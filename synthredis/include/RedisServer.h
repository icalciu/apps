#ifndef __REDIS_SERVER_H__
#define __REDIS_SERVER_H__

#include "util.h"

/* Sequential data structures */
#include "SeqHashmap.h"
#include "SeqSkipList.h"


class RedisServer {
private: 
  SeqHashmap *hm;
  SeqSkipList *skp;

public:

  RedisServer() {
    hm = new SeqHashmap(); 
    skp = new SeqSkipList();
  }

  void initServer(u32 initsize) {
  }

  void ZADD(u32 thrid, u32 key, u32 score, u32 val) {
    hm->Add(val, score);
    skp->Add(val, score);
  }
  
  u32 ZRANK(u32 thrid, u32 key, u32 member) {
    if (hm->Contain(member)) {
      u32 rank = skp->GetRank(member);
      //printf("get rank %u rank %u\n", member, rank);
      return rank;
    }
    return 0;
  }

  void ZRANGE(u32 thrid, u32 key, u32 start, u32 end) {
    // TODO
  }

  u32 ZSCORE(u32 thrid, u32 key, u32 member) {
    return hm->Contain(member);
  }

};

#endif  // __REDIS_SERVER_H__
