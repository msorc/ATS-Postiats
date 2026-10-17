(* ****** ****** *)
//
// For processing
// .atxt file in prelude/DATS
//
(* ****** ****** *)
//
// Author: Hongwei Xi
// Authoremail: gmhwxiATgmailDOTcom
//
(* ****** ****** *)
//
staload
_(*anon*) = "prelude/DATS/list_vt.dats"
//
(* ****** ****** *)
//
fun
g0int_implist
(
  knm: string
, tnm: string, tnm2: string
) : atext = let
//
fun
fopr (
  opr: string
) : atext = let
//
val x = sprintf
("\
implement
g0int_%s<%s> = g0int_%s_%s\n\
", @(opr, knm, opr, tnm)
) (* end of [val] *)
//
in
  atext_strptr (x)
end // end of [fopr]
//
fun
fprnt (
// argless
) : atext = let
//
val x = sprintf
("\
implement
fprint_val<%s> (out, x) = fprint_%s (out, x)\
",
@(
tnm2, tnm
)
)
in
  atext_strptr (x)
end // end of [fprnt]
//
var
res: atextlst = glist_nil()
//
val () = res := glist_cons(fopr"neg", res)
val () = res := glist_cons(fopr"abs", res)
//
val () = res := glist_cons(fopr"succ", res)
val () = res := glist_cons(fopr"pred", res)
//
val () = res := glist_cons(fopr"half", res)
//
val () = res := glist_cons(fopr"add", res)
val () = res := glist_cons(fopr"sub", res)
val () = res := glist_cons(fopr"mul", res)
val () = res := glist_cons(fopr"div", res)
val () = res := glist_cons(fopr"mod", res)
//
val () = res := glist_cons(fopr"asl", res)
val () = res := glist_cons(fopr"asr", res)
//
val () = res := glist_cons(fopr"isltz", res)
val () = res := glist_cons(fopr"isltez", res)
val () = res := glist_cons(fopr"isgtz", res)
val () = res := glist_cons(fopr"isgtez", res)
val () = res := glist_cons(fopr"iseqz", res)
val () = res := glist_cons(fopr"isneqz", res)
//
val () = res := glist_cons(fopr"lt", res)
val () = res := glist_cons(fopr"lte", res)
val () = res := glist_cons(fopr"gt", res)
val () = res := glist_cons(fopr"gte", res)
val () = res := glist_cons(fopr"eq", res)
val () = res := glist_cons(fopr"neq", res)
//
val () = res := glist_cons(fopr"compare", res)
//
val () = res := glist_cons(fopr"max", res)
val () = res := glist_cons(fopr"min", res)
//
val () = res := glist_cons(atext_strcst("//\n"), res)
//
val () = res := glist_cons(fprnt((*void*)), res)
//
in
  atext_concatxt(glist_reverse(res))
end // end of [g0int_implist]
//
fun
g0sint_implist
(
  knm: string
, tnm: string, tnm2: string
) : atext = g0int_implist(knm, tnm, tnm2)
//
(* ****** ****** *)
//
fun
g1int_implist
(
  knm: string
, tnm: string, tnm2: string
) : atext = let
//
fun
fopr
(
  opr: string
) : atext = let
//
val x = sprintf
("\
implement
g1int_%s<%s> = g1int_%s_%s\n\
", @(opr, knm, opr, tnm)
) (* end of [val] *)
//
in
  atext_strptr (x)
end // end of [fopr]
//
var
res: atextlst = glist_nil()
//
val () = res := glist_cons(fopr"neg", res)
val () = res := glist_cons(fopr"abs", res)
//
val () = res := glist_cons(fopr"succ", res)
val () = res := glist_cons(fopr"pred", res)
//
val () = res := glist_cons(fopr"half", res)
//
val () = res := glist_cons(fopr"add", res)
val () = res := glist_cons(fopr"sub", res)
val () = res := glist_cons(fopr"mul", res)
val () = res := glist_cons(fopr"div", res)
(*
val () = res := glist_cons(fopr"mod", res) // HX: skipped
*)
val () = res := glist_cons(fopr"nmod", res)
//
val () = res := glist_cons(fopr"isltz", res)
val () = res := glist_cons(fopr"isltez", res)
val () = res := glist_cons(fopr"isgtz", res)
val () = res := glist_cons(fopr"isgtez", res)
val () = res := glist_cons(fopr"iseqz", res)
val () = res := glist_cons(fopr"isneqz", res)
//
val () = res := glist_cons(fopr"lt", res)
val () = res := glist_cons(fopr"lte", res)
val () = res := glist_cons(fopr"gt", res)
val () = res := glist_cons(fopr"gte", res)
val () = res := glist_cons(fopr"eq", res)
val () = res := glist_cons(fopr"neq", res)
//
val () = res := glist_cons(fopr"compare", res)
//
val () = res := glist_cons(fopr"max", res)
val () = res := glist_cons(fopr"min", res)
//
in
  atext_concatxt(glist_reverse(res))
end // end of [g1int_implist]
//
(* ****** ****** *)
//
fun
g0uint_implist
(
  knm: string
, tnm: string, tnm2: string
) : atext = let
//
fun
fopr
(
  opr: string
) : atext = let
//
val x = sprintf
("\
implement
g0uint_%s<%s> = g0uint_%s_%s\n\
", @(opr, knm, opr, tnm)
) // end of [val]
//
in
  atext_strptr (x)
end // end of [f]
//
fun
fprnt (
// argless
): atext = let
//
val x = sprintf
("\
implement
fprint_val<%s> (out, x) = fprint_%s (out, x)\
", 
@(
tnm2, tnm
)
) // end of [val]
//
in
  atext_strptr (x)
end // end of [fpr]
//
var
res: atextlst = glist_nil()
//
val () = res := glist_cons(fopr"succ", res)
val () = res := glist_cons(fopr"pred", res)
//
val () = res := glist_cons(fopr"half", res)
//
val () = res := glist_cons(fopr"add", res)
val () = res := glist_cons(fopr"sub", res)
val () = res := glist_cons(fopr"mul", res)
val () = res := glist_cons(fopr"div", res)
val () = res := glist_cons(fopr"mod", res)
//
val () = res := glist_cons(fopr"lsl", res)
val () = res := glist_cons(fopr"lsr", res)
//
val () = res := glist_cons(fopr"lnot", res)
val () = res := glist_cons(fopr"lor", res)
val () = res := glist_cons(fopr"lxor", res)
val () = res := glist_cons(fopr"land", res)
//
val () = res := glist_cons(fopr"isgtz", res)
val () = res := glist_cons(fopr"iseqz", res)
val () = res := glist_cons(fopr"isneqz", res)
//
val () = res := glist_cons(fopr"lt", res)
val () = res := glist_cons(fopr"lte", res)
val () = res := glist_cons(fopr"gt", res)
val () = res := glist_cons(fopr"gte", res)
val () = res := glist_cons(fopr"eq", res)
val () = res := glist_cons(fopr"neq", res)
//
val () = res := glist_cons(fopr"compare", res)
//
val () = res := glist_cons(fopr"max", res)
val () = res := glist_cons(fopr"min", res)
//
val () = res := glist_cons(atext_strcst("//\n"), res)
//
val () = res := glist_cons(fprnt((*void*)), res)
//
in
  atext_concatxt(glist_reverse(res))
end // end of [g0uint_implist]
//
(* ****** ****** *)
//
fun
g1uint_implist
(
  knm: string
, tnm: string, tnm2: string
) : atext = let
//
fun
fopr (
  opr: string
) : atext = let
//
val
res =
sprintf
("\
implement
g1uint_%s<%s> = g1uint_%s_%s\n\
", @(opr, knm, opr, tnm)
) (* end of [val] *)
//
in
  atext_strptr(res)
end // end of [fopr]
//
var
res: atextlst = glist_nil((*void*))
//
val () = res := glist_cons(fopr"succ", res)
val () = res := glist_cons(fopr"pred", res)
//
val () = res := glist_cons(fopr"half", res)
//
val () = res := glist_cons(fopr"add", res)
val () = res := glist_cons(fopr"sub", res)
val () = res := glist_cons(fopr"mul", res)
val () = res := glist_cons(fopr"div", res)
val () = res := glist_cons(fopr"mod", res)
//
(*
val () = res := glist_cons(fopr"mod", res) // HX: skipped
*)
//
val () = res := glist_cons(fopr"isgtz", res)
val () = res := glist_cons(fopr"iseqz", res)
val () = res := glist_cons(fopr"isneqz", res)
//
val () = res := glist_cons(fopr"lt", res)
val () = res := glist_cons(fopr"lte", res)
val () = res := glist_cons(fopr"gt", res)
val () = res := glist_cons(fopr"gte", res)
val () = res := glist_cons(fopr"eq", res)
val () = res := glist_cons(fopr"neq", res)
//
val () = res := glist_cons(fopr"compare", res)
//
val () = res := glist_cons(fopr"max", res)
val () = res := glist_cons(fopr"min", res)
//
in
  atext_concatxt(glist_reverse(res))
end // end of [g1uint_implist]
//
fun
g1sint_implist
(
  knm: string
, tnm: string, tnm2: string
) : atext = g1int_implist(knm, tnm, tnm2)
//
(* ****** ****** *)

(* end of [prelude_DATS_atext.hats] *)
