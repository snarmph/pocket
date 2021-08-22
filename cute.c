// #define SPRITEBATCH_MALLOC(size, ctx) malloc(size)
// #define SPRITEBATCH_FREE(ptr, ctx) free(ptr)
// #define SPRITEBATCH_MEMCPY(dst, src, n) memcpy(dst, src, n)
// #define SPRITEBATCH_MEMSET(ptr, val, n) memset(ptr, val, n)
// #define SPRITEBATCH_MEMMOVE(dst, src, n) memmove(dst, src, n)
//#define SPRITEBATCH_ASSERT(condition) assert(condition)

// void malloc(unsigned int size) { (void)size; }
// void free(void *ptr) { (void)ptr; }
// void *memcpy(void *dst, const void *src, unsigned int n) { (void)src; (void)n; return dst; }
// void *memset(void *dst, char val, unsigned int n) { (void)val; (void)n; return dst; }
// void *memmove(void *dst, const void *src, unsigned int n) { (void)src; (void)n; return dst; }
// void assert(char cond) { (void)cond; }

#define SPRITEBATCH_IMPLEMENTATION
#include "cute_spritebatch.h"