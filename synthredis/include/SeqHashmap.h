#ifndef __SEQ_HASHMAP__
#define __SEQ_HASHMAP__

// Sequential Hashmap (1 thread only -- not thread-safe)


#include "hashmap/HashMap.h"
#include "hashmap/KeyHash.h"

#define _TSIZE 100000
#define _EMPTY_VALUE   0
#define _NULL_VALUE   _EMPTY_VALUE

class SeqHashmap { 
protected:
  HashMap<u32, u32, _TSIZE, KeyHash<u32, _TSIZE> > storage; 

public:

	SeqHashmap() {		
	}

	~SeqHashmap() { }

public:
	
	bool Add(u32 key, u32 value) {			
    storage.put(key, value);
    return true;
	}
		
	u32 Remove(u32 inValue) {   
    u32 key = inValue;
    storage.remove(key);
    return key;
	}

	u32 Contain(u32 key) {
    u32 value = _NULL_VALUE;					
    bool result = storage.get(key, value);
    if (result) return value;
    else return _NULL_VALUE;
	}

public:

	u32 Size() {
    return 0;
	}

	const char* Name() {
		return "SeqHashmap";
	}

};

#endif
