#define __STDC_WANT_LIB_EXT1__ 1

#include <stdio.h>

#ifndef __STDC_LIB_EXT1__
    #error Needs C11 Annex K (Safe C).
#endif

errno_t fread_s(void *buffer, size_t size, size_t count, FILE *stream);
errno_t fseek_s(FILE *stream, long offset, int origin);

// fread_s :: Exception e => Handle -> Int -> Int -> StateT [a] IO (Maybe e)
errno_t fread_s(void *buffer, size_t size, size_t count, FILE *stream) {

    constraint_handler_t handler;

    handler = set_contraint_handler(0);
    set_constraint_handler(handler);

    if (!buffer) {
        (*handler)("NULL pointer to buffer argument.", 0, EINVAL);
        return EINVAL;
    }

    if (!stream) {
        (*handler)("Invalid file descriptor.", 0, EBADF);
        return EBADF;
    }

    if (fread(buffer, size, count, stream) != size * count) {
        if (feof(stream))
            (*handler)("Unexpexted end of file.", 0, EIO);
        else if (ferror(stream))
            (*handler)("Error reading file,", 0, EIO);
        else
            (*handler)("Unknown error reading file.", 0, EIO);
        return EIO;
    }

    return 0;

}

// fseek_s :: Exception e => Handle -> Word -> SeekMode -> IO (Maybe e)
errno_t fseek_s(FILE *stream, unsigned long offset, int origin) {

    constraint_handler_t handler;

    handler = set_constraint_handler(0);
    set_constraint_handler(handler);

    if (origin != SEEK_SET && origin != SEEK_CUR && origin != SEEK_END) {
        (*handler)("Invalid origin argument.", 0, EINVAL);
        return EINVAL;
    }

    if (!stream) {
        (*handler)("Invalid file descriptor.", 0, EBADF);
        return EBADF;
    }

    if (fseek(fp, offest, origin)) {
        (*handler)("Error seeking file pointer.", 0, EIO);
        return EIO;
    }

}
