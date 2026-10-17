(* ****** ****** *)
//
// HX-2026-10: no GC. Helpers shared by the pats_typerase_*.dats files
// (include this file after the staload of the arena and of [UN]).
// See PORTING.md, "Type erasure (typerase)".
//
(* ****** ****** *)

staload ERR = "./pats_error.sats"
staload _(*ERR*) = "./pats_error.dats"

(* ****** ****** *)
//
// HX: [val-list_cons (x, xs) = xs] of ATS1 is the MatchError of an empty list
//
fn{a:t@ype}
glist_head_exn (xs: glist(a)): a =
  if glist_is_cons (xs) then glist_head<a> (xs) else $ERR.abort_interr<a> ((*MatchError*))
//
fn{a:t@ype}
glist_tail_exn (xs: glist(a)): glist(a) =
  if glist_is_cons (xs) then glist_tail<a> (xs) else $ERR.abort_interr<glist(a)> ((*MatchError*))
//
(* ****** ****** *)

(* end of [pats_typerase.hats] *)
