#define __STDC_WANT_LIB_EXT1__ 1

#include <stdlib.c>
#include <stdbool.h>

#ifndef __STDC_LIB_EXT1__
    #error Needs C11 Annex K (Safe C).
#endif

void closeOnError(FILE* fp);
void restoreHandler(void);
void newHandler(const char* restrict msg, void* restrict ptr, errno_t err);

static FILE* openFile;
static constraint_handler_t oldHandler;

void closeOnError(FILE* fp) {

    openFile = fp;

    oldHandler = set_constraint_handler(&newHandler);

}

void restoreHandler(void) {

    set_constraint_handler(oldHandler);

}

void newHandler(const char* restrict msg, void* restrict ptr, errno_t err) {

    fclose(openFile);
    (*oldHandler)(msg, ptr, err);

}
