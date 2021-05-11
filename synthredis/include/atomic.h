#ifndef __ATOMIC_H__
#define __ATOMIC_H__

#include <xmmintrin.h>

#define PAUSE()    _mm_pause() 
#define BACKOFF(x)  { for (uint32_t i = 0; i < x; i++) PAUSE(); } 
#define THRLOCAL   __thread  

#define MEMBAR()  __asm __volatile("mfence;" : : : "memory")
#define WMEMBAR() __asm __volatile("sfence;" : : : "memory")
#define RMEMBAR() __asm __volatile("lfence;" : : : "memory")
#define COMPBAR() __asm __volatile("" ::: "memory")

// From https://www.cs.rochester.edu/users/faculty/sandhya/csc258/assignments/proj2/atomic_ops.h
#if 0
static inline unsigned long
cas(volatile unsigned long* ptr, unsigned long old, unsigned long _new)
{
    unsigned long prev;
    asm volatile("lock;"
                 "cmpxchgq %1, %2;"
                 : "=a"(prev)
                 : "r"(_new), "m"(*ptr), "a"(old)
                 : "memory");
    return prev;
}
#endif

static inline unsigned int
cas(volatile unsigned int* ptr, unsigned int old, unsigned int _new)
{
    unsigned int prev;
    asm volatile("lock;"
                 "cmpxchgl %1, %2;"
                 : "=a"(prev)
                 : "r"(_new), "m"(*ptr), "a"(old)
                 : "memory");
    return prev;
}

//#define CAS32(addr,oldv,newv)   __sync_val_compare_and_swap((addr),(oldv),(newv))
#define CAS32(addr,oldv,newv)   cas((addr), (oldv), (newv))
#define CAS64(addr,oldv,newv)   __sync_val_compare_and_swap((addr),(oldv),(newv))
#define CASPO(addr,oldv,newv)   __sync_val_compare_and_swap((addr),(oldv),(newv))

#define FetchAndAdd32(p, v)   __sync_fetch_and_add((p), (v))
#define FetchAndAdd64(p, v)   __sync_fetch_and_add((p), (v))
#define AtomicInc32(p)        FetchAndAdd32((p), 1)
#define AtomicInc64(p) __sync_add_and_fetch(p, 1)
#define AtomicDec32(p) __sync_sub_and_fetch(p, 1)
#define AtomicDec64(p) __sync_sub_and_fetch(p, 1)

#define CompareSwap32(ptr32,cmp32,val32) __sync_val_compare_and_swap((u32*)ptr32,cmp32,val32)
#define CompareSwap64(ptr64,cmp64,val64) __sync_val_compare_and_swap((u64*)ptr64,cmp64,val64)
#define CompareSwapPtr(ptr,cmp,val) __sync_val_compare_and_swap((void**)ptr,(void*)cmp,(void*)val)

#define MemBarrier __sync_synchronize

#endif  // __ATOMIC_H__
