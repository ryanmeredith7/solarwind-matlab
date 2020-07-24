function add7zip(archive, file)
    arguments
        archive (1,1) string
        file (1,1) string
    end

    [status, output] = system(sprintf("7zr a -bd -ms- %s %s", archive, file));

    switch status
        case 0
        case 1
            warning("7zip warning:\n%s", output);
        case 2
            error("7zip error:\n%s", output);
        case 7
            error("7zip command line error:\n%s", output);
        case 8
            error("7zip ran out of memory.");
        otherwise
            error("Unknown 7zip error:\n%s", output);
    end

end
