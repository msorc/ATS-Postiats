//
// Implementing Ackermann's function
// Author: Hongwei Xi (May 10, 2013)
//

(* ****** ****** *)
//
// HX: this one involves run-time closure creation
//
(* ****** ****** *)

staload "prelude/DATS/integer.dats"

(* ****** ****** *)

//
// HX-2026-10: no GC
// the closures are linear (cloptr): each
// one is freed right after it is applied
//
staload UN = "prelude/SATS/unsafe.sats"
//
vtypedef cfun = (int) -<cloptr1> int
//
fun
cfun_app_free
(f: cfun, n: int): int = let
  val res = f (n)
  val () = cloptr_free ($UN.castvwtp0{cloptr(void)}(f))
in
  res
end // end of [cfun_app_free]
//
fun acker
  (m: int): cfun =
  lam (n) =<cloptr1>
  (
    if m <= 0 then n+1 else
    (
      if n <= 0
        then cfun_app_free (acker (m-1), 1)
        else cfun_app_free (acker (m-1), cfun_app_free (acker (m), n-1))
      // end of [if]
    ) // end of [if]
  ) (* end of [lam] *)
// end of [acker]

(* ****** ****** *)

implement
main0 () = let
//
val () = assertloc (cfun_app_free (acker(3), 3) = 61)
//
in
  // nothing
end // end of [main0]

(* ****** ****** *)

(* end of [acker3.dats] *)
