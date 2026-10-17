(*
** HX-2026-10: no GC
** Helpers shared by the .dats files of pats_constraint3* (#include it after "libats/SATS/arena.sats",
** "prelude/SATS/unsafe.sats", pats_staexp2.sats, pats_constraint3.sats and pats_error.dats).
** See PORTING.md, "Constraint solving (constraint3)".
*)
//
#define l2l glist_make_list_vt
//
fn{a:t@ype}
glist_is_pair (xs: glist(a)): bool =
  if glist_is_cons (xs) then glist_is_cons (glist_tail<a> (xs)) else false
//
fn{a:t@ype}
glist_pair (x1: a, x2: a): glist(a) = glist_cons<a> (x1, glist_sing<a> (x2))
//
// the payload of a node known to have a given constructor
//
fn un_S3Eicff (x: s3exp): @(intinf, s3exp) =
  case+ s3exp_view (x) of
  | ~S3Eicff (c, x1) => @(c, x1)
  | v => (s3exp_view_free (v); $ERR.abort_interr<@(intinf, s3exp)> ())
fn un_S3Eisum (x: s3exp): s3explst =
  case+ s3exp_view (x) of
  | ~S3Eisum (xs) => xs
  | v => (s3exp_view_free (v); $ERR.abort_interr<s3explst> ())
fn un_S3Evar (x: s3exp): s2var =
  case+ s3exp_view (x) of
  | ~S3Evar (s2v) => s2v
  | v => (s3exp_view_free (v); $ERR.abort_interr<s2var> ())
fn un_S3Eiatm (x: s3exp): s2varmset =
  case+ s3exp_view (x) of
  | ~S3Eiatm (s2vs) => s2vs
  | v => (s3exp_view_free (v); $ERR.abort_interr<s2varmset> ())
//
(* end of [pats_constraint3.hats] *)
