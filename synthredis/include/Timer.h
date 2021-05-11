#ifndef __TIMER_H__
#define __TIMER_H__

#include <cstdint>
#include <chrono>
#include "util.h"

class Timer {
public:
  Timer();
  void start();
  void stop();

  double getElapsedSec();
  double getElapsedMs();
  double getElapsedUs();

private:
  std::chrono::time_point<std::chrono::high_resolution_clock> startTime_;
  std::chrono::time_point<std::chrono::high_resolution_clock> stopTime_;
};

#endif  // __TIMER_H__

