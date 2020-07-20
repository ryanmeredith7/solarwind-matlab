openProject Solarwind.prj;

if isfile("data/jumps.txt")
    delete data/jumps.txt;
end

diary data/jumps.txt;

for d = datetime(2014, 1, 1):calmonths(1):datetime(2020, 6, 1)
    [data, times] = getOmni(d);
    [inds, lvls] = findJumps(data);
    i = find(diff(lvls) >= 5.5) + 1;
    disp(times(inds(i)));
end

diary off;
