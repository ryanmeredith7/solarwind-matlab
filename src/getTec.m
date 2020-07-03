function tbl = getTec(date, loc)
    arguments
        date (1,1) datetime {mustBeAfter(date, 2013)}
        loc (1,1) string
    end

    yr = year(date);

    doy = day(date, "dayofyear");

    hr = hour(date);

    fileName = sprintf("%sc%2i%03i%c.ismr.gz", loc, yr - 2000, doy, hr + 97);
    fileDir = fullfile("data", "ismr");
    file = fullfile(fileDir, fileName);

    if ~isfile(file)

        if ~isfolder(fileDir)
            mkdir data ismr;
        end

        try
            ftpObj = mkFTP();
        catch
            error("FTP not available, must download files manually.");
        end
        ftpcln = onCleanup(@() close(ftpObj));

        cd(ftpObj, sprintf("gps/ismr/%4i/%03i/%02i", yr, doy, hr));
        mget(ftpObj, fileName, fileDir);

    end

    tmpFile = gunzip(file, tempdir);
    tmpFile = tmpFile{1};
    tmpcln = onCleanup(@() delete(tmpFile));

    opts = delimitedTextImportOptions( ...
        "NumVariables", 24, ...
        "SelectedVariableNames", [1:3, 6, 17:24], ...
        "DataLines", 1, ...
        "Delimiter", ',', ...
        "WhiteSpace", ' ', ...
        "ConsecutiveDelimitersRule", "error", ...
        "LeadingDelimitersRule", "error", ...
        "MissingRule", "fill", ...
        "EmptyLineRule", "error", ...
        "ImportErrorRule", "error", ...
        "ExtraColumnsRule", "ignore" );

    opts = setvaropts(opts, "QuoteRule", "error", "EmptyFieldRule", "error", ...
        "TreatAsMissing", "\s*nan");

    opts = setvaropts(opts, 1, "Type", "int16", "FillValue", -1);
    opts = setvaropts(opts, 2, "Type", "int32", "FillValue", -1);
    opts = setvaropts(opts, 3, "Type", "uint8", "FillValue", 255);
    opts = setvaropts(opts, 6, "Type", "int8", "FillValue", -128);
    opts = setvaropts(opts, 17:24, "Type", "double", "FillValue", NaN);

    tbl = readtable(tmpFile, opts, "ReadVariableNames", false);

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

    tbl = table2timetable(tbl(:,[3,4,6]), "RowTimes", time);
    tbl = splitvars(tbl, 3, "NewVariableNames", ["tec", "dtec"]);
    tbl = renamevars(tbl, 2, "elev");
    tbl = unstack(tbl, 2:4, 1);

    keyboard

end
