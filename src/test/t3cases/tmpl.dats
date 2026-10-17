(* templates, overloading, symbols, implement, extern, macros *)
#include "share/atspre_staload.hats"

extern fun {a:t@ype} show (x: a): string
implement show<int> (x) = "int"
implement show<bool> (x) = "bool"
implement {a} show (x) = "any"

extern fun {a,b:t@ype} conv (x: a): b
implement conv<int,double> (x) = g0int2float_int_double (x)

fun {a:t@ype} twice (x: a, f: (a) -> a): a = f (f (x))
val t1 = twice<int> (1, lam (x) => x + 1)
val t2 = twice (2, lam (x: int): int => x * 2)

fun {a:t@ype} swap (p: @(a, a)): @(a, a) = @(p.1, p.0)
val s1 = swap<int> (@(1, 2))
val s2 = swap (@(true, false))

fun {a:vt@ype} dummy (x: a): a = x

symintr foo
extern fun foo1 (x: int): int
extern fun foo2 (x: int, y: int): int
overload foo with foo1
overload foo with foo2
implement foo1 (x) = x
implement foo2 (x, y) = x + y
val o1 = foo (1)
val o2 = foo (1, 2)

symintr bar
extern fun bar_i (x: int): int
extern fun bar_b (x: bool): bool
overload bar with bar_i
overload bar with bar_b
implement bar_i (x) = x
implement bar_b (x) = x
val b1 = bar (3)
val b2 = bar (true)

val c1 = 1 + 2 * 3 - 4
val c2 = 1.0 + 2.5 * 3.0
val c3 = 1 < 2 && 2 <= 3 || 3 > 4
val c4 = (1 = 1) && (1 != 2)
val c5 = ~1 + abs (~3)
val c6 = 'a' < 'b'
val c7 = "abc" < "abd"
val c8 = 1 + 2.0
val c9 = g0int_add (1, 2)
val c10 = 3 mod 2 + 3 / 2
val c11 = max (1, 2) + min (3, 4)
val c12 = ptr_is_null (the_null_ptr)
val c13 = $UNSAFE.cast{int} (3.0)
val c14 = sizeof<int>

macdef mymac (x) = ,(x) + 1
val m1 = mymac (3)
#define TWO 2
val m2 = TWO + 1
#if 1
val m3 = 1
#else
val m3 = 2
#endif

extern fun {a:t@ype} lst (x: a): List0_vt (a)
implement {a} lst (x) = list_vt_cons (x, list_vt_nil ())
val l1 = lst<int> (1)
val () = list_vt_free<int> (l1)

stadef mysz = 3
fun tmpuse (): int = let
  val x = show<int> (3)
  val y = show<bool> (true)
  val z = show<char> ('a')
in 0 end
extern fun {a:t@ype} g (): a
implement g<int> () = 0
fun gg (): int = g<int> ()
fun gbad (): bool = g<bool> ()
