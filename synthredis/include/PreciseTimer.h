#ifndef __PRECISE_TIMER_H__
#define __PRECISE_TIMER_H__

#include <cstdint>
#include "util.h"

class PreciseTimer {
public:
  PreciseTimer();
  void start();
  void stop();

  double getElapsedSec();
  double getElapsedMs();
  double getElapsedUs();

private:
  static uint32_t getFrequency();
  static uint64_t readMSR(uint32_t msr_id);
  double getElapsed(double unitsRatio);

  unsigned long long frequency;
  unsigned long long startT;
  unsigned long long stopT;
};

#endif  // __PRECISE_TIMER_H__

