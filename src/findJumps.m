function [jumpPos, jumpMag] = findJumps(inData)
    arguments
        inData {mustBeNumeric,mustBeNonempty,mustBeReal}
    end

    if ~isa(gcp("nocreate"), "parallel.ThreadPool")
        delete(gcp("nocreate"));
        pp = parpool("threads");
        ppcln = onCleanup(@() delete(pp));
    end

    buf = 200;

    emptyParts = @(n) table( ...
        zeros(n, 1, "int32"), zeros(n, 1, "int32"), ...
        zeros(n, 1, "double"), zeros(n, 1, "double"), ...
        zeros(n, 1, "int32"), zeros(n, 1, "double"), ...
        zeros(n, 2, "double"), zeros(n, 2, "double"), ...
        'VariableNames', [ ...
            "start", "finish", "level", "loss", ...
            "split", "diff", "levels", "losses" ] );

    parts = emptyParts(buf);

    level = mean(inData(:), 'omitnan');

    parts(1,:) = mkPart(inData, 1, numel(inData), level, ...
        sum((inData(:) - level) .^ 2, 'omitnan'));

    lossDiff = parts.diff(1);

    splitInd = 1;

    k = 1;

    while lossDiff > 1000

        if k >= buf
            parts = [parts; emptyParts(50)]; %#ok<AGROW>
            buf = buf + 50;
        end

        k = k + 1;

        [parts(splitInd,:), parts(k,:)] = splitPart(inData, parts(splitInd,:));

%       viewJumps(inData, parts(1:k,:)); keyboard;

        [lossDiff, splitInd] = max(parts.diff(1:k), [], 'omitnan');

    end

    parts(k+1:end,:) = [];

    parts = sortrows(parts);

    jumpPos = parts.start;
    jumpMag = parts.level;

%   viewJumps(inData, parts);

end

function part = mkPart(inData, a, b, level, loss)

    n = b - a - 1;

    if n > 0

        x1 = inData(a:b-1);
        x2 = inData(a+1:b);

        m1 = cumsum(x1, 'omitnan') ...
            ./ cumsum(~isnan(x1));
        m2 = cumsum(x2, 'omitnan', 'reverse') ...
            ./ cumsum(~isnan(x2), 'reverse');

        s = zeros(2, n);

        parfor i = 1:n
            s(:,i) = [sum((x1(1:i) - m1(i)) .^ 2, 'omitnan'); ...
                sum((x2(i:end) - m2(i)) .^ 2, 'omitnan')];
        end

        [m, i] = min(sum(s), [], 'omitnan');

        part = {a, b, level, loss, i + a, loss - m, [m1(i), m2(i)], s(:,i).'};

    else

        part = {a, b, level, loss, b, loss, [inData(a), inData(b)], [0, 0]};

    end

end

function [p1, p2] = splitPart(inData, part)

    p1 = mkPart(inData, part.start, part.split - 1, ...
        part.levels(1), part.losses(1));

    p2 = mkPart(inData, part.split, part.finish, ...
        part.levels(2), part.losses(2));

end

function viewJumps(data, jumps)
    m = zeros(numel(data), 1);
    for i = 1:height(jumps)
        m(jumps.start(i):jumps.finish(i)) = jumps.level(i);
    end
    plot([data(:), m]);
end
