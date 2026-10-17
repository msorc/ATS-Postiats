#include "share/atspre_staload.hats"
#ifdef FOO
#define V 1
#else
#define V 2
#endif
#if (V=1)
implement main0 () = println! ("foo")
#else
implement main0 () = println! ("nofoo")
#endif
val z = FOO
