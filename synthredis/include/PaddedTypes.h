#ifndef __PADDED_TYPES_H__
#define __PADDED_TYPES_H__

#include <atomic>
#include "util.h"

struct PaddedUInt {
  u32 val;
  char pad_[CACHE_LINE - sizeof(u32)];

  PaddedUInt():val(0){}
} CACHE_ALIGN;



struct PaddedVolatileUInt {
  volatile u32 val;
  char pad_[CACHE_LINE - sizeof(u32)];

  PaddedVolatileUInt():val(0){}
} CACHE_ALIGN;


struct PaddedVolatileUInt64 {
  volatile u64 val;
  char pad_[CACHE_LINE - sizeof(u64)];

  PaddedVolatileUInt64():val(0){}
} CACHE_ALIGN;


template <class T>
union PaddedAtomic {
  std::atomic<T> val;
  char pad_[CACHE_LINE];
} CACHE_ALIGN;


class FakeAtomic {
private:
  volatile u32 val;
public:
  u32 load(std::memory_order = std::memory_order_relaxed) {
    return val;
  }

  void store(u32 newval, std::memory_order = std::memory_order_relaxed) {
    val = newval;
  }

  bool compare_exchange_strong(u32 &oldval, u32 newval, std::memory_order = std::memory_order_relaxed, std::memory_order = std::memory_order_relaxed) {
    return (CAS32(&val, oldval, newval) == (oldval));
  }
} CACHE_ALIGN;

//template <class T>
union PaddedFakeAtomic {
  //volatile u32 val;
  FakeAtomic val;
  //std::atomic<u32> val;
  char pad_[CACHE_LINE];
} CACHE_ALIGN;


#endif  // __PADDED_TYPES_H__
