(* view@ and view@ := : success paths, labels, context errors, address mismatch, non-pointers, addressless linear variables *)
#include "share/atspre_staload.hats"

typedef rcd = @{ a= int, b= int }
typedef rcd2 = @{ r= rcd, c= bool }
datavtype dvt = DVT of (int)

fun vw1 (): int = let
  var r: rcd = @{ a= 1, b= 2 }
  prval pf = view@ r.a
  prval () = view@ r.a := pf
in r.a end

fun vw2 (): int = let
  var r: rcd2 = @{ r= @{ a= 1, b= 2 }, c= true }
  prval pf = view@ r.r.b
  prval () = view@ r.r.b := pf
in r.r.b end

(* context cannot be formed *)
fun vwe1 (): int = let
  var r: rcd = @{ a= 1, b= 2 }
  prval pf = view@ r.zzz
in 0 end

fun vwe2 (): int = let
  var x: int = 1
  prval pf = view@ x.a
in 0 end

fun vwe3 (): int = let
  var r: rcd = @{ a= 1, b= 2 }
  prval () = view@ r.zzz := (view@ r.a)
in 0 end

(* deref *)
fun vd1 {l:addr} (pf: int @ l | p: ptr l): (int @ l | void) = let
  prval pf1 = view@ (!p)
in (pf1 | ()) end

fun vd2 {l:addr} (pf: rcd @ l | p: ptr l): (rcd @ l | void) = let
  prval pf1 = view@ (p->a)
in (pf1 | ()) end

fun vd3 {l:addr} (pf: !int @ l | p: ptr l): void = let
  prval pf1 = view@ (!p)
  prval () = view@ (!p) := pf1
in end

fun vd4 {l:addr} (pf: !rcd @ l | p: ptr l): void = let
  prval pf1 = view@ (p->b)
  prval () = view@ (p->b) := pf1
in end

fun vd5 {l:addr} (p: ptr l): void = let
  prval pf1 = view@ (!p)
in end

fun vd6 {l:addr} (p: ptr l, pf: int @ l): void = let
  prval () = view@ (!p) := pf
in end

fun vd7 (x: int): void = let
  prval pf1 = view@ (!x)
in end

fun vd8 (x: int, pf: int @ null): void = let
  prval () = view@ (!x) := pf
in end

fun vd9 {l:addr} (pf: !rcd @ l | p: ptr l): void = let
  prval pf1 = view@ (p->zzz)
in end

(* address mismatch, non-atview, non-without *)
fun vm1 {l1,l2:addr} (pf1: int @ l1, pf2: int @ l2 | p: ptr l1, q: ptr l2): void = let
  prval pf = view@ (!p)
  prval () = view@ (!q) := pf
in end

fun vm2 (): void = let
  var x: int = 1
  var y: int = 2
  prval pfx = view@ x
  prval () = view@ y := pfx
in end

fun vm3 (): void = let
  var x: int = 1
  prval () = view@ x := (view@ x)
in end

fun vm4 (): void = let
  var x: int = 1
  prval () = view@ x := 3
in end

fun vm5 {l:addr} (pf: int @ l | p: ptr l): void = let
  prval () = view@ (!p) := pf
in end

fun vm6 {l:addr} (pf: int @ l | p: ptr l): void = let
  prval () = view@ (!p) := (view@ (!p))
in end

(* addressless linear / non-lvalue *)
fun vl1 (x: dvt): void = let
  prval pf = view@ x
in free x end

fun vl2 (x: dvt, pf: int @ null): void = let
  prval () = view@ x := pf
in free x end

fun vn1 (): void = let
  prval pf = view@ (1+2)
in end

fun vn2 (pf: int @ null): void = let
  prval () = view@ (1+2) := pf
in end

fun vn3 (x: int): void = let
  prval pf = view@ x
in end

fun vn4 (x: int, pf: int @ null): void = let
  prval () = view@ x := pf
in end
