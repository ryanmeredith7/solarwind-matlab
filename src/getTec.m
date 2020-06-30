function getTec(date, loc)
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

        ftpObj = mkFTP();
        clnup = onCleanup(@() close(ftpObj));

        cd(ftpObj, sprintf("gps/ismr/%4i/%03i/%02i", yr, doy, hr));
        mget(ftpObj, fileName, fileDir);

    end

    keyboard

end
