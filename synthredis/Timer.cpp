///
/// Timer class implementation
///

#include <cstdint>
#include <fcntl.h>
#include <unistd.h>

#include "util.h"
#include "Timer.h"


Timer::Timer() { 
  startTime_ = stopTime_ = std::chrono::high_resolution_clock::now();
}

void Timer::start() {
  startTime_ = std::chrono::high_resolution_clock::now();
}

void Timer::stop() {
  stopTime_ = std::chrono::high_resolution_clock::now();
}

double Timer::getElapsedSec() {
  std::chrono::duration<double> diff = stopTime_ - startTime_;
  return diff.count();
}

double Timer::getElapsedMs() {
  return std::chrono::duration_cast<std::chrono::milliseconds>(stopTime_ - startTime_).count();
}

double Timer::getElapsedUs() {
  return std::chrono::duration_cast<std::chrono::microseconds>(stopTime_ - startTime_).count();
}
                                      
