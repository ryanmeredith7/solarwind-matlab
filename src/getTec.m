function tbl = getTec(date, loc)
    arguments
        date (1,1) datetime {mustBeAfter(date, 2013)}
        loc (1,1) string {mustBeMember(loc, ["arc", "arv", "chu", "cor", ...
            "edm", "fsi", "fsm", "gjo", "kug", "mcm", "rab", "ran", "rep", ...
            "sac"])}
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
        catch exception
            if exception.identifier == "MATLAB:UndefinedFunction"
                error("FTP not available, must download files manually.");
            else
                rethrow(exception);
            end
        end

        ftpcln = onCleanup(@() close(ftpObj));

        try
            cd(ftpObj, sprintf("gps/ismr/%4i/%03i/%02i", yr, doy, hr));
        catch exception
            if exception.identifier == "MATLAB:ftp:NoSuchDirectory"
                error("No TEC data for %s", date);
            else
                rethrow(exception);
            end
        end

        try
            mget(ftpObj, fileName, fileDir);
        catch exception
            if exception.identifier == "MATLAB:ftp:FileUnavailable"
                error("No TEC data for %s at %s", date, loc);
            else
                rethrow(exception);
            end
        end

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
        "ExtraColumnsRule", "ignore") ...
        .setvaropts( ...
            "QuoteRule", "error", ...
            "EmptyFieldRule", "error", ...
            "TreatAsMissing", "\s*nan") ...
        .setvaropts(1, "Type", "int16", "FillValue", -1) ...
        .setvaropts(2, "Type", "int32", "FillValue", -1) ...
        .setvaropts(3, "Type", "uint8", "FillValue", 255) ...
        .setvaropts(6, "Type", "int8", "FillValue", -128) ...
        .setvaropts(17:24, "Type", "double", "FillValue", NaN);

    tbl = readtable(tmpFile, opts, "ReadVariableNames", false);

end
