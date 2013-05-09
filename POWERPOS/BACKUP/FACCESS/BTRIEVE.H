
#define TRUE      1
#define FALSE     0

#define B_STR_TYPE   (char) 0x0
#define B_CMP_EQUAL  1
#define B_CMP_NOTEQ  4
#define B_LOGIC_OR   2
#define B_LOGIC_END  0

#define B_OPEN       0
#define B_CLOSE      1
#define B_INSERT     2
#define B_UPDATE     3
#define B_DELETE     4
#define B_GETEQ      5
#define B_GETNEXT    6
#define B_GETPREV    7
#define B_GETGR      8
#define B_GETGE      9
#define B_GETFIRST  12
#define B_GETLAST   13
#define B_CREATE    14
#define B_GETPOSI   22
#define B_DIRECT    23
#define B_GETNX_EXT 36


int BTRV(int, char *, char *, int *, char *, int);

struct KeySpecType  {
	 int    keyPos;
	 int    keyLen;
	 int    keyFlag;
	 char   notUsed[4];
	 char   keyType;
	 char   reserve[5];
};

typedef struct {
	 int    recordLength;
	 int    pageSize;
	 int    indexCount;
	 char   notUsed[4];
	 int    fileFlags;
	 char   reserve2[2];
	 int    preAlloc;
	 struct KeySpecType keySpecBuf;  /* We will use one key */
} FileSpecType;



