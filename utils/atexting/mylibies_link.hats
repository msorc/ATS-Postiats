(* ****** ****** *)
//
// HX-2016-02-16
//
(* ****** ****** *)
//
// For downstream linking
//
(* ****** ****** *)
//
#define
ATS_MAINATSFLAG 1
//
(* ****** ****** *)
//
#define
ATS_DYNLOADNAME
"atexting_all_dynload"
//
(* ****** ****** *)
//
local
#include "./DATS/atexting_mylib.dats"
in (*nothing*) end
//
(* ****** ****** *)
//
// HX-2026-10: the arena encoding of the syntax
//
local
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload "./SATS/atexting.sats"
in
#include "./DATS/atexting_gen.hats"
#include "./DATS/atexting_def_gen.hats"
end // end of [local]
//
(* ****** ****** *)
//
local
#include "./DATS/atexting_fname.dats"
in (*nothing*) end
local
#include "./DATS/atexting_posloc.dats"
in (*nothing*) end
//
local
#include "./DATS/atexting_token.dats"
in (*nothing*) end
local
#include "./DATS/atexting_atext.dats"
in (*nothing*) end
//
local
#include "./DATS/atexting_parerr.dats"
in (*nothing*) end
//
local
#include "./DATS/atexting_lexbuf.dats"
in (*nothing*) end
local
#include "./DATS/atexting_lexing.dats"
in (*nothing*) end
//
local
#include "./DATS/atexting_tokbuf.dats"
in (*nothing*) end
//
local
#include "./DATS/atexting_global.dats"
in (*nothing*) end
//
local
#include "./DATS/atexting_textdef.dats"
in (*nothing*) end
//
local
#include "./DATS/atexting_parsing.dats"
in (*nothing*) end
//
local
#include "./DATS/atexting_strngfy.dats"
in (*nothing*) end
local
#include "./DATS/atexting_topeval.dats"
in (*nothing*) end
//
local
#include "./DATS/atexting_commarg.dats"
in (*nothing*) end
//
(* ****** ****** *)
//
staload
"prelude/DATS/integer.dats"
staload
"prelude/DATS/filebas.dats"
// HX-2026-10: (for the arena templates)
#include "share/atspre_staload.hats"
//
(* ****** ****** *)
//
staload
"libats/libc/SATS/stdio.sats"  
//
(* ****** ****** *)
//
// HX-2026-10: no GC (flat)
// 0: OUTCHANref; 1: OUTCHANptr
//
typedef
outchan = @(int, FILEref)
//
(* ****** ****** *)

fun
outchan_get_fileref
  (x0: outchan): FILEref =
(
//
x0.1
//
) // outchan_get_fileref

(* ****** ****** *)

fun
outchan_close(x0: outchan): void =
(
//
if x0.0 > 0 then fclose0_exn(x0.1)
//
) (* end of [outchan_close] *)

(* ****** ****** *)
//
#ifdef
MAIN_NONE
#then
//
// HX:
// the [main] is
// to be implemented
//
(*
#print
"MAIN_NONE defined!"
*)
//
#else
//
local
//
staload "./SATS/atexting.sats"
staload "libats/SATS/arena.sats" // HX-2026-10
staload _ = "libats/DATS/arena.dats"
//
typedef
cmdstate = @{
//
cmdname= commarg
//
(*
, inpfil=filename
*)
//
, outmode= fmode
, outchan= outchan
//
} (* end of [cmdstate] *)

(* ****** ****** *)

fun
atexting_usage
(
  out: FILEref, arg0: commarg
) : void = let
//
val-~CAgitem(cmd) = commarg_view(arg0)
//
in
//
fprintln! (out, "Usage: ", cmd, " <command> ... <command>\n");
fprintln! (out, "where a <command> is of one of the following forms:\n");
//
end // end of [atexting_usage]

(* ****** ****** *)

fun
process_commarg
(
  x0: commarg
, state: &cmdstate >> _
) : void = let
in
//
case+ commarg_view(x0) of
//
| ~CAhelp _ =>
  atexting_usage
  (
    stderr_ref, state.cmdname
  ) (* CAhelp *)
//
| ~CAgitem(arg) =>
  {
    val () =
    fprintln!
    ( stderr_ref
    , "warning(atexting): "
    , "unrecognized arg: ", arg
    ) (* end of [val] *)
  }
//
| ~CAnsharp(_, opt) => let
    val ns =
    (
      case+ gopt_view(opt) of
      | ~GOnone() => 0
      | ~GOsome(ns) => g0string2int(ns)
    ) : int // end of [val]
  in
    the_nsharp_set(ns)
  end // end of [CSnsharp]
//
| ~CAinpfil(_, opt) =>
  (
    case+ gopt_view(opt) of
    | ~GOnone() => let
        val txts =
          parsing_from_stdin()
        // end of [val]
        val out =
          outchan_get_fileref(state.outchan)
        // end of [val]
      in
        atextlst_topeval(out, txts)
      end // end of [None]
    | ~GOsome(path) => let
        val txts =
          parsing_from_filename(path)
        // end of [val]
        val out =
          outchan_get_fileref(state.outchan)
        // end of [val]
      in
        atextlst_topeval(out, txts)
      end // end of [Some]
  ) (* end of [CAinpfil] *)
//
| ~CAoutfil(_, opt) =>
    process_commarg_outfil(x0, opt, state)
  // end of [CAoutfil]
//
end // end of [process_commarg]
//
and
process_commarg_outfil
(
  x0: commarg
, opt: gopt(string)
, state: &cmdstate >> _
) : void = let
//
val () =
  outchan_close(state.outchan)
// end of [val]
//
in
//
case+ gopt_view(opt) of
| ~GOnone() =>
  (
    state.outchan := @(0, stdout_ref)
  ) (* None *)
| ~GOsome(path) => let
    val opt =
      fileref_open_opt(path, state.outmode)
    // end of [val]
  in
    case+ opt of
    | ~None_vt() =>
      (
        state.outchan := @(0, stderr_ref)
      )
    | ~Some_vt(filr) => state.outchan := @(0, filr)
  end // end of [val]
//
end // end of [process_commarg_outfil]
//
and
process_commarglst
(
  xs: commarglst
, state: &cmdstate >> _
) : void = let
in
//
case+ glist_view(xs) of
//
| ~GLnil() =>
  process_commarglst_final(state)
//
| ~GLcons(x, xs) => let
    val () =
    process_commarg(x, state)
  in
    process_commarglst(xs, state)
  end // end of [list_cons]
//
end // end of [process_commarglst]
//
and
process_commarglst_final
(
  state: &cmdstate >> _
) : void = let
//
val () = outchan_close(state.outchan)
//
in
  // nothing
end // end of [process_commarglst_final]

in (* in-of-local *)

implement
main0{n}
(
  argc, argv
) = ((*void*)) where
{
(*
//val () =
println!
("Hello from [atexting]!")
//
*)
//
//
val () =
  the_nsharp_set(2)
//
val out = stdout_ref
val args = commarglst_parse(argc, argv)
(*
val _(*void*) = fprintln! (out, "args = ", args)
*)
//
val-
~GLcons
  (arg0, args) = glist_view(args)
//
var
state: cmdstate
val () =
state.cmdname := arg0
val () =
state.outmode := file_mode_w
val () =
state.outchan := @(0, stdout_ref)
//
val () = process_commarglst(args, state)
//
} (* end of [main0] *)

end // end of [local]
//
#endif // #ifdef(MAIN_NONE)

(* ****** ****** *)

(* end of [mylibies_link.dats] *)
