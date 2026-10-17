(* at-views, pointers, addr@, view@, !p, p->field, :=, :=:, fold@/free@, arrays *)
#include "share/atspre_staload.hats"

fun swap_int (x: &int, y: &int): void = let
  val t = x
  val () = x := y
  val () = y := t
in end

fun xchg_int (x: &int, y: &int): void = (x :=: y)

fun incr {l:addr} (pf: !int @ l | p: ptr l): void = !p := !p + 1

fun get_set {l:addr} (pf: !int @ l | p: ptr l, v: int): int = let
  val old = !p
  val () = !p := v
in old end

fun xchg_ptr {l:addr} (pf: !int @ l | p: ptr l, v: int): int = let
  var x: int = v
  val () = !p :=: x
in x end

fun take {l:addr} (pf: int @ l | p: ptr l): (int @ l | int) = (pf | !p)

fun mk {l:addr} (pf: int? @ l | p: ptr l): (int @ l | void) = let
  val () = !p := 1
in (pf | ()) end

fun viewtest (): int = let
  var x: int = 1
  val p = addr@ x
  prval pf = view@ x
  val () = !p := 5
  prval () = view@ x := pf
in x end

typedef pt = @{ x= int, y= int }
fun setpt (p: &pt): void = (p.x := 1; p.y := 2)
fun getpt (p: &pt): int = p.x + p.y
fun ptr_pt {l:addr} (pf: !pt @ l | p: ptr l): int = p->x + p->y
fun ptr_pt_set {l:addr} (pf: !pt @ l | p: ptr l): void = (p->x := 3; p->y := 4)

typedef tup = @(int, bool, char)
fun tupf (t: &tup): int = t.0 + (if t.1 then 1 else 0)
fun tupset (t: &tup): void = (t.0 := 7; t.2 := 'a')

fun arr (): int = let
  var a = @[int][3](0)
  val () = a[0] := 1
  val () = a[1] := 2
in a[0] + a[1] end

fun arr2 (): int = let
  var a = @[int](1, 2, 3)
in a[2] end

fun nested (): int = let
  var r: @{ a= @(int, int), b= int } = @{ a= @(1, 2), b= 3 }
  val () = r.a.0 := 10
in r.a.0 + r.b end

fun dyn_deref (r: ptr): int = $UNSAFE.ptr0_get<int> (r)
fun pfold {l:addr} (pf: !int @ l | p: ptr l): void = let
  prval pf1 = pf
  prval () = pf := pf1
in end

dataview myv (addr, int) =
  | myv_nil (null, 0)
  | {l:agz} {n:nat} myv_cons (l, n+1) of (int @ l, myv (l, n))

fun vwith {l:addr} (pf: !int @ l | p: ptr l): int = let
  val x = ptr_get<int> (pf | p)
  val () = ptr_set<int> (pf | p, x + 1)
in x end

fun vexch {l:addr} (pf: !int @ l | p: ptr l): int = ptr_exch<int> (pf | p, 3)
