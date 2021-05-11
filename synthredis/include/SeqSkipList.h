#ifndef __SEQ_SKIP_LIST__
#define __SEQ_SKIP_LIST__

// Sequential Skiplist (1 thread only -- not thread-safe)

#include <climits>

#include "util.h"
#include "prng.h"

#include <kapi.h>

#define _MAX_LEVEL     20
#define _EMPTY_VALUE   0
#define _NULL_VALUE   _EMPTY_VALUE

class SeqSkipList { 
protected:

	class Node {
	public:
		u32		_key;
    u32   _val;
		u32		_top_level;
		u32		_counter;
		Node* 	_next[_MAX_LEVEL+1];
		
	};

	Node*			_head;
	Node* 		_tail;
	Node* 		_fhead;
	Prng      _prng;

	u32 _not_found;
	u32 _duplicates;
	
	inline u32 randomLevel() {		
		u32 x = _prng.next();
		if ((x & 0x80000001) != 0) {// test highest and lowest bits
			return 1;
		}
		u32 level = 2;
		while (((x >>= 1) & 1) != 0)
			++level;
		if (level > (_MAX_LEVEL - 1))
			return (_MAX_LEVEL - 1);
		else
			return level;
	}

	Node* getNewNodeInit(const u32 inKey) {		
		Node* const new_node = new Node();
		new_node->_key = inKey;
		new_node->_top_level = _MAX_LEVEL;
		new_node->_counter = 1;
		return new_node;
	}

	Node* getNewNode(const u32 inKey, const u32 value, const u32 height) {		
//		Node* const new_node = new Node();
		Node* const new_node = allocateNode();
		new_node->_key = inKey;
    new_node->_val = value;
		new_node->_top_level = height;
		new_node->_counter = 1;
		return new_node;
	}

	inline Node* find(const u32 key, Node **preds, Node **succs) {		
		Node* pPred;
		Node* pCurr;
		pPred = _head;
		Node* found_node = _tail;

		for (i32 iLevel = _MAX_LEVEL-1; iLevel >= 0; --iLevel) {

			pCurr = pPred->_next[iLevel];

			TRY_KAPI(kapi_fetch((unsigned long) pCurr, 1));
			while (key > pCurr->_key) {			

				pPred = pCurr; 
				pCurr = pPred->_next[iLevel];
				static int count = 0;
				count += TRY_KAPI(kapi_fetch((unsigned long) pCurr, 1));
			}
			
			if (key == pCurr->_key) {
				found_node = pCurr;
			}

			preds[iLevel] = pPred;
			succs[iLevel] = pCurr;
		}

		return found_node;
	}

public:

	SeqSkipList():_not_found(0), _duplicates(0) {		
		KWRITE(_head, getNewNodeInit(0));
		KWRITE(_tail, getNewNodeInit(UINT32_MAX));

		_fhead = NULL;
#if 1 
		for (int i = 0; i < 10000000; ++i) {
			Node *node = new Node();
			node->_next[0] = _fhead;
			_fhead = node;
		}
#endif		
		//initialize head to point to tail .....................................
		for (u32 iLevel = 0; iLevel < _head->_top_level; ++iLevel)
			_head->_next[iLevel] = _tail;
		
	}

	~SeqSkipList() { }

	inline void deleteNode(Node *node) {
		node->_next[0] = _fhead;
		_fhead = node;
	}

	inline Node* allocateNode() {
		Node *node;
		if (_fhead) {
			node = _fhead;
			_fhead = _fhead->_next[0];
			node->_next[0] = NULL;
		}
		else {
			node = new Node();			
		}
		return node;
	}

public:
	
	bool Add(u32 key, u32 value) {			

		Node* preds[_MAX_LEVEL + 1];
		Node* succs[_MAX_LEVEL + 1];
		Node* node_found = find(key, preds, succs);

#if defined (USE_SKIPLIST_COUNTERS)
		if (KREAD(_tail) != node_found) {
			++(node_found->_counter);
			return true;
		}
		else {	
#elif defined (SKIPLIST_NO_DUPLICATES)
		if (KREAD(_tail) != node_found) {		
			++_duplicates;
			return true;
		}
		else {
#endif

				const u32 top_level = randomLevel();

				/* first link succs 
				   then link next fields of preds */
				Node* new_node = getNewNode(key, value, top_level);
				Node** new_node_next = new_node->_next;
				Node** curr_succ = succs;
				Node** curr_preds = preds;

				for (u32 level = 0; level < top_level; ++level) {
					*new_node_next = *curr_succ;
					(*curr_preds)->_next[level] = new_node;
					++new_node_next;
					++curr_succ;
					++curr_preds;
				}
				return true;
#if defined (USE_SKIPLIST_COUNTERS)
			}
#elif defined (SKIPLIST_NO_DUPLICATES)
		}
#endif
	}
		
	u32 Remove(u32 inValue) {   
		u32 key = inValue;

		Node* preds[_MAX_LEVEL + 1];
		Node* succs[_MAX_LEVEL + 1];

		while (true) {
			Node* node_found = find(key, preds, succs);			
			if (_tail != node_found) {
				key = node_found->_key;
				--(node_found->_counter);

				if (0 == node_found->_counter) {

					/* preds and succs are set in the find method */
					for (u32 level = 0; level < node_found->_top_level; ++level) {
						preds[level]->_next[level] = node_found->_next[level];
					}

					deleteNode(node_found);
					
				}
				return key;
			}
			else {							
					++_not_found;
					return inValue;
			}			
		}
	}

	//peek ......................................................................
	u32 Contain(u32 inValue) {					
		Node* pPred;
		Node* pCurr;
		pPred = _head;

		for (i32 iLevel = _MAX_LEVEL - 1; iLevel >= 0; --iLevel) {

			pCurr = pPred->_next[iLevel];

			while (inValue > pCurr->_key) {

				pPred = pCurr;
				pCurr = pPred->_next[iLevel];
			}

			if (inValue == pCurr->_key) {
				return inValue;
			}
		}
				
		return _NULL_VALUE;
	}

	u32 GetRank(u32 key) {					
		Node* pCurr = _head;

    u32 rank = 0;
    while(pCurr != _tail) { 
      pCurr = pCurr->_next[0];
      rank++;
      if (pCurr->_key == key) return rank;
    }
    return rank;
	}

public:

	u32 Size() {
		u32 size = 0;
		u32 buckets = 0;
		Node *curr = _head->_next[0];
//		printf("%d %d\n ", _head->_top_level, _tail->_top_level);

//		int levels[_MAX_LEVEL];
//		memset(&levels, 0, sizeof(levels));


		while (curr != _tail) {
			//printf("%p %d %d %d %d %d %d\n", curr, curr->_key, curr->_counter, curr->_top_level, curr->_next[0]->_key, curr->_next[1]->_key, curr->_next[2]->_key);
			//if (curr->_top_level > 6) printf("%d ", curr->_top_level);
			//levels[curr->_top_level]++;

			//printf("%d ", curr->_key);

			size += curr->_counter;
			buckets++;
			curr = curr->_next[0];
		}

//		for (int i = 0; i < _MAX_LEVEL; ++i) {
//			printf("level %d %d\n", i, levels[i]);
//		}

		//printf("SeqSkipList size %d buckets %d\n", _size, buckets);
		printf("Not found %d\n", _not_found);
		printf("Duplicates %d\n", _duplicates);

		return size;
	}

	const char* Name() {
		return "SeqSkipList";
	}

};

#endif
