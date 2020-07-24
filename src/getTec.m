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

    fileName = sprintf("%sc%2i%03i%c.ismr", loc, yr - 2000, doy, hr + 97);
    archive = fullfile("data", "ismr.7z");
    file = tempdir + fileName;

    try

        get7zip(archive, fileName, tempdir);

    catch err

        if err.identifier == "g7zip:ArchiveIncomplete"

            if ~isfolder("data")
                mkdir("data");
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

            ftpcln = onCleanup(@() ftpObj.close());

            try
                ftpObj.cd(sprintf("gps/ismr/%4i/%03i/%02i", yr, doy, hr));
            catch exception
                if exception.identifier == "MATLAB:ftp:NoSuchDirectory"
                    error("ISMR:NoData", "No TEC data for %s", date);
                else
                    rethrow(exception);
                end
            end

            try
                ftpObj.mget(fileName + ".gz", tempdir);
            catch exception
                if exception.identifier == "MATLAB:ftp:FileUnavailable"
                    error("ISMR:NoData", "No TEC data for %s at %s", date, loc);
                else
                    rethrow(exception);
                end
            end

            gunzip(file + ".gz");
            delete(file + ".gz");

            add7zip(archive, file);

        else

            rethrow(err);

        end

    end

    delFile = onCleanup(@() delete(file));

    opts = getOpts();

    tbl = readtable(file, opts, "ReadVariableNames", false);

    assert(~isempty(tbl), "File is empty.");

end

function opts = getOpts()

    optsFile = fullfile("data", "ismr_opts.mat");

    try

        load(optsFile, "opts");

    catch exception

        if exception.identifier == "MATLAB:load:couldNotReadFile"

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

            save(optsFile, "opts");

        else

            rethrow(exception);

        end

    end

end
