assert(usejava('jvm'), "Needs JVM");
addpath src;

locs = ["arc", "arv", "chu", "cor", "edm", "fsi", "fsm", "gjo", "kug", ...
    "mcm", "rab", "ran", "rep", "sac"];

jumps = datetime(readmatrix("data/jumps.txt", "OutputType", "string", ...
    "Delimiter", ','), "TimeZone", "UTCLeapSeconds").';

for jump = jumps

    [omniData, omniTime] = getOmni(jump);

    a = dateshift(jump, "start", "hour");
    b = a + minutes(59);
    inds = a <= omniTime & omniTime <= b;
    x = omniData(inds);
    t = omniTime(inds);

    while all(isnan(x(t < jump)))
        a = a - hours(1);
        inds = a <= omniTime & omniTime <= b;
        x = omniData(inds);
        t = omniTime(inds);
    end

    while all(isnan(x(t > jump)))
        b = b + hours(1);
        inds = a <= omniTime & omniTime <= b;
        x = omniData(inds);
        t = omniTime(inds);
    end

    myplot("omni", x, jump, t);

    for loc = locs

        tecData = table();
        next = false;

        for d = a:hours(1):b
            try
                tecData = [tecData; getTec(d, loc)];
            catch err
                if err.identifier == "ISMR:NoData" || err.message == "File is empty."
                    next = true;
                    break;
                else
                    rethrow(err);
                end
            end
        end

        if next; continue; end

        tecData = retime(processTec(tecData), "minutely", "mean");
        tecData(1,:) = [];

        for var = tecData.Properties.VariableNames
            var = var{1};
            myplot(loc + "-" + var, tecData{:,var}, jump);
        end

    end

end

function myplot(name, x, jump, t)
    persistent fig ln tl xln

    if isempty(fig)

        fig = figure("Name", name, "WindowStyle", "docked", "NumberTitle", false);
        ln = line(t, x);
        xln = xline(jump);
        tl = title(name + " - " + string(jump), "Interpreter", "none");

    else

        if nargin == 4
            ln.XData = t;
            xln.Value = jump;
        end

        fig.Name = name;
        ln.YData = x;
        tl.String = name + " - " + string(jump);

        drawnow();

    end

    dir = fullfile("data", "figures", string(jump));

    if ~isfolder(dir)
        mkdir(dir);
    end

    savefig(fig, fullfile(dir, name), "compact");

end
