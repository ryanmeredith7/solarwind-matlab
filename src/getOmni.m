function data = getOmni(date)
    arguments
        date (1,1) datetime {mustBeAfter(date, 1995)}
    end

    [year, month] = ymd(date);

    fileName = sprintf("%4i-%02i.cdf", year, month);
    fileDir = fullfile("data", "omni");
    file = fullfile(fileDir, fileName);

    if ~isfile(file)

        if ~isfolder(fileDir)
            mkdir data omni;
        end

        url = sprintf(...
            "https://cdaweb.gsfc.nasa.gov/pub/data/omni/omni_cdaweb/hro2_1min/" ...
            + "%1$4i/omni_hro2_1min_%1$4i%2$02i01_v01.cdf", year, month);

        try
            websave(file, url);
        catch exception
            if isfile(file + ".html")
                delete(file + ".html");
            end
            if exception.identifier == "MATLAB:webservice:HTTP404StatusCodeError"
                error("No OMNI data for %s", date);
            else
                rethrow(exception);
            end
        end

    end

    data = cdfread(file, "Variables", "Pressure", "CombineRecords", true);
    data(data == single(99.99)) = NaN;

end
