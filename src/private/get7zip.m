function get7zip(archive, file, outDir)
    arguments
        archive (1,1) string
        file (1,1) string
        outDir (1,1) string
    end

    cmd = sprintf("7zr e -bd -aos -o%s %s %s", outDir, archive, file);

    [status, output] = system(cmd);

    switch status
        case 0
            if contains(output, "No files to process")
                error("g7zip:ArchiveIncomplete", ...
                    "File %s not in archive %s.", file, archive);
            end
        case 1
            warning("7zip warning:\n%s", output);
        case 2
            if contains(output, "ERROR: No more files")
                error("g7zip:ArchiveIncomplete", "No archive %s.", archive);
            else
                error("7zip error:\n%s", output);
            end
        case 7
            error("7zip command line error:\n%s", output);
        case 8
            error("7zip ran out of memory.");
        otherwise
            error("Unknown 7zip error:\n%s", output);
    end

end
