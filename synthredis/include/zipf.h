#ifndef _ZIPF_H
#define _ZIPF_H

#include <cstdio>
#include <vector>
#include <unordered_map>
#include <cmath>

#include "prng.h"

class ZipfianGenerator {
private:
  Prng _prng;

  double _curr_number;
  int _count;
  const double _order;
  std::vector<double> _discretized_cdf;

  
  // Formula for calucalting GHN from wikipedia
  double getNextGeneralizedHarmonicNumber(){
    _curr_number += 1 / (pow(double(_count++), _order));
    return _curr_number;
  }
  
public:
  ZipfianGenerator(int nItems, double order, unsigned long seed=0);

  // Formula for calculating Zipfian CDF from Wikipedia
  void Init();

  // Perform binary search to find the highest index less than a random (0.0, 1.0).
  // This effective "inverts" the CDF, giving us the target distribution.
  int GetIndex();

  void print();
};
#endif
