#ifndef __UTIL_H__
#define __UTIL_H__

#include <cassert>
#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <iostream>

#include "inttypes.h"
#include "atomic.h"

#define KREAD(x)        ((x))
#define KWRITE(x, y)    (x) = (y) 


#define NAME1(t)  #t
#define NAME(t)   NAME1(t)

#define ASSERT(x)   assert((x))
#define ASSERTZ(x)  ASSERT(!(x))

#define MAXUINT32         (UINT32_MAX)
 
#define CACHE_LINE    128 
#define CACHE_ALIGN   __attribute__((aligned(CACHE_LINE))) 


#define KNRM  "\x1B[0m"
#define KRED  "\x1B[31m"
#define KGRN  "\x1B[32m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KMAG  "\x1B[35m"
#define KCYN  "\x1B[36m"
#define KWHT  "\x1B[37m"
#define RESET "\x1B[0m"

#define pr_error(eno, func) \
               do { errno = eno; perror(KRED func); printf(RESET);} while (0)


#define INIT_EXPB  128

inline void Backoff(u32 times) {
  u32 max = times;
  if (max < INIT_EXPB) max = INIT_EXPB;
  for (u32 t = 0; t < max; ++t) {
    PAUSE();
  }
}

#endif  // __UTIL_H__
