function tbl = preProcessTec(tbl)
    arguments
        tbl (:,12) table {mustBeNonEmpty}
    end

    tbl(tbl{:,4} < 10,:) = [];

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

end
