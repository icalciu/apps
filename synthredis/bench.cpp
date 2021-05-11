#include <cstdio>
#include <cstring>
#include <iostream>
#include <thread>

#include "util.h"
#include "Timer.h"
#include "numalib.h"
#include "prng.h"
#include "zipf.h"
#include "PaddedTypes.h"
#include "RedisServer.h"

#include <kapi.h>

enum {
  ARG_PROG_, 
  ARG_THREADS_,
  ARG_RANDOM_,
  ARG_PROB_ZADD_,
  ARG_PROB_ZRANK_,
  ARG_PROB_ZRANGE_,
  ARG_CAPACITY,
  ARG_INITSIZE,
  ARG_NUM_SETS,
  ARG_RW_DELAY_,
  ARG_COMPUTE_DELAY_,
  ARG_OPS_LIMIT,
  ARG_USE_KAPI,
  ARG_NUM_
};

enum {
  PROB_ZADD_,
  PROB_ZRANK_,
  PROB_ZRANGE_,
  PROB_ZSCORE_
};

THRLOCAL PaddedVolatileUInt* _local_v;

struct Globals {
  PaddedVolatileUInt pre_start_threads, start_threads, stop_threads;
  PaddedVolatileUInt threadIds;
  PaddedUInt rw_delay;
  PaddedUInt compute_delay;
  u32 threads;
  std::string random;
  u32 prob[5]; 
  u32 param_capacity;
  u32 param_initsize;
  u32 param_num_sets;
  u32 *randNums;
  u32 *randOps;
  u32 randNumsSize;
  u32 randOpsSize;
  u32 ops_limit;
  u32 use_kapi;
} CACHE_ALIGN;

Globals _gl;

const char const_random[] = "{uniform, zipf}";

struct ThreadStats {
  u64 num_ops;
  char pad_[CACHE_LINE - sizeof(u64)];
};

ThreadStats *stats;
ThreadStats *statsReads;
ThreadStats *fake;

inline void read_write_delay(u32 delay) {
  u32 sum = 0;	
  for (u32 i = 0; i < delay; ++i) {
    sum += _local_v[i].val;
    _local_v[i].val += sum + 1;
  }
}

inline void compute_delay(u32 delay) {
  for (u32 i = 0; i < delay; ++i) {
    PAUSE();
  }
}

static void initServer(u32 thrid, RedisServer *rs, u32 &argIndex) {
  for (u32 i = 0; i < _gl.param_initsize; ++i) {
    u32 val = _gl.randNums[argIndex++];
    if (argIndex >= _gl.randNumsSize) argIndex = 0;
    rs->ZADD(0, 1, val, val);
  }
}

static void runOP(u32 thrid, RedisServer *server, u32 &opIndex, u32 &argIndex) {
  u32 x;

  u32 op = _gl.randOps[opIndex++] % 100;
  if (opIndex >= _gl.randOpsSize) opIndex = 0;

  u32 key = _gl.randNums[argIndex++] % _gl.param_num_sets; 
  if (argIndex >= _gl.randNumsSize) argIndex = 0;
  u32 begin = _gl.randNums[argIndex++];
  if (argIndex >= _gl.randNumsSize) argIndex = 0;
  u32 end = _gl.randNums[argIndex++];
  if (argIndex >= _gl.randNumsSize) argIndex = 0;

  if (op < _gl.prob[0]) {
    // (thrid, key, score, val)
    server->ZADD(thrid, key, begin, end);
  } else if (op < _gl.prob[1]) {
    // (thrid, key, member)
    x = server->ZRANK(thrid, key, begin);
    fake[thrid].num_ops += x;   
  } else if (op < _gl.prob[2]) {
    // (thrid, key, start, stop)
    server->ZRANGE(thrid, key, begin, begin + end);
  } else {
    // (thrid, key, member)
    x = server->ZSCORE(thrid, key, begin);
    fake[thrid].num_ops += x;   
  }
}

void runThread(RedisServer *rs) {	
        u32 thrid = AtomicInc32(&(_gl.threadIds.val));

        u32 myRandNumIndex = thrid * 1024 % _gl.randNumsSize;
        u32 opIndex = thrid * 128 % _gl.randOpsSize;

        std::cout << "Thread " << thrid << std::endl;
        pinThread(thrid);

#if DO_RW_DELAY
        _local_v = new PaddedVolatileUInt[_gl.rw_delay.val];
#endif	

        initServer(thrid, rs, myRandNumIndex);
        AtomicInc32(&(_gl.pre_start_threads.val));
        while (_gl.pre_start_threads.val < _gl.threads);	
        AtomicInc32(&(_gl.start_threads.val));
        while (_gl.start_threads.val <= _gl.threads);	

        do {

          if (++stats[thrid].num_ops >= _gl.ops_limit)
            break;

          // Show periodic progress
          if (stats[thrid].num_ops % 500000 == 0)
            std::cout << "Thread " << thrid << ": num_ops= " << stats[thrid].num_ops 
                << "/" <<  _gl.ops_limit << std::endl;

          runOP(thrid, rs, opIndex, myRandNumIndex);

#if DO_RW_DELAY
          read_write_delay(_gl.rw_delay.val);
#endif

#if DO_COMPUTE_DELAY
          compute_delay(_gl.compute_delay.val);
#endif

        } while (!_gl.stop_threads.val);

}

void processArgs(int argc, char**argv) {
  _gl.threads = atoi(argv[ARG_THREADS_]);
  _gl.random = std::string(argv[ARG_RANDOM_]);	
  _gl.prob[PROB_ZADD_] = atoi(argv[ARG_PROB_ZADD_]);
  _gl.prob[PROB_ZRANK_] = _gl.prob[PROB_ZADD_] + atoi(argv[ARG_PROB_ZRANK_]);
  _gl.prob[PROB_ZRANGE_] = _gl.prob[PROB_ZRANK_] + atoi(argv[ARG_PROB_ZRANGE_]);
  _gl.param_capacity = atoi(argv[ARG_CAPACITY]);
  _gl.param_initsize = atoi(argv[ARG_INITSIZE]);
  _gl.param_num_sets = atoi(argv[ARG_NUM_SETS]);
  _gl.rw_delay.val = atoi(argv[ARG_RW_DELAY_]);
  _gl.compute_delay.val = atoi(argv[ARG_COMPUTE_DELAY_]);
  _gl.ops_limit = atoi(argv[ARG_OPS_LIMIT]);
  _gl.use_kapi = atoi(argv[ARG_USE_KAPI]);

  std::cout << std::endl << std::endl << "=====================================" << std::endl;
  std::cout << "Nrbench: Begin" << std::endl;
  std::cout << "Random: " << _gl.random.c_str() << std::endl;
  std::cout << "Threads: " << _gl.threads << std::endl;
  std::cout << "DataCapacity: " << _gl.param_capacity << std::endl;
  std::cout << "InitSize: " << _gl.param_initsize << std::endl;
  std::cout << "NumSets: " << _gl.param_num_sets << std::endl;

  std::cout << "ProbZADD: " << _gl.prob[PROB_ZADD_] << std::endl;
  std::cout << "ProbZRANK: " << _gl.prob[PROB_ZRANK_] - _gl.prob[PROB_ZADD_] << std::endl;
  std::cout << "ProbZRANGE: " << _gl.prob[PROB_ZRANGE_] - _gl.prob[PROB_ZRANK_] << std::endl;	
  std::cout << "ProbZSCORE: " << 100 - _gl.prob[PROB_ZRANGE_] << std::endl;	
  std::cout << "RWDelay: " << _gl.rw_delay.val << std::endl;
  std::cout << "ComputeDelay: " << _gl.compute_delay.val << std::endl;
  std::cout << "OpsLimit: " << _gl.ops_limit << std::endl;
  std::cout << "UseKAPI: " << _gl.use_kapi << std::endl;
}

void generateRandomOps(u32 size) {
  ZipfianGenerator zg(size, 0.0, size + 1024);
  zg.Init();

  _gl.randOpsSize = size;
  _gl.randOps = new u32[size];
  for (u32 index = 0; index < size; ++index) {
    _gl.randOps[index] = zg.GetIndex() % size;
  }
}

void generateRandomNums(u32 size, double order) {
  // use size as seed 
  // order = 0.0 is uniform distribution
  ZipfianGenerator zg(size, order, size);
  zg.Init();


  _gl.randNumsSize = size;
  _gl.randNums = new u32[size];
  // TRY_KAPI(kapi_fetch((unsigned long) _gl.randNums, size));
  // TRY_KAPI(kapi_pin((unsigned long) _gl.randNums, size, true));
  for (u32 index = 0; index < size; ++index) {
    _gl.randNums[index] = (zg.GetIndex() + _gl.param_initsize / 2 ) % size + 2;
  }
}

void runMain() {
  Timer tm;

  _gl.pre_start_threads.val = 0;
  _gl.start_threads.val = 0;
  _gl.stop_threads.val = 0;
  _gl.threadIds.val = 0;
  MEMBAR();

  RedisServer *rs = new RedisServer();

  // create threads
  std::thread *threads = new std::thread[_gl.threads];
  stats = new ThreadStats[_gl.threads];
  statsReads = new ThreadStats[_gl.threads];
  fake = new ThreadStats[_gl.threads];

  for (u32 id = 0; id < _gl.threads; ++id) {
    statsReads[id].num_ops = 0;
    stats[id].num_ops = 0;
    threads[id] = std::thread(runThread, rs);
  }


  // start threads
  AtomicInc32(&(_gl.start_threads.val));
  while (_gl.start_threads.val <= _gl.threads);

  tm.start();

  // threads will quit when op_limit operations per thread are complete

  for (u32 id = 0; id < _gl.threads; ++id) {
    threads[id].join();
  }
  tm.stop();


  /******* print stats ************/

  u64 num_ops = 0;
  u64 min_ops = stats[0].num_ops;
  u64 max_ops = stats[0].num_ops;

  std::cout << std::endl;
  std::cout << std::endl << "StatsWrites:" << std::endl;
  for (u32 id = 0; id < _gl.threads; ++id) {
    num_ops += stats[id].num_ops;
    if (stats[id].num_ops < min_ops && stats[id].num_ops > 0) min_ops = stats[id].num_ops;
    if (stats[id].num_ops > max_ops) max_ops = stats[id].num_ops;
    std::cout << stats[id].num_ops << " ";
  }

  std::cout << std::endl;
  std::cout << std::endl << "Tput(ops/ms): " << num_ops/tm.getElapsedMs() << std::endl;
  std::cout << std::endl << "NumOps: " << num_ops << std::endl;
  std::cout << std::endl << "MinOps: " << min_ops << std::endl;
  std::cout << std::endl << "MaxOps: " << max_ops << std::endl;
  std::cout << std::endl << "Fairness: " << (double)max_ops / (min_ops + 1) << std::endl;
  std::cout << "Time(ms): " << tm.getElapsedMs() << std::endl;
}

void usage(char *argv0) {
  std::cerr << "usage: " << argv0 << " <threads> <random> <prob_ZADD> <prob_ZRANK> <prob_ZRANGE> <capacity> <initsize> <num_sets> <rw_delay> <compute_delay> <ops_limit> <use_KAPI>" << std::endl;
  std::cerr << "<random> is one of " << const_random << std::endl;
}

/**********************************************
  Main
 ************************************************/

int main(int argc, char **argv) {
  // remove path from argv[0]
  char* argv0;
  argv0 = strrchr(argv[ARG_PROG_], '\\');
  if (argv0) ++argv0;
  else argv0 = argv[ARG_PROG_];

  if (argc != ARG_NUM_) {
    usage(argv0);
    exit(1);
  }

  processArgs(argc, argv);

  if (_gl.use_kapi) {
    ASSERT(init_kapi() == 0 && "Is memalloclib LD_PRELOADed?");
  }

  ASSERT(_gl.threads == 1 && "No support for multi-threading for now");
  
  pinThread(0);

  if (!_gl.random.compare("uniform")) {
    generateRandomNums(50*1024*1024, 0.0);
  } else if (!_gl.random.compare("zipf")) {
    generateRandomNums(50*1024*1024, 1.5);
  } else {
    std::cout << "[ERROR] Unrecognized <random> choice: " << _gl.random << ". Please use {uniform, zipf}" << std::endl;
    exit(1);
  }
  generateRandomOps(25*1024*1024);

  runMain();

  std::cout << "******************" << std::endl;
  return 0;
}

