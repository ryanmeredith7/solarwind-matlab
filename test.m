assert(usejava('jvm'), "Needs JVM");
addpath src;

locs = ["arc", "arv", "chu", "cor", "edm", "fsi", "fsm", "gjo", "kug", ...
    "mcm", "rab", "ran", "rep", "sac"];

jumps = datetime(readmatrix("data/jumps.txt", "OutputType", "string", ...
    "Delimiter", ','), "TimeZone", "UTCLeapSeconds").';

for jump = jumps(39:end)
    for loc = locs
        try
            stackedplot(processTec(getTec(jump, loc)));
        catch err
            if startsWith(err.message, ["No TEC data", "File is empty"])
                continue;
            else
                rethrow(err);
            end
        end
        dir = fullfile("data", "figures", datestr(jump, "yyyy-mm-dd-HH"));
        if ~isfolder(dir)
            mkdir(dir);
        end
        savefig(fullfile(dir, loc));
    end
end
