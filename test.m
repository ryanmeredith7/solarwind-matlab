assert(usejava('jvm'), "Needs JVM");
addpath src;

locs = ["arc", "arv", "chu", "cor", "edm", "fsi", "fsm", "gjo", "kug", ...
    "mcm", "rab", "ran", "rep", "sac"];

jumps = datetime(readmatrix("data/jumps.txt", "OutputType", "string", ...
    "Delimiter", ','), "TimeZone", "UTCLeapSeconds").';

for jump = jumps
    for loc = locs
        file = fullfile("data", "figures", datestr(jump, "yyyy-mm-dd-HH"), ...
            loc + ".fig");
        if isfile(file)
            openfig(file);
            title(loc + " - " + string(jump));
            keyboard;
            close(gcf);
        end
    end
end
