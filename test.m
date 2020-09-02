assert(usejava('awt') || usejava('swing'), "Needs JVM");
addpath src;

locs = ["arc", "arv", "chu", "cor", "edm", "fsi", "fsm", "gjo", "kug", ...
    "mcm", "rab", "ran", "rep", "sac"];

jumps = datetime(readmatrix("data/bigJumps.txt", "OutputType", "string", ...
    "Delimiter", ','), "TimeZone", "UTCLeapSeconds").';

if startsWith(input("Load data? ", 's'), 'y', "IgnoreCase", true)
    load(fullfile("data", "tecData.mat"), "tecData");
    i = length(tecData);
    jumps(1:i) = [];
else
    tecData = struct([]);
    i = 0;
end

for jump = jumps

    i = i + 1;

    folder = fullfile("data", "figures", string(jump));
    omniFig = openfig(fullfile(folder, "omni.fig"));

    for loc = locs

        items = dir(fullfile(folder, loc + "*.fig"));
        n = length(items);
        if n <= 0, continue; end

        tecData(i).(loc) = table('Size', [n, 5], 'VariableTypes', ["uint8", ...
            "datetime", "doubleNaN", "datetime", "doubleNaN"], ...
            'VariableNames', ["prn", "lowTime", "lowVal", "highTime", ...
            "highVal"]);

        tecData(i).(loc).lowTime.TimeZone = "UTCLeapSeconds";
        tecData(i).(loc).highTime.TimeZone = "UTCLeapSeconds";

        for j = 1:n

            fig = openfig(fullfile(folder, items(j).name));

            tecData(i).(loc).prn(j) = sscanf(items(j).name, loc + "-prn_%02u.fig");

            input("Select low data point.", 's');

            dt = findobj(fig, "Type", "DataTip");

            if ~isempty(dt)
                tecData(i).(loc).lowTime(j) = dt.X;
                tecData(i).(loc).lowVal(j) = dt.Y;
                delete(dt);
                input("Select high data point.", 's');
                dt = findobj(fig, "Type", "DataTip");
                tecData(i).(loc).highTime(j) = dt.X;
                tecData(i).(loc).highVal(j) = dt.Y;
            end

            if isgraphics(fig, "figure")
                close(fig);
            end

        end

    end

    if isgraphics(omniFig, "figure")
        close(omniFig);
    end

    if startsWith(input("Save and exit? ", 's'), 'y', "IgnoreCase", true)
        save(fullfile("data", "tecData.mat"), "tecData");
        return;
    end

end
