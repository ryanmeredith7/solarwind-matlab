function [data, time] = getOmni(date)
    arguments
        date (1,1) datetime {mustBeAfter(date, 1995)}
    end

    [year, month] = ymd(date);

    fileName = sprintf("%4i-%02i.cdf", year, month);
    archive = fullfile("data", "omni.7z");
    file = tempdir + fileName;

    try

        get7zip(archive, fileName, tempdir);

    catch err

        if err.identifier == "g7zip:ArchiveIncomplete"

            if ~isfolder("data")
                mkdir("data");
            end

            try
                websave(file, sprintf("https://cdaweb.gsfc.nasa.gov/pub/" ...
                    + "data/omni/omni_cdaweb/hro2_1min/%1$4i/" ...
                    + "omni_hro2_1min_%1$4i%2$02i01_v01.cdf", ...
                    year, month));
            catch exception
                if isfile(file + ".html")
                    delete(file + ".html");
                end
                if exception.identifier ...
                        == "MATLAB:webservices:HTTP404StatusCodeError"
                    error("No OMNI data for %s.", date);
                else
                    rethrow(exception);
                end
            end

            add7zip(archive, file);

        else

            rethrow(err);

        end

    end

    delFile = onCleanup(@() delete(file));

    raw = cdfread(file, "Variables", ["Epoch", "Pressure"], ...
        "CombineRecords", true, "ConvertEpochToDatenum", true);

    data = raw{2};
    data(data == single(99.99)) = NaN;

    time = datetime(raw{1}, "ConvertFrom", "datenum", ...
        "TimeZone", "UTCLeapSeconds");

end
