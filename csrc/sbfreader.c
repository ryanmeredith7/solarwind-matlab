#define __STDC_WANT_LIB_EXT1__ 1

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifndef __STDC_LIB_EXT1__
    #error Needs C11 Annex K (Safe C).
#endif

#define IDMASK 0x1FFF

errno_t SBFReader(const char* file, double* buffer);

// SBFReader :: Exception e => FilePath -> StateT [Double] IO (Maybe e)
errno_t SBFReader(const char* file, double* buffer) {

    FILE* fp;

    long startOfBlock;

    char sync[2];
    uint16_t id;
    uint16_t length;

    if (err = fopen_s(&fp, file, "rb"))
        return err;

    closeOnError(fp);

    startOfBlock = ftell(fp);
    if (startOfBlock == -1) {
        err = errno;
        newHandler(strerror(err), 0, err);
        return err;
    }

    while (!fread_s(sync, 1, 2, fp)) {

        if (strncmp(sync, "$@", 2)) {
            newHandler("Header out of sync.", 0, EILSEQ);
            return EILSEQ;
        }

        if (err = fseek_s(fp, 2, SEEK_CUR))
            return err;
        if (err = fread_s(id, 2, 1, fp))
            return err;
        if (err = fread_s(length, 2, 1, fp))
            return err;

        if (length % 4) {
            newHandler("Bad block length.", 0, EILSEQ);
            return EILSEQ;
        }

        switch (id & IDMASK) {

            default:
                fseek_s(fp, startOfBlock, SEEK_SET);
                break;

        }

        startOfBlock = ftell(fp);
        if (startOfBlock == -1) {
            err = errno;
            newHandler(strerror(err), 0, err);
            return err;
        }

    }

    restoreHandler();
    fclose(fp);
    return 0;

}
