/* See COPYRIGHT for copyright information. */

#ifndef JOS_INC_ASSERT_H
#define JOS_INC_ASSERT_H

#include <inc/stdio.h>

void _warn(const char*, int, const char*, ...);
void _panic(const char*, int, const char*, ...) __attribute__((noreturn));

#define warn(...) _warn(__FILE__, __LINE__, __VA_ARGS__)
#define panic(...) _panic(__FILE__, __LINE__, __VA_ARGS__)

#define assert(x)		\
	do { if (!(x)) panic("assertion failed: %s", #x); } while (0)

// static_assert(x) will generate a compile-time error if 'x' is false.
#define static_assert(x)	switch (x) case 0: case (x):

void _info_free_page_list(const char*, int, int);
#define info_free_page_list(...) _info_free_page_list(__FILE__, __LINE__, __VA_ARGS__)

void _info_env_list(const char*, int, void *);
#define info_env_list(...) _info_env_list(__FILE__, __LINE__, __VA_ARGS__)

void _fprintf(const char*, int, const char *fmt, ...);
#define kprintf(...) _fprintf(__FILE__, __LINE__, __VA_ARGS__)

void _printf_mem(const char*, int, void *, int);
#define mprintf(start, cnt) _printf_mem(__FILE__, __LINE__, start, cnt)

void printf_from_page(void *, void *, int);

#endif /* !JOS_INC_ASSERT_H */
