(* #define, #if and friends *)
#define N 10
#define M (N + 1)
#define STR "abc"
#define STR2 STR + "def"
#define F(x) (x * 2)
#define G(x, y) (if x > y then x else y)
#define H1 F(N)
#define CH 'a'
#define FLT 1.5
#define NONE
#undef M
#define M2 (N + 2)
#if N > 5
val a = N
#else
val a = 0
#endif
#if (N > 100)
val b = 1
#elif N > 7
val b = 2
#else
val b = 3
#endif
#ifdef N
val c = 1
#endif
#ifndef N
val c = 0
#endif
#ifdef UNDEFINED
val d1 = 0
#else
val d1 = 1
#endif
#if defined(M)
val e = 1
#else
val e = 2
#endif
#if N >= 10 && N <= 10 || N == 0
val f = 1
#endif
#assert (N == 10)
#print "hello\n"
#print N
#print "\n"
#print STR2
#print "\n"
#print F(3)
#print "\n"
#print G(3, 4)
#print "\n"
#print CH
#print "\n"
#print FLT
#print "\n"
#prerr "prerr\n"
#if N > 5 #then
val g = 1
#endif
#define ATS_PACKNAME "mypack"
#define ATS_DYNLOADFLAG 0
#define ATS_DYNLOADNAME "myload"
#define ATS_STATIC_PREFIX "myprefix_"
#define ATS_MAINATSFLAG 1
#define ATS_EXTERN_PREFIX "extprfx_"
extern fun foo(): int = "ext#%"
extern fun foo2(): int = "mac#%foo2name"
val x = N + 1 + M2
#if (1 + 2) * 3 - 4 / 2 == 7
val y = 1
#endif
#if "a" + "b" == "ab"
val z = 1
#endif
