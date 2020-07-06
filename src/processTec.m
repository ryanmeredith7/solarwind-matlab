function tbl = processTec(tbl)
    arguments
        tbl (:,12) table {mustBeNonempty}
    end

    tbl(tbl{:,4} <= 10,:) = [];

    tbl = mergevars(tbl, 5:6, "NewVariableName", "tec1");
    tbl = mergevars(tbl, 6:7, "NewVariableName", "tec2");
    tbl = mergevars(tbl, 7:8, "NewVariableName", "tec3");
    tbl = mergevars(tbl, 8:9, "NewVariableName", "tec4");
    tbl = stack(tbl, 5:8);

    time = datetime(1980, 1, 6, "TimeZone", "UTCLeapSeconds") ...
        + days(7 * tbl{:,1}) + seconds(tbl{:,2});
    time(tbl{:,5} == "tec1") = time(tbl{:,5} == "tec1") - seconds(45);
    time(tbl{:,5} == "tec2") = time(tbl{:,5} == "tec2") - seconds(30);
    time(tbl{:,5} == "tec3") = time(tbl{:,5} == "tec3") - seconds(15);

    tbl = table2timetable(tbl(:,[3,6]), "RowTimes", time);
    tbl = unstack(tbl, 2, 1, "VariableNamingRule", "preserve");

    if ~isregular(tbl)
        error("Not implemented yet")
    end

    tbl = varfun(@prn, tbl);

end

function out = prn(in)

    atec = in(:,1);
    rtec = cumsum(in(:,2), 'omitnan');
    rtec(isnan(in(:,2))) = NaN;

    out = rtec + median(atec - rtec, 'omitnan');

end
