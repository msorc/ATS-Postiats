(*
**
** for highlighting ATS2 code
** Author: Hongwei Xi (hwxiATgmhwxiDOTcom)
**
*)

(* ****** ****** *)
//
// HX-2026-10: no GC (ATS2 port of the ATS1 version of this file)
// A closure is a pair (env, function): the output channel is the
// [env] of the [putc] that writes to it.
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"
//
(* ****** ****** *)
//
staload
STDIO =
"libats/libc/SATS/stdio.sats"
//
(* ****** ****** *)
//
staload
SYM = "src/pats_symbol.sats"
staload
FIL = "src/pats_filename.sats"
//
(* ****** ****** *)

staload "./../SATS/pats2xhtml.sats"

(* ****** ****** *)
//
staload
LSYNMK =
"utils/libatsynmark/SATS/libatsynmark.sats"
//
(* ****** ****** *)
//
implement
fileref2charlst
  (fil) = $LSYNMK.libatsynmark_char_list_vt_make_file(fil)
//
(* ****** ****** *)

(*
** HX-2012-06:
** prfexp: text-decoration: line-through for erasure?
*)
#define
PSYNMARK_HTML_FILE_BEG "\
<!DOCTYPE html>\n\
<html>\n\
<head>\n\
  <title></title>\n\
  <meta http-equiv=\"Content-Type\" content=\"text/html;charset=utf-8\"/>\n\
  <style type=\"text/css\">\n\
    .patsyntax {color:#808080;background-color:#E0E0E0;}\n\
    .patsyntax span.keyword {color:#000000;font-weight:bold;}\n\
    .patsyntax span.comment {color:#787878;font-style:italic;}\n\
    .patsyntax span.extcode {color:#A52A2A;}\n\
    .patsyntax span.neuexp  {color:#800080;}\n\
    .patsyntax span.staexp  {color:#0000F0;}\n\
    .patsyntax span.prfexp  {color:#603030;}\n\
    .patsyntax span.dynexp  {color:#F00000;}\n\
    .patsyntax span.stalab  {color:#0000F0;font-style:italic}\n\
    .patsyntax span.dynlab  {color:#F00000;font-style:italic}\n\
    .patsyntax span.dynstr  {color:#008000;font-style:normal}\n\
    .patsyntax span.stacstdec  {text-decoration:none;}\n\
    .patsyntax span.stacstuse  {color:#0000CF;text-decoration:underline;}\n\
    .patsyntax span.dyncstdec  {text-decoration:none;}\n\
    .patsyntax span.dyncstuse  {color:#B80000;text-decoration:underline;}\n\
    .patsyntax span.dyncst_implement  {color:#B80000;text-decoration:underline;}\n\
  </style>\n\
</head>\n\
<body class=\"patsyntax\">\n\
" // end of [PSYNMARK_HTML_FILE_BEG]

#define PSYNMARK_HTML_FILE_END "\
</body>\n\
</html>\n\
" // end of [PSYNMARK_HTML_FILE_END]

(* ****** ****** *)
//
fun
pats2xhtml_file_beg
  (out: FILEref): void =
  fprint_string(out, PSYNMARK_HTML_FILE_BEG)
fun
pats2xhtml_file_end
  (out: FILEref): void =
  fprint_string(out, PSYNMARK_HTML_FILE_END)
//
(* ****** ****** *)
//
#define PSYNMARK_HTML_PRE_END "</pre>\n"
#define PSYNMARK_HTML_PRE_BEG "<pre class=\"patsyntax\">\n"

(* ****** ****** *)
//
fun
pats2xhtml_pre_beg
  (out: FILEref): void =
  fprint_string(out, PSYNMARK_HTML_PRE_BEG)
//
fun pats2xhtml_pre_end
  (out: FILEref): void =
  fprint_string(out, PSYNMARK_HTML_PRE_END)
//
(* ****** ****** *)
//
staload "src/pats_comarg.sats"
//
(* ****** ****** *)

datatype
waitkind =
  | WTKnone // no wait
  | WTKoutput // -o ...
  | WTKinput_sta // -s ...
  | WTKinput_dyn // -d ...
  | WTKdefine // -DATS ...
  | WTKinclude // -IATS ...
// end of [waitkind]

(* ****** ****** *)

fun
waitkind_get_stadyn
  (knd: waitkind): int =
  case+ knd of
  | WTKinput_sta() => 0
  | WTKinput_dyn() => 1
  | _ (*erroneous*) => ~1 // this is not a valid input kind
// end of [cmdkind_get_stadyn]

(* ****** ****** *)
//
// HX-2026-10: [OUTCHANref(filr)] is @(0, filr) (never closed)
// and [OUTCHANptr(filp)] is @(1, filp) (closed when replaced)
//
typedef outchan = @(int, FILEref)
//
fun
outchan_get_fileref
  (x: outchan): FILEref = x.1
//
(* ****** ****** *)

typedef
cmdstate = @{
  comarg0= comarg
, ncomarg= int // number of arguments
, waitkind= waitkind
// number of processed input files;
, ninputfile= int // waiting for STDIN if it is 0
, outchan= outchan // current output channel
, standalone= bool (* output is a stand-alone file *)
, nerror= int // number of accumulated errors
} // end of [cmdstate]

(* ****** ****** *)

fun
cmdstate_set_outchan
(
  state: &cmdstate, chan_new: outchan
) : void = let
//
val chan_old = state.outchan
val ((*void*)) = state.outchan := chan_new
//
in
  if chan_old.0 = 0 then () else let
    val _(*err*) = $STDIO.fclose0 (chan_old.1) in (*nothing*)
  end // end of [if]
end // end of [cmdstate_set_outchan]

(* ****** ****** *)

fun
cmdstate_set_outchan_basename
(
  state: &cmdstate, basename: string
) : void = let
//
val opt = fileref_open_opt (basename, file_mode_w)
//
in
//
case+ opt of
| ~Some_vt (filp) =>
    cmdstate_set_outchan(state, @(1, filp))
| ~None_vt () => let
    val () = state.nerror := state.nerror + 1
  in
    cmdstate_set_outchan(state, @(0, stderr_ref))
  end // end of [None_vt]
//
end // end of [cmdstate_set_outchan_basename]

(* ****** ****** *)

fn isoutwait
  (state: cmdstate): bool =
  case+ state.waitkind of
  | WTKoutput() => true | _ => false
// end of [isoutwait]

fn isinpwait
  (state: cmdstate): bool =
  case+ state.waitkind of
  | WTKinput_sta() => true
  | WTKinput_dyn() => true
  | _ (*non-WTKinput*) => false
// end of [isinpwait]

fn isdatswait
  (state: cmdstate): bool =
  case+ state.waitkind of
  | WTKdefine() => true | _ => false
// end of [isdatswait]

fn isiatswait
  (state: cmdstate): bool =
  case+ state.waitkind of
  | WTKinclude() => true | _ => false
// end of [isiatswait]

(* ****** ****** *)
//
// HX-2026-10: the [putc] that writes to the output channel [env]
//
fun
fputc_putc
  (env: ptr, c: char): int =
  $STDIO.fputc0_char(c, $UN.castvwtp0{FILEref}(env))
//
(* ****** ****** *)

fun
pats2xhtml_level1_state_fileref
(
  state: &cmdstate, inp: FILEref
) : void = let
//
val stadyn =
  waitkind_get_stadyn(state.waitkind)
val out = outchan_get_fileref(state.outchan)
val putc =
  $LSYNMK.putc_make($UN.castvwtp0{ptr}(out), fputc_putc)
//
val () =
  if state.standalone then pats2xhtml_file_beg(out)
//
val () = pats2xhtml_pre_beg(out)
val () = pats2xhtml_level1_fileref(stadyn, inp, putc)
val () = pats2xhtml_pre_end(out)
//
val () =
  if state.standalone then pats2xhtml_file_end(out)
//
in
  // nothing
end // end of [pats2xhtml_level1_state_fileref]

(* ****** ****** *)

fun
pats2xhtml_level1_state_basename
(
  state: &cmdstate, basename: string
) : void = let
//
val opt = $FIL.filenameopt_make_local (basename)
//
in
//
case+ opt of
| ~Some_vt (fil) => let
    val fsym =
      $FIL.filename_get_fullname(fil)
    val fname = $SYM.symbol_get_name(fsym)
    val inp = $LSYNMK.libatsynmark_fopen_exn(fname, "r")
    val () = pats2xhtml_level1_state_fileref(state, inp)
    val _(*err*) = $STDIO.fclose0(inp)
  in
    // nothing
  end // end of [Some_vt]
| ~None_vt () => let
    val () = prerr_string "error(ATS)"
    val () = prerrln! (": the file of the name [", basename, "] is not available.")
  in
    state.nerror := state.nerror + 1
  end // end of [None_vt]
//
end // end of [pats2xhtml_level1_state_basename]

(* ****** ****** *)

fn
pats2xhtml_usage
  (cmd: string): void = {
//
macdef
pr(s) = fprint_string(stdout_ref, ,(s))
//
val () = pr("usage: ")
val () = fprint_string(stdout_ref, cmd)
val () = pr(" <command> ... <command>\n\n")
val () =
pr("where each <command> is of one of the following forms:\n\n")
//
val () =
pr("  -h : for printing out this help usage\n")
val () =
pr("  --help : for printing out this help usage\n")
//
val () =
pr("  -o <filename> : output into <filename>\n")
val () =
pr("  --output <filename> : output into <filename>\n")
//
val () =
pr("  -s <filename> : for processing static <filename>\n")
val () =
pr("  --static <filename> : for processing static <filename>\n")
//
val () =
pr("  -d <filename> : for processing dynamic <filename>\n")
val () =
pr("  --dynamic <filename> : for processing dynamic <filename>\n")
//
val () =
pr("  --embedded : for outputing xhtml code to be embedded\n")
//
} (* end of [pats2xhtml_usage] *)

(* ****** ****** *)

fun
process_cmdline
  {i:nat} (
  state: &cmdstate
, arglst: comarglst (i)
) : void = let
in
//
case+ arglst of
//
| ~list_vt_cons
    (arg, arglst) => let
    val () =
      state.ncomarg := state.ncomarg + 1
    // end of [val]
  in
    process_cmdline2(state, arg, arglst)
  end (* end of [list_vt_cons] *)
//
| ~list_vt_nil () => let
    val nif = state.ninputfile
  in
    if nif = 0
      then let
        val stadyn =
          waitkind_get_stadyn(state.waitkind)
        // end of [val]
      in
        if stadyn >= 0 then let
            val inp = stdin_ref
          in
            pats2xhtml_level1_state_fileref(state, inp)
          end // end of [then]
        else (
          if state.ncomarg = 0 then pats2xhtml_usage("pats2xhtml")
        ) (* end of [else] *)
      end // end of [then]
      else () // end of [else]
    // end of [if]
  end // end of [list_vt_nil]
//
end // end of [process_cmdline]

and
process_cmdline2
  {i:nat} (
  state: &cmdstate
, arg: comarg
, arglst: comarglst (i)
) : void = let
in
//
if
isinpwait(state) then let
//
// HX: the [inpwait] state stays unchanged
//
    val nif = state.ninputfile
  in
    if arg.0 = 1 && nif > 0 then
      process_cmdline2_comarg1(state, arglst, arg.1)
    else if arg.0 = 2 && nif > 0 then
      process_cmdline2_comarg2(state, arglst, arg.1)
    else let
      val basename = arg.1
      val () =
      (state.ninputfile := nif + 1)
      val () =
      pats2xhtml_level1_state_basename(state, basename)
    in
      process_cmdline(state, arglst)
    end (* end of [else] *)
  end // end of [isinpwait]
//
else if
isoutwait(state) then let
    val () =
    state.waitkind := WTKnone()
    val fname = arg.1
    val () = cmdstate_set_outchan_basename(state, fname)
  in
    process_cmdline(state, arglst)
  end // end of [isoutwait]
//
else if
isdatswait(state) then let
    val () =
    state.waitkind := WTKnone()
    val def = arg.1
    val () = process_DATS_def(def)
  in
    process_cmdline(state, arglst)
  end // end of [isdatswait]
//
else if
isiatswait(state) then let
    val () =
    state.waitkind := WTKnone()
    val dir = arg.1
    val () = process_IATS_dir(dir)
  in
    process_cmdline(state, arglst)
  end // end of [isiatswait]
//
else if arg.0 = 1 then
    process_cmdline2_comarg1(state, arglst, arg.1)
else if arg.0 = 2 then
    process_cmdline2_comarg2(state, arglst, arg.1)
else let
    val () =
    comarg_warning(arg.1)
    val () =
    state.waitkind := WTKnone() in process_cmdline(state, arglst)
  end // end of [else]
//
end // end of [process_cmdline2]

and
process_cmdline2_comarg1
  {i:nat}
(
  state: &cmdstate
, arglst: comarglst(i), key: string
) : void = let
//
val () = (
//
if key = "-o" then {
    val () =
    state.waitkind := WTKoutput()
  } (* -o *)
//
else if key = "-s" then {
    val () =
    state.ninputfile := 0
    val () =
    state.waitkind := WTKinput_sta()
  } (* -s *)
else if key = "-d" then {
    val () =
    state.ninputfile := 0
    val () =
    state.waitkind := WTKinput_dyn()
  } (* -d *)
//
else if key = "-h" then {
    val () =
    state.waitkind := WTKnone()
    val () =
    pats2xhtml_usage("pats2xhtml")
  } (* -h *)
//
else if
is_DATS_flag(key) then let
    val def = DATS_extract(key)
    val issome = stropt_is_some(def)
  in
    if issome then let
      val () =
        state.waitkind := WTKnone()
      // end of [val]
    in
      process_DATS_def(stropt_unsome(def))
    end else let
      val () = state.waitkind := WTKdefine()
    in
      // nothing
    end // end of [if]
  end // is_DATS_flag
else if
is_IATS_flag(key) then let
    val dir = IATS_extract(key)
    val issome = stropt_is_some(dir)
  in
    if issome then let
      val () =
        state.waitkind := WTKnone()
      // end of [val]
    in
      process_IATS_dir(stropt_unsome(dir))
    end else let
      val () = state.waitkind := WTKinclude()
    in
      // nothing
    end // end of [if]
  end // is_IATS_flag
else (*unrecognized*) comarg_warning(key)
//
) : void // end of [val]
//
in
  process_cmdline(state, arglst)
end // end of [process_cmdline2_comarg1]

and
process_cmdline2_comarg2
  {i:nat}
(
  state: &cmdstate
, arglst: comarglst(i), key: string
) : void = let
//
val () = (
//
if key = "--help" then
  let val () =
    state.waitkind := WTKnone()
  in
    pats2xhtml_usage("pats2xhtml")
  end // end of ["--help"]
//
else if key = "--output" then
    state.waitkind := WTKoutput()
//
else if key = "--static" then
    state.waitkind := WTKinput_sta()
else if key = "--dynamic" then
    state.waitkind := WTKinput_dyn()
//
else if key = "--embedded" then
    state.standalone := false
//
else (*unrecognized*) comarg_warning(key)
//
) : void // end of [val]
//
in
  process_cmdline(state, arglst)
end // end of [process_cmdline2_comarg2]

(* ****** ****** *)

implement
main0(argc, argv) = let
//
// HX-2026-10: the initialization of libatsopt
// (the ATS1 version did [dynload "utils/libatsynmark/dynloadall.dats"])
//
val () = $LSYNMK.libatsynmark_dynloadall((*void*))
//
val (pf, fpf | p) = argv_takeout_strarr(argv)
val
arglst =
$effmask_all(comarglst_parse(argc, !p))
prval () = minus_addback(fpf, pf | argv)
//
val+
~list_vt_cons(arg0, arglst) = arglst
//
var
state =
@{
  comarg0    = arg0
, ncomarg    = 0 // counting from 0
, waitkind   = WTKnone() // no wait
// the current number of
, ninputfile = 0 // prcessed input files
, outchan    = @(0, stdout_ref)
, standalone = true (* standalone output *)
, nerror     = 0 // the number of accumulated errors
} : cmdstate // end of [var state]
//
val () = process_cmdline(state, arglst)
//
in
  // nothing
end // end of [main0]

(* ****** ****** *)

(* end of [pats2xhtml_main.dats] *)
