(* misc dynamic expressions: records, labelled tuples, sequences, $-forms, effects, exceptions, lazies, arrays, strings *)
#include "share/atspre_staload.hats"

val r = @{ a= 1, b= "x", c= 'c' }
val ra = r.a
val rb = r.b
val t = @(1, 2.0, "s")
val t0 = t.0
val t2 = t.2
val () = print "hello"
val () = println! ("a", 1, 'c', 2.0)
fun f (x: int): int = (print x; x + 1)
val x = $extfcall (int, "atoi", "3")
val y = $extval (int, "0")
val z = $UNSAFE.castvwtp0{ptr} (the_null_ptr)
fun eff (): int = $effmask_all (1)
fun eff2 (): int = $effmask_wrt (1)
fun eff3 (): void = $effmask_ntm (())
exception E1
exception E2 of (int, string)
fun raise2 (): int = $raise E1 ()
fun raise3 (x: int): int = try $raise E2 (x, "a") with | ~E2 (n, _) => n | ~E1 () => 0
val lz = $ldelay (1)
val () = lazy_vt_free (lz)
fun str (): string = "abc" + "def"
fun chr (): char = 'a'
fun flt (): double = 1.0e3
fun intl (): lint = 1L
fun uintl (): uint = 3U
val big = 12345678901234567890
val hex = 0xff
val neg = ~1
val str2 = "a\nb\t"
val strx = $mylocation
val fl = $showtype (r)
val sol = $solver_assert (())
fun tuprec (x: @{a=int, b=bool}): bool = x.b
fun lab (p: @(int, int)): int = case+ p of | @(a, b) => a + b
fun ann (x: int): int = (x: int)
fun ann2 (x: int): [n:int] int n = (x: [n:int] int n)
fun voidf (): void = ()
fun unitf (): () = ()
fun emptyseq (): void = ()
fun nest (): int = ((1; 2); 3)
val sq = (1; 2; 3)
val inc = let var i: int = 0 in (i := i + 1; i) end
val lt1 = (let val x = 1 in x end : int)
val lcast = $UNSAFE.cast{lint} (3)
val tmp = $tempenver (())
val ptr1 = the_null_ptr
val ptr2 = ptr_succ<int> (ptr1)
val arrp = $arrpsz{int} (1, 2, 3)
val arrb = (@[int](1,2,3))
val ltr = $list{int} (1, 2, 3)
val lvt = $list_vt{int} (1, 2, 3)
