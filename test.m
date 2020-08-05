assert(usejava('jvm'), "Needs JVM");
addpath src;

locs = ["arc", "arv", "chu", "cor", "edm", "fsi", "fsm", "gjo", "kug", ...
    "mcm", "rab", "ran", "rep", "sac"];

jumps = datetime(readmatrix("data/jumps.txt", "OutputType", "string", ...
    "Delimiter", ','), "TimeZone", "UTCLeapSeconds").';

for jump = jumps

    folder = fullfile("data", "figures", string(jump));
    omniFig = openfig(fullfile(folder, "omni.fig"));

    for loc = locs
        items = dir(fullfile(folder, loc + "*.fig"));
        if isempty(items), continue; end
        n = length(items);
        figs = gobjects(n, 1);

        for i = 1:n
            figs(i) = openfig(fullfile(folder, items(i).name));
        end

        m = msgbox("Next?", "Next");
        uiwait(m);

        valid = ishandle(figs);
        if any(valid), close(figs(valid)); end

    end

    if ishandle(omniFig), close(omniFig); end

end
