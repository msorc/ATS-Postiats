(* ****** ****** *)
//
// Atscc2erl:
// from ATS to Erlang
//
(* ****** ****** *)
//
// HX-2015-06-29: start
//
(* ****** ****** *)
//
#include
"share/atspre_staload.hats"
//
(* ****** ****** *)
//
staload
UN = "prelude/SATS/unsafe.sats"
//
(* ****** ****** *)
//
#if
defined
(
CATSPARSEMIT_targetloc
)
#then
#else
//
#define
CATSPARSEMIT_targetloc
"./../CATS-parsemit"
//
#endif // end of [ifdef]
//
(* ****** ****** *)
//
#staload "libats/SATS/arena.sats"
#staload _ = "libats/DATS/arena.dats"
#staload
"{$CATSPARSEMIT}/SATS/catsparse.sats"
#staload
"{$CATSPARSEMIT}/SATS/catsparse_emit.sats"
#staload
"{$CATSPARSEMIT}/SATS/catsparse_syntax.sats"
#staload
"{$CATSPARSEMIT}/SATS/catsparse_typedef.sats"
#staload
"{$CATSPARSEMIT}/SATS/catsparse_fundecl.sats"
//
(* ****** ****** *)
//
extern
fun
emit_tmpdeclst_initize
(
  out: FILEref, tds: tmpdeclst
) : void // end-of-fun
//
local

fun
skipds
(
  p1: ptr
) : ptr = let
  val c1 = $UN.ptr0_get<char>(p1)
in
  if isdigit(c1)
    then skipds(ptr_succ<char>(p1)) else p1
  // end of [if]
end // end of [skipds]

fun
emit_axrg__
(
  out: FILEref, sym: symbol
) : void = let
//
val p0 =
string2ptr
  (symbol_get_name(sym))
// string2ptr
val p1 =
  skipds(ptr_succ<char>(p0))
//
val p1_2 = ptr_add<char>(p1, 2)
//
in
  emit_text(out, "arg");
  emit_text(out, $UN.cast{string}(p1_2))
end // end of [emit_axrg__]

in (* in-of-local *)

implement
emit_tmpdeclst_initize
  (out, tds) = let
//
fun
auxlst
(
  out: FILEref, tds: tmpdeclst
) : void = let
//
(*
val () =
println! ("auxlst: tds = ", tds)
*)
//
in
//
case+ glist_view(tds) of
| ~GLnil() => ()
| ~GLcons(td, tds) =>
  (
    case+
    tmpdec_node_view(td.tmpdec_node())
    of // case+
    | ~TMPDECnone
        (tmp) =>
        auxlst (out, tds)
    | ~TMPDECsome
        (tmp, _) =>
        auxlst (out, tds) where
      {
//
        val sym = tmp.i0dex_sym()
//
        val isaxrg = tmpvar_is_axrg(sym)
//
        val () =
        (
          emit_text(out, "%% var ");
          emit_tmpvar(out, tmp); emit_ENDL(out)
        ) (* end of [val] *)
//
        fun
        emit_axrg__
        (
          out: FILEref, sym: symbol
        ) : void = let
          val p0 =
            string2ptr
              (symbol_get_name(sym))
            // string2ptr
          val p4 = ptr_add<char>(p0, 4)
        in
          emit_text(out, "Arg");
          emit_text(out, $UN.cast{string}(p4))
        end // end of [emit_axrg__]
//
        val () =
        if isaxrg then
        (
          emit_nspc(out, 2);
          emit_tmpvar(out, tmp); emit_text(out, " = ");
          emit_axrg__(out, sym); emit_text(out, ",\n");
        ) (* end of [if] *)
//
      } (* end of [TMPDECsome] *)
  ) (* end of [list_cons] *)
//
end // end of [auxlst]
//
in
  auxlst (out, tds)
end // end of [emit_tmpdeclst_initize]

end // end of [local]
//
(* ****** ****** *)
//
extern
fun
the_Casefunx_new (): int
extern
fun
the_Casefunx_reset (): void
//
(* ****** ****** *)
//
extern
fun
the_funlabind_get (): int
extern
fun
the_funlabind_set (i0: int): void
//
(* ****** ****** *)
//
extern
fun
the_tmpdeclst_get (): tmpdeclst
extern
fun
the_tmpdeclst_set (tds: tmpdeclst): void
//
(* ****** ****** *)
//
extern
fun
the_f0headopt_get (): f0headopt
extern
fun
the_f0headopt_set (fhd: f0head): void
//
(* ****** ****** *)
//
extern
fun
the_funbodyknd_get (): int
extern
fun
the_funbodyknd_set (knd: int): void
//
(* ****** ****** *)
//
extern
fun
the_funbodylst_get (): instrlst
extern
fun
the_funbodylst_set (inss: instrlst): void
//
(* ****** ****** *)
//
extern
fun
the_branchlablst_get (): labelist
extern
fun
the_branchlablst_set (tls: labelist): void
extern
fun
the_branchlablst_unset ((*void*)): void
//
(* ****** ****** *)

local
//
//
// HX-2026-10: no GC (made of a static var)
//
var
the_Casefunx_var: int = 1
val the_Casefunx =
  ref_make_viewptr{int}(view@the_Casefunx_var | addr@the_Casefunx_var)
//
//
// HX-2026-10: no GC (made of a static var)
//
var
the_funlabind_var: int = ~1
val the_funlabind =
  ref_make_viewptr{int}(view@the_funlabind_var | addr@the_funlabind_var)
//
//
// HX-2026-10: no GC (made of a static var)
//
var
the_tmpdeclst_var: tmpdeclst = glist_nil()
val the_tmpdeclst =
  ref_make_viewptr{tmpdeclst}(view@the_tmpdeclst_var | addr@the_tmpdeclst_var)
//
//
// HX-2026-10: no GC (made of a static var)
//
var
the_f0headopt_var: f0headopt = gopt_none()
val the_f0headopt =
  ref_make_viewptr{f0headopt}(view@the_f0headopt_var | addr@the_f0headopt_var)
//
//
// HX-2026-10: no GC (made of a static var)
//
var
the_funbodyknd_var: int = ~1
val the_funbodyknd =
  ref_make_viewptr{int}(view@the_funbodyknd_var | addr@the_funbodyknd_var)
//
// HX-2026-10: no GC (made of a static var)
//
var
the_funbodylst_var: instrlst = glist_nil()
val the_funbodylst =
  ref_make_viewptr{instrlst}(view@the_funbodylst_var | addr@the_funbodylst_var)
//
// HX: this is a stack:
//
//
// HX-2026-10: no GC (made of a static var)
//
var
the_branchlablstlst_var: glist(labelist) = glist_nil()
val the_branchlablstlst =
  ref_make_viewptr{glist(labelist)}(view@the_branchlablstlst_var | addr@the_branchlablstlst_var)
//
in (* in-of-local *)

implement
the_Casefunx_new
  ((*void*)) = fx where
{
  val fx = !the_Casefunx
  val () = !the_Casefunx := fx+1 
}

implement
the_Casefunx_reset() = !the_Casefunx := 1

implement
the_funlabind_get() = !the_funlabind
implement
the_funlabind_set(i0) = !the_funlabind := i0

implement
the_tmpdeclst_get () = !the_tmpdeclst
implement
the_tmpdeclst_set (xs) = !the_tmpdeclst := xs

implement
the_f0headopt_get () = !the_f0headopt
implement
the_f0headopt_set (fhd) = !the_f0headopt := gopt_some(fhd)

implement
the_funbodyknd_get() = !the_funbodyknd
implement
the_funbodyknd_set(knd) = !the_funbodyknd := knd

implement
the_funbodylst_get () = !the_funbodylst
implement
the_funbodylst_set (xs) = !the_funbodylst := xs

implement
the_branchlablst_get
(
) = let
//
val xss = !the_branchlablstlst
//
in
//
case- glist_view(xss) of ~GLcons (xs, _) => xs
//
end // end of [the_branchlablst_get]

implement
the_branchlablst_set
(
  xs
) = let
//
val xss = !the_branchlablstlst
//
in
  !the_branchlablstlst := glist_cons (xs, xss)
end // end of [the_branchlablst_set]

implement
the_branchlablst_unset
(
) = let
//
val xss = !the_branchlablstlst
//
in
//
case- glist_view(xss) of
| ~GLcons (_, xss) => !the_branchlablstlst := xss
//
end // end of [the_branchlablst_unset]

end // end of [local]

(* ****** ****** *)
//
extern
fun
funlab_get_index (fl: label): int
extern
fun
tmplab_get_index (lab: label): int
//
(* ****** ****** *)

implement
funlab_get_index
  (fl0) = let
//
val n0 = fl0.i0dex_sym()
//
fun
auxlst
(
  xs: instrlst, i: int
) : int = (
//
case+ glist_view(xs) of
| ~GLnil
   ((*error*)) => ~1
  // end of [list_nil]
| ~GLcons(x, xs) =>
  (
    case+
    instr_node_view(x.instr_node())
    of // case+
    | ~ATSfunbodyseq _ => let
        val fl = funbodyseq_get_funlab (x)
      in
        if n0 = fl.i0dex_sym() then i else auxlst (xs, i+1)
      end // end of [ATSfunbodyseq]
    | v0 (*non-ATSfunbody*) => (instr_node_view_free(v0); auxlst (xs, i))
  ) (* end of [list_cons] *)
//
) (* end of [auxlst] *)
//
in
  auxlst (the_funbodylst_get(), 1)
end // end of [funlab_get_index]

(* ****** ****** *)

implement
tmplab_get_index
  (lab0) = let
//
val n0 = lab0.i0dex_sym()
//
fun
auxlst
(
  xs: labelist, i: int
) : int =
(
case+ glist_view(xs) of
| ~GLnil
    ((*error*)) => ~1
  // end of [list_nil]
| ~GLcons (x, xs) =>
  if n0 = x.i0dex_sym()
    then i else auxlst (xs, i+1)
  // end of [list_cons]
)
//
in
  auxlst (the_branchlablst_get(), 1)
end // end of [tmplab_get_index]

(* ****** ****** *)
//
fun
emit_funlab_index
 (out: FILEref, fl: label): void =
 emit_int (out, funlab_get_index (fl))
//
fun
emit_tmplab_index
 (out: FILEref, lab: label): void =
 emit_int (out, tmplab_get_index (lab))
//
(* ****** ****** *)
//
extern
fun
emit_Casefun (out: FILEref): void
extern
fun
emit_Casefun2 (out: FILEref, tli: int): void
//
implement
emit_Casefun (out) =
  emit_text(out, "Casefun")
//
implement
emit_Casefun2
  (out, tli) = () where
{
//
val () = emit_Casefun(out)
//
val () = emit_LPAREN(out)
val () = emit_Casefun(out)
val () = emit_text(out, ", ")
val () = emit_int (out, tli)
val () = emit_RPAREN(out)
//
} (* end of [emit_Casefun2] *)
//
(* ****** ****** *)
//
extern
fun
emit_Casefunx
  (out: FILEref, x: int): void
extern
fun
emit_Casefunx2
  (out: FILEref, x: int, tli: int): void
//
implement
emit_Casefunx (out, x) =
  (emit_text(out, "Casefunx"); emit_int(out, x))
//
implement
emit_Casefunx2
  (out, x, tli) = () where
{
//
val () =
  emit_Casefunx(out, x)
//
val () = emit_LPAREN(out)
//
val () =
(
  emit_Casefunx(out, x); emit_text(out, ", "); emit_int (out, tli)
) (* end of [val] *)
//
val () = emit_RPAREN(out)
//
} (* end of [emit_Casefunx2] *)
//
(* ****** ****** *)
//
extern
fun emit2_instr
  (out: FILEref, ind: int, ins: instr): void
//
extern
fun emit2_instr_ln
  (out: FILEref, ind: int, ins: instr): void
//
extern
fun
emit2_instrlst
  (out: FILEref, ind: int, inss: instrlst): void
(*
extern
fun
emit2_instrlst_ln
  (out: FILEref, ind: int, inss: instrlst): void
*)
extern
fun
emit2_instrlst_end
  (out: FILEref, ind: int, inss: instrlst, sep: string): void
//
(* ****** ****** *)
//
extern
fun emit2_branchlst
  (out: FILEref, ind: int, inss: instrlst): void
extern
fun emit2_branchseqlst
  (out: FILEref, ind: int, inss: instrlst): void
//
(* ****** ****** *)
//
extern
fun emit2_tailcalseqlst
  (out: FILEref, ind: int, inss: instrlst): void
//
(* ****** ****** *)
//
extern
fun emit2_ATSfunbodyseq
  (out: FILEref, ind: int, ins: instr) : void
//
extern
fun emit2_ATSINSmove_con1
  (out: FILEref, ind: int, ins: instr) : void
//
extern
fun emit2_ATSINSmove_boxrec
  (out: FILEref, ind: int, ins: instr) : void
extern
fun emit2_ATSINSmove_fltrec
  (out: FILEref, ind: int, ins: instr) : void
//
(* ****** ****** *)
//
extern
fun emit2_ATSINSmove_delay
  (out: FILEref, ind: int, ins: instr) : void
extern
fun emit2_ATSINSmove_lazyeval
  (out: FILEref, ind: int, ins: instr) : void
//
// HX-2026-10: linear lazy values ($ldelay)
//
extern
fun emit2_ATSINSmove_ldelay
  (out: FILEref, ind: int, ins: instr) : void
extern
fun emit2_ATSINSmove_llazyeval
  (out: FILEref, ind: int, ins: instr) : void
//
(* ****** ****** *)
//
// HX-2014-08:
// this one should not be used for
// emitting multiple-line instructions
//
implement
emit_instr
  (out, ins) = emit2_instr (out, 0(*ind*), ins)
//
(* ****** ****** *)

implement
emit2_instr
  (out, ind, ins0) = let
in
//
case+
instr_node_view(ins0.instr_node())
of // case+
//
| ~ATSif
  (
    d0e, inss, inssopt
  ) => let
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "if\n")
    val () = emit_nspc (out, ind+2)
    val () = emit_d0exp (out, d0e)
    val () = emit_text (out, " ->\n")
    val () = emit2_instrlst_end (out, ind+4, inss, ";\n")
    val () = emit_nspc (out, ind+2)
    val () = emit_text (out, "%% if-then\n")
  in
    case+ gopt_view(inssopt) of
    | ~GOnone() =>
      {
        val () = emit_nspc (out, ind+2)
        val () = emit_text (out, "true ->\n")
        val () = emit_nspc (out, ind+4)
        val () = emit_text (out, "atscc2erl_void\n")
        val () = emit_nspc (out, ind+2)
        val () = emit_text (out, "%% if-else\n")
        val () = emit_nspc (out, ind)
        val ((*closing*)) = emit_text (out, "end")
      } (* end of [None] *)
    | ~GOsome(inss) =>
      {
        val () = emit_nspc (out, ind+2)
        val () = emit_text (out, "true ->\n")
        val () = emit2_instrlst_end (out, ind+4, inss, "\n")
        val () = emit_nspc (out, ind+2)
        val () = emit_text (out, "%% if-else\n")
        val () = emit_nspc (out, ind)
        val ((*closing*)) = emit_text (out, "end")
      } (* end of [Some] *)
  end // end of [ATSif]
//
| ~ATSifthen (d0e, inss) =>
  {
//
    val ins = glist_head(inss)
//
    val () = emit_nspc(out, ind)
    val () = emit_text(out, "if(")
    val () = emit_d0exp(out, d0e)
    val () = emit_text(out, ") -> ")
    val () = emit_instr(out, ins)
    val () = emit_text(out, "; true -> atscc2erl_void end")
  }
//
| ~ATSifnthen (d0e, inss) =>
  {
//
    val ins = glist_head(inss)
//
    val () = emit_nspc(out, ind)
    val () = emit_text(out, "if(not(")
    val () = emit_d0exp(out, d0e)
    val () = emit_text(out, ")) -> ")
    val () = emit_instr(out, ins)
    val () = emit_text(out, "; true -> atscc2erl_void end")
  }
//
| ~ATSbranchseq (inss) =>
  {
    val () = emit_nspc(out, ind)
    val () = emit_text(out, "%% ATSbranchseq(...)")
  }
//
| ~ATScaseofseq (inss) =>
  {
//
    val tls =
      caseofseq_get_tmplablst(ins0)
    // end of [val]
    val () = the_branchlablst_set(tls)
//
    val () = emit_nspc(out, ind)
    val () = emit_text(out, "begin\n")
(*
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "%while(true) {\n")
*)
//
    val fx = the_Casefunx_new()
//
    val () = emit_nspc(out, ind)
    val () =
      (emit_Casefunx(out, fx); emit_text(out, " =\n"))
    // end of [val]
    val () = emit_nspc(out, ind)
    val () = emit_text(out, "fun (Casefun, Tmplab) ->\n")
//
(*
    val () = emit_nspc(out, ind+2)
    val () = emit_text(out, "%% Tmplab = Tmplab_erl; Tmplab_erl = 0;\n")
*)
    val () = emit_nspc(out, ind+2)
    val () = emit_text(out, "%switch(Tmplab) {\n")
//
    val () = emit_nspc(out, ind+2)
    val () = emit_text(out, "case Tmplab of\n")
//
    val () = emit2_branchseqlst(out, ind+4, inss)
//
    val () = emit_nspc(out, ind+2)
    val () = emit_text(out, "end %% endcase\n")
    val () = emit_nspc(out, ind+2)
    val () = emit_text(out, "%} // end-of-switch\n")
//
(*
    val () = emit_nspc (out, ind+2)
    val () = emit_text (out, "%% if (Tmplab_erl = 0) break;\n")
*)
//
    val () = emit_nspc(out, ind)
    val () = emit_text(out, "end, %% endfun\n")
(*
    val () = emit_nspc (out, ind)
    val ((*closing*)) = emit_text (out, "%} // endwhile\n")
*)
//
//
    val () = emit_nspc(out, ind)
    val () = emit_Casefunx2 (out, fx, 1)
//
    val () = emit_ENDL(out)
    val () = emit_nspc(out, ind)
    val () = emit_text(out, "end")
//
    val () = the_branchlablst_unset ((*void*))
//
  } (* end of [ATScaseofseq] *)
//
| ~ATSreturn (tmp) =>
  {
    val () = emit_nspc(out, ind)
    val () = emit_text(out, "%% return ")
    val () =
      (emit_tmpvar(out, tmp); emit_SEMICOLON(out))
    // end of [val]
  }
| ~ATSreturn_void (tmp) =>
  {
    val () = emit_nspc(out, ind)
    val () = emit_text(out, "%% return/*_void*/;")
    val () = emit_SEMICOLON(out)
  }
//
| ~ATSINSlab (lab) =>
  {
    val () = emit_nspc(out, ind)
    val () = emit_text(out, "%% case ")
    val () = emit_tmplab_index(out, lab)
    val () =
      (emit_text(out, ": // "); emit_label(out, lab))
    // (* end of [val] *)
  } (* end of [ATSINSlab] *)
//
| ~ATSINSgoto (lab) =>
  {
//
    val () = emit_nspc(out, ind)
    val () = emit_Casefun2(out, tmplab_get_index(lab))
//
  } (* end of [ATSINSgoto] *)
//
| ~ATSINSflab (flab) =>
  {
    val () = emit_nspc(out, ind)
    val () = emit_text(out, "%% ")
    val () = emit_label(out, flab)
  } (* end of [ATSINSflab] *)
//
| ~ATSINSfgoto(flab) =>
  {
    val () = emit_nspc(out, ind)
//
    val () = let
      val fi =
        funlab_get_index (flab)
      // end of [val]
      val () = the_funlabind_set(fi)
    in
      emit_text (out, "%% Funlab_erl = "); emit_int (out, fi)
    end (* end of [val] *)
//
    val () = (emit_text (out, "% // "); emit_label (out, flab))
  } (* end of [ATSINSfgoto] *)
//
| ~ATSINSfreeclo (d0e) =>
  {
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "%% ")
    val () = emit_text (out, "ATSINSfreeclo")
    val () = emit_LPAREN (out)
    val () = emit_d0exp (out, d0e)
    val () = emit_RPAREN (out)
    val () = emit_SEMICOLON (out)
  }
| ~ATSINSfreecon (d0e) =>
  {
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "%% ")
    val () = emit_text (out, "ATSINSfreecon")
    val () = emit_LPAREN (out)
    val () = emit_d0exp (out, d0e)
    val () = emit_RPAREN (out)
    val () = emit_SEMICOLON (out)
  }
//
| ~ATSINSmove
    (tmp, d0e) =>
  {
//
    val () = emit_nspc (out, ind)
//
    val isret =
      tmpvar_is_tmpret (tmp.i0dex_sym())
    // end of [val]
//
    val () =
    if isret
      then (
        emit_d0exp (out, d0e)
      ) (* end of [then] *)
      else (
        emit_tmpvar (out, tmp);
        emit_text (out, " = "); emit_d0exp (out, d0e)
      ) (* end of [else] *)
    // end of [if]
//
  } (* end of [ATSINSmove] *)
//
| ~ATSINSmove_void
    (tmp, d0e(*command*)) => let
    val () = emit_nspc (out, ind)
  in
    case+
    d0exp_node_view(d0e.d0exp_node())
    of // case+
    | ~ATSPMVempty _ =>
        emit_text (out, "?ATSINSmove_void()")
      // end of [ATSempty]
    | v0 (*non-ATSPMVempty*) => (d0exp_node_view_free(v0); emit_d0exp (out, d0e))
      // end of [non-ATSPMVempty]
  end (* end of [ATSINSmove_void] *)
//
| ~ATSINSmove_nil(tmp) =>
  {
//
    val () = emit_nspc (out, ind)
//
    val
    isret =
      tmpvar_is_tmpret (tmp.i0dex_sym())
    // end of [val]
    val () =
    if not(isret) then
    {
      val () = emit_tmpvar (out, tmp)
      val () = emit_text (out, " = ")
    } (* end of [val] *)
//
    val () = emit_text (out, "atscc2erl_null")
//
  }
//
| ~ATSINSmove_con0(tmp, tag) =>
  {
//
    val () = emit_nspc (out, ind)
//
    val
    isret =
      tmpvar_is_tmpret (tmp.i0dex_sym())
    // end of [val]
    val () =
    if not(isret) then
    {
      val () = emit_tmpvar (out, tmp)
      val () = emit_text (out, " = ")
    } (* end of [val] *)
//
    val () = emit_PMVint (out, tag)
//
  }
//
| ~ATSINSmove_con1 _ =>
    emit2_ATSINSmove_con1 (out, ind, ins0)
//
| ~ATSINSmove_boxrec _ =>
    emit2_ATSINSmove_boxrec (out, ind, ins0)
| ~ATSINSmove_fltrec _ =>
    emit2_ATSINSmove_fltrec (out, ind, ins0)
//
| ~ATSINSmove_delay _ =>
    emit2_ATSINSmove_delay (out, ind, ins0)
| ~ATSINSmove_lazyeval _ =>
    emit2_ATSINSmove_lazyeval (out, ind, ins0)
//
| ~ATSINSmove_ldelay _ =>
    emit2_ATSINSmove_ldelay (out, ind, ins0)
| ~ATSINSmove_llazyeval _ =>
    emit2_ATSINSmove_llazyeval (out, ind, ins0)
//
| ~ATStailcalseq(inss) =>
  {
//
    val () = emit2_tailcalseqlst(out, ind, inss)
//
  } (* end of [ATStailcalseq] *)
//
| ~ATSINSmove_tlcal
    (tmp, d0e) =>
  {
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "%% ")
    val () = emit_tmpvar (out, tmp)
    val () = emit_text (out, " = ")
    val () = emit_d0exp (out, d0e)  
    // val () = emit_SEMICOLON (out)
  } (* end of [ATSINSmove_tlcal] *)
//
| ~ATSINSargmove_tlcal
    (tmp1, tmp2) =>
  {
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "%% ")
    val () = emit_tmpvar (out, tmp1)
    val () = emit_text (out, " = ")
    val () = emit_tmpvar (out, tmp2)
    // val () = emit_SEMICOLON (out)
  } (* end of [ATSINSargmove_tlcal] *)
//
| ~ATSINSextvar_assign
    (ext, d0e_r) =>
  {
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "%% ")
    val () = emit_d0exp (out, ext)
    val () = emit_text (out, " = ")
    val () = emit_d0exp (out, d0e_r)
    val () = emit_SEMICOLON (out)
  }
| ~ATSINSdyncst_valbind
    (d2c, d0e_r) =>
  {
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "%% ")
    val () = emit_i0de (out, d2c)
    val () = emit_text (out, " = ")
    val () = emit_d0exp (out, d0e_r)
    val () = emit_SEMICOLON (out)
  }
//
| ~ATSINScaseof_fail(errmsg) =>
  {
//
    val () = emit_nspc (out, ind)
//
    val () =
      emit_text (out, "?ATSINScaseof_fail")
    val () =
    (
      emit_LPAREN (out); emit_PMVstring (out, errmsg); emit_RPAREN (out)
    ) (* end of [val] *)
//
  }
| ~ATSINSdeadcode_fail(__tok__) =>
  {
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "?ATSINSdeadcode_fail()")
  }
//
| ~ATSdynload(dummy) =>
  {
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "%% ATSdynload()")
  }
//
| ~ATSdynloadset(flag) =>
  {
    val () = emit_nspc (out, ind)
    val () = (
      emit_tmpvar (out, flag); emit_text (out, " = 1 ; // flag is set")
    ) (* end of [val] *)
  }
//
| ~ATSdynloadfcall(fcall) =>
  {
    val () = emit_nspc (out, ind)
    val () = (
      emit_tmpvar (out, fcall); emit_text (out, "(/*void*/) ; // dynloading")
    ) (* end of [val] *)
  }
//
| ~ATSdynloadflag_sta(flag) =>
  {
    val () = emit_nspc (out, ind)
    val () = fprint! (out, "%% ATSdynloadflag_sta(", flag, ")")
  }
| ~ATSdynloadflag_ext(flag) =>
  {
    val () = emit_nspc (out, ind)
    val () = fprint! (out, "%% ATSdynloadflag_ext(", flag, ")")
  }
//
| v0 (*rest-of-instr*) => (instr_node_view_free(v0);
  {
    val () = emit_nspc (out, ind)
    val ((*error*)) = fprint! (out, "UNRECOGNIZED-INSTRUCTION: ", ins0)
  })
//
end // end of [emit2_instr]

(* ****** ****** *)

implement
emit2_instr_ln
  (out, ind, ins) =
(
  emit2_instr (out, ind, ins); emit_ENDL (out)
) (* end of [emit2_instr_ln] *)

(* ****** ****** *)

implement
emit2_instrlst
(
  out, ind, inss
) = let
//
fun
auxlst
(
  i: int, inss: instrlst
) : void =
(
//
case+ glist_view(inss) of
| ~GLnil
    ((*void*)) => ()
| ~GLcons
    (ins, inss) => let
    val () =
    if i > 0
      then emit_text (out, ",\n")
    // end of [val]
    val () = emit2_instr (out, ind, ins)
  in
    auxlst (i+1, inss)
  end // end of [list_cons]
//
)
//
in
  auxlst (0, inss)
end (* end of [emit2_instrlst] *)

(* ****** ****** *)

implement
emit2_instrlst_end
  (out, ind, inss, sep) = (
//
case+ glist_view(inss) of
//
| ~GLcons _ => let
    val () =
    emit2_instrlst
      (out, ind, inss)
    // end of [val]
    val () = emit_text (out, sep)
  in
    // nothing
  end // end of [list_cons]
//
//
// HX-2026-10:
// an empty body is a syntax error in Erlang; it arises
// from an empty branch (e.g., the free-branch of a
// $ldelay-expression without one)
//
| ~GLnil() =>
  (
    emit_nspc(out, ind);
    emit_text(out, "atscc2erl_void"); emit_text(out, sep)
  ) (* end of [GLnil] *)
//
) (* end of [emit2_instrlst_end] *)

(* ****** ****** *)

implement
emit2_branchlst
  (out, ind, inss) = let
//
fun
auxins
(
  ind: int
, tli: int, ins: instr
) : void = let
in
  emit2_instr(out, ind, ins)
end // end of [auxins]
//
fun
auxinss0
(
  ind: int, inss: instrlst
) : void =
(
case glist_view(inss) of
| ~GLnil((*void*)) => ()
| ~GLcons(ins1, inss1) =>
  (
    case+
    instr_node_view(ins1.instr_node())
    of // case+
    | ~ATSINSlab(lab) => let
        val
        tli1 =
        tmplab_get_index(lab)
      in
        auxinss1 (ind, tli1, inss1)
      end
    | v0 (*non-ATSINSlab*) => (instr_node_view_free(v0); auxinss0 (ind, inss1))
  )
)
//
and
auxinss1
(
  ind: int
, tli: int, inss: instrlst
) : void = let
//
val () = emit_nspc (out, ind)
val () = (emit_int (out, tli); emit_text (out, " ->\n"))
//
val inss = auxinss2 (ind, tli, 0, inss)
//
val () = emit_text (out, ";\n")
//
in
  auxinss0 (ind, inss)
end (* end of [auxinss1] *)
//
and
auxinss2
(
  ind: int
, tli: int, i: int, inss: instrlst
) : instrlst =
(
case+ glist_view(inss) of
| ~GLnil
    ((*void*)) => glist_nil()
  // end of [list_nil]
| ~GLcons
    (ins1, inss1) => let
    val () =
    if i > 0
      then emit_text (out, ",\n")
    // end of [val]
  in
    case+
    instr_node_view(ins1.instr_node())
    of // case+
    | ~ATSINSlab(lab) => let
        val () = emit_nspc (out, ind)
        val () = emit_Casefun2 (out, tli+1)
      in
        inss
      end // end of [ATSINSlab]
    | v0 (*non-ATSINSlab*) => (instr_node_view_free(v0);
        auxinsinss2 (ind, tli, i, ins1, inss1))
   end // end of [non-ATSINSlab]
)
//
and
auxinsinss2
(
  ind: int
, tli: int, i: int
, ins: instr, inss: instrlst
) : instrlst =
(
case+
instr_node_view(ins.instr_node())
of // case+
| ~ATSINSlab(lab) => let
    val () = emit_nspc (out, ind)
    val () = emit_Casefun2 (out, tli+1)
  in
    inss
  end // end of [ATSINSlab]
//
| ~ATSifthen
    (d0e, inss2) => let
//
    val-~GLcons (ins2, _) = glist_view(inss2)
//
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "if(")
    val () = emit_d0exp (out, d0e)
    val () = emit_text (out, ") -> ")
    val () = emit_instr (out, ins2)
    val () = emit_text (out, "; true ->\n")
    val inss = auxinss2 (ind+2, tli, 0, inss)
    val () = emit_ENDL (out)
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "end")
  in
    inss
  end // end of [ATSifnthen]
| ~ATSifnthen
    (d0e, inss2) => let
//
    val-~GLcons (ins2, _) = glist_view(inss2)
//
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "if(not(")
    val () = emit_d0exp (out, d0e)
    val () = emit_text (out, ")) -> ")
    val () = emit_instr (out, ins2)
    val () = emit_text (out, "; true ->\n")
    val inss = auxinss2 (ind+2, tli, 0, inss)
    val () = emit_ENDL (out)
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "end")
  in
    inss
  end // end of [ATSifnthen]
//
| v0 (*rest-of-ATSINS*) => (instr_node_view_free(v0);
  (
    auxins (ind, tli, ins); auxinss2 (ind, tli, i+1, inss)
  ) (* end of [rest-of-ATSINS] *))
//
) (* end of [auxinsinss2] *)
//
in
  auxinss0 (ind, inss)
end // end of [emit2_branchlst]

(* ****** ****** *)

implement
emit2_branchseqlst
  (out, ind, inss) = let
//
fun auxseq
(
  out: FILEref
, ind: int, ins0: instr
) : void = let
in
//
case-
instr_node_view(ins0.instr_node()) of
//
| ~ATSbranchseq
    (inss) => emit2_branchlst (out, ind, inss)
  // end of [ATSbranchseq]
//
end (* end of [auxseq] *)
//
fun auxseqlst
(
  out: FILEref
, ind: int, inss: instrlst
) : void = let
in
//
case+ glist_view(inss) of
| ~GLnil
    ((*void*)) => ()
| ~GLcons
    (ins, inss) => let
//
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "%% ATSbranchseq_beg\n")
//
    val () = auxseq (out, ind, ins)
//
(*
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "break;\n")
*)
//
    val () = emit_nspc (out, ind)
    val () = emit_text (out, "%% ATSbranchseq_end\n")
//
  in
    auxseqlst (out, ind, inss)
  end (* end of [list_cons] *)
//
end (* end of [auxseqlst] *)
//
val () = auxseqlst (out, ind, inss)
//
val () = emit_nspc (out, ind)
val () = emit_text (out, "_ -> ")
val () = emit_text (out, "atscc2erl_caseof_deadcode(?FILE, ?LINE)\n")
//
in
  // nothing
end // end of [emit2_branchseqlst]

(* ****** ****** *)

implement
emit2_tailcalseqlst
  (out, ind, inss) = let
//
fun
auxenvlst
(
  out: FILEref, i0: int, xs: f0arglst
) : int =
(
case+ glist_view(xs) of
| ~GLnil() => i0
| ~GLcons(x, xs) =>
  (
    case+
    f0arg_node_view(x.f0arg_node())
    of // case+
    | ~F0ARGnone _ => i0
    | ~F0ARGsome(arg, s0e) =>
      if tmpvar_is_env(arg.i0dex_sym())
        then (
          (if i0 > 0 then emit_text(out, ", "));
          emit_tmpvar(out, arg); auxenvlst(out, i0+1, xs)
        ) else i0
      // end of [F0ARGsome]
  ) (* end of [list_cons] *)
)
//
fun
auxarglst
(
  out: FILEref, i0: int, xs: instrlst
) : int =
(
case+ glist_view(xs) of
| ~GLnil () => i0
| ~GLcons(x, xs) =>
  (
    case+ instr_node_view(x.instr_node()) of
    | ~ATSINSmove_tlcal
        (_, d0e) => let
        val () =
        if i0 > 0
          then emit_text(out, ", ")
        // end of [if]
        val () = emit_d0exp(out, d0e)
      in
        auxarglst(out, i0+1, xs)
      end // end of [ATSINSmove_tlcal]
    | v0(*non-ATSINSmove_tlcal*) => (instr_node_view_free(v0); i0)
  )
)
//
val () =
  emit2_instrlst(out, ind, inss)
//
val knd = the_funbodyknd_get()
val-~GOsome(fhd) = gopt_view(the_f0headopt_get())
//
in
//
case+
f0head_node_view(fhd.f0head_node())
of // case+
| ~F0HEAD
    (fid, f0ma, res) =>
  {
//
    val () = emit_ENDL (out)
    val () = emit_nspc (out, ind)
//
(*
    val () = emit_text (out, "%% ")
*)
//
    val () =
      emit_i0de (out, fid)
    val () =
      if knd >= 2 then emit_text(out, "__")
//
    val () = emit_LPAREN (out)
//
    val () =
      if knd >= 2
        then emit_int(out, the_funlabind_get())
      // end of [if]
//
    val xs = f0ma.f0marg_node()
    val i0 =
      (if knd <= 1 then 0 else 1): int
    // end of [val]
    val i0 = auxenvlst (out, i0, xs)
    val i0 = auxarglst (out, i0, inss)
//
    val () = emit_RPAREN (out)
//
  } (* end of [F0HEAD] *)
//
end // end of [emit2_tailcalseqlst]

(* ****** ****** *)

implement
emit2_ATSfunbodyseq
  (out, ind, ins) = let
//
val-~ATSfunbodyseq(inss) = instr_node_view(ins.instr_node())
//
in
  emit2_instrlst_end (out, ind, inss, ".\n")
end // end of [emit2_ATS2funbodyseq]

(* ****** ****** *)
//
(*
datatype
tyfld_node =
TYFLD of (i0de, s0exp)
typedef
tyfld = tyfld_TYFLDREC(loc_t, tyfld_node) (* end of [tyfld] *)
//
typedef tyfldlst = glist(tyfld)
//
typedef tyrec = tyrec_TYREC(loc_t, tyfldlst) (* end of [tyrec] *)
*)
//
extern
fun
emit_tyrec
  (FILEref, tyrec): void
//
implement
emit_tyrec
  (out, s0rec) = let
//
fun
auxlst
(
  i: int, tfs: tyfldlst
) : void =
(
case+ glist_view(tfs) of
| ~GLnil() => ()
| ~GLcons(tf, tfs) => let
    val+~TYFLD(id, _) = tyfld_node_view(tf.tyfld_node())
    val () =
      if i > 0 then emit_text(out, ", ")
    // end of [val]
    val () = emit_i0de(out, id)
  in
    auxlst (i+1, tfs)
  end // end of [list_cons]
)
//
val () = emit_LBRACE(out)
val () = auxlst(0, s0rec.tyrec_node())
val () = emit_RBRACE(out)
//
in
  // nothing
end // end of [emit_tyrec]
//
extern
fun
emit_typedef
  (FILEref, i0de, tyrec): void
//
implement
emit_typedef
  (out, id, s0rec) = let
//
val () = emit_text(out, "-record")
//
val () = emit_LPAREN(out)
val () = emit_i0de(out, id)
val () = emit_text(out, ", ")
val () = emit_tyrec(out, s0rec)
val () = emit_RPAREN(out)
val () = emit_text(out, ".\n")
//
in
end // end of [emit_typedef]
//
extern
fun
emit_tyrec_d0explst
  (FILEref, d0explst): void
extern
fun
emit_tysum_d0explst
  (FILEref, tag: tokenopt, d0explst): void
//
implement
emit_tyrec_d0explst
  (out, d0es) =
(
  emit_d0explst (out, d0es)
) // end of [emit_tyrec_d0explst]

implement
emit_tysum_d0explst
  (out, opt, d0es) = (
//
case+ gopt_view(opt) of
| ~GOnone() =>
    emit_d0explst (out, d0es)
| ~GOsome(tag) => let
    val () =
      emit_PMVint(out, tag)
    // end of [val]
  in
    emit_d0explst_1 (out, d0es)
  end // end of [Some]
//
) // end of [emit_tysum_d0explst]
//
(* ****** ****** *)

implement
emit2_ATSINSmove_con1
  (out, ind, ins0) = let
//
fun
getarglst
(
  inss: instrlst
) : d0explst =
(
case+ glist_view(inss) of
| ~GLnil
    ((*void*)) => glist_nil()
| ~GLcons
    (ins, inss) => let
    val-~ATSINSstore_con1_ofs(_, _, _, d0e) = instr_node_view(ins.instr_node())
    val d0es = getarglst(inss)
  in
    glist_cons(d0e, d0es)
  end // end of [list_cons]
)
//
val-~ATSINSmove_con1(inss) = instr_node_view(ins0.instr_node())
//
val-~GLcons(ins, inss) = glist_view(inss)
val-~ATSINSmove_con1_new(tmp, _) = instr_node_view(ins.instr_node())  
//
var opt: tokenopt = gopt_none()
//
val inss =
(
case+ glist_view(inss) of
| ~GLnil () => inss
| ~GLcons (ins, inss2) =>
  (
    case+
    instr_node_view(ins.instr_node())
    of // case+
    | ~ATSINSstore_con1_tag
        (tmp, tag) => let
        val () = opt := gopt_some(tag) in inss2
      end // end of [ATSINSstore_con1_tag]
    | v0 (*non-ATSINSstore_con1_tag*) => (instr_node_view_free(v0); inss)
  )
) : instrlst
//
val d0es = getarglst (inss)
//
val () = emit_nspc (out, ind)
//
val isret =
  tmpvar_is_tmpret (tmp.i0dex_sym())
// end of [val]
//
val () =
if
not(isret)
then
{
//
val () =
  emit_tmpvar (out, tmp)
//
val () = emit_text (out, " = ")
//
} (* end of [val] *)
//
(*
val () = emit_SHARP (out)
val () = emit_symbol (out, name)
*)
val () = emit_LBRACE (out)
val () = emit_tysum_d0explst (out, opt, d0es)
val () = emit_RBRACE (out)
//
in
  // nothing
end // end of [emit2_ATSINSmove_con1]

(* ****** ****** *)

implement
emit2_ATSINSmove_boxrec
  (out, ind, ins0) = let
//
fun
getarglst
(
  inss: instrlst
) : d0explst =
(
case+ glist_view(inss) of
| ~GLnil () => glist_nil ()
| ~GLcons (ins, inss) => let
    val-~ATSINSstore_boxrec_ofs(_, _, _, d0e) = instr_node_view(ins.instr_node())
    val d0es = getarglst (inss)
  in
    glist_cons (d0e, d0es)
  end // end of [list_cons]
)
//
val-~ATSINSmove_boxrec(inss) = instr_node_view(ins0.instr_node())
//
val-~GLcons(ins, inss) = glist_view(inss)
val-~ATSINSmove_boxrec_new(tmp, _) = instr_node_view(ins.instr_node())
//
val d0es = getarglst (inss)
//
val () = emit_nspc (out, ind)
//
val isret =
  tmpvar_is_tmpret (tmp.i0dex_sym())
// end of [val]
//
val () =
if
not(isret)
then
{
//
val () =
  emit_tmpvar (out, tmp)
//
val () = emit_text (out, " = ")
//
} (* end of [val] *)
//
(*
val () = emit_SHARP (out)
val () = emit_symbol (out, name)
*)
val () = emit_LBRACE (out)
val () = emit_tyrec_d0explst (out, d0es)
val () = emit_RBRACE (out)
//
in
  // nothing
end // end of [emit2_ATSINSmove_boxrec]

(* ****** ****** *)
//
// HX-2026-10:
// flat records are represented as boxed ones
//
implement
emit2_ATSINSmove_fltrec
  (out, ind, ins0) = let
//
fun
getarglst
(
  inss: instrlst
) : d0explst =
(
case+ glist_view(inss) of
| ~GLnil () => glist_nil ()
| ~GLcons (ins, inss) => let
    val-~ATSINSstore_fltrec_ofs(_, _, _, d0e) = instr_node_view(ins.instr_node())
    val d0es = getarglst (inss)
  in
    glist_cons (d0e, d0es)
  end // end of [list_cons]
)
//
val-~ATSINSmove_fltrec(inss) = instr_node_view(ins0.instr_node())
//
val-~ATSINSstore_fltrec_ofs(tmp, _, _, _) = instr_node_view((glist_head(inss)).instr_node())
//
val d0es = getarglst (inss)
//
val () = emit_nspc (out, ind)
//
val isret =
  tmpvar_is_tmpret (tmp.i0dex_sym())
// end of [val]
//
val () =
if
not(isret)
then
{
//
val () =
  emit_tmpvar (out, tmp)
//
val () = emit_text (out, " = ")
//
} (* end of [val] *)
//
(*
val () = emit_SHARP (out)
val () = emit_symbol (out, name)
*)
val () = emit_LBRACE (out)
val () = emit_tyrec_d0explst (out, d0es)
val () = emit_RBRACE (out)
//
in
  // nothing
end // end of [emit2_ATSINSmove_fltrec]

(* ****** ****** *)

implement
emit2_ATSINSmove_delay
  (out, ind, ins0) = let
//
val-
~ATSINSmove_delay
  (tmp, s0e, thunk) = instr_node_view(ins0.instr_node())
//
val () = emit_nspc (out, ind)
//
val isret =
  tmpvar_is_tmpret (tmp.i0dex_sym())
// end of [val]
//
val () =
if
not(isret)
then
{
//
val () =
  emit_tmpvar (out, tmp)
//
val () = emit_text (out, " = ")
//
} (* end of [val] *)
//
val () =
  emit_text (out, "?ATSPMVlazyval")
val () =
(
  emit_LPAREN (out); emit_d0exp (out, thunk); emit_RPAREN (out)
) (* end of [val] *)
//
in
  // nothing
end // end of [emit2_ATSINSmove_delay]

(* ****** ****** *)

implement
emit2_ATSINSmove_lazyeval
  (out, ind, ins0) = let
//
val-
~ATSINSmove_lazyeval
  (tmp, s0e, lazyval) = instr_node_view(ins0.instr_node())
//
val () = emit_nspc (out, ind)
//
val isret =
  tmpvar_is_tmpret (tmp.i0dex_sym())
// end of [val]
//
val () =
if
not(isret)
then
{
//
val () =
  emit_tmpvar (out, tmp)
//
val () = emit_text (out, " = ")
//
} (* end of [val] *)
//
val () =
  emit_text (out, "?ATSPMVlazyval_eval")
val () =
(
  emit_LPAREN (out); emit_d0exp (out, lazyval); emit_RPAREN (out)
) (* end of [val] *)
//
in
  // nothing
end // end of [emit2_ATSINSmove_lazyeval]

(* ****** ****** *)
//
// HX-2026-10: linear lazy values ($ldelay)
//
implement
emit2_ATSINSmove_ldelay
  (out, ind, ins0) = let
//
val-
~ATSINSmove_ldelay
  (tmp, s0e, thunk) = instr_node_view(ins0.instr_node())
//
val () = emit_nspc (out, ind)
//
val isret =
  tmpvar_is_tmpret (tmp.i0dex_sym())
// end of [val]
//
val () =
if
not(isret)
then
{
//
val () =
  emit_tmpvar (out, tmp)
//
val () = emit_text (out, " = ")
//
} (* end of [val] *)
//
val () = emit_d0exp (out, thunk)
//
in
  // nothing
end // end of [emit2_ATSINSmove_ldelay]

(* ****** ****** *)

implement
emit2_ATSINSmove_llazyeval
  (out, ind, ins0) = let
//
val-
~ATSINSmove_llazyeval
  (tmp, s0e, lazyval) = instr_node_view(ins0.instr_node())
//
val () = emit_nspc (out, ind)
//
val isret =
  tmpvar_is_tmpret (tmp.i0dex_sym())
// end of [val]
//
val () =
if
not(isret)
then
{
//
val () =
  emit_tmpvar (out, tmp)
//
val () = emit_text (out, " = ")
//
} (* end of [val] *)
//
val () =
  emit_text (out, "?ATSPMVllazyval_eval")
val () =
(
  emit_LPAREN (out); emit_d0exp (out, lazyval); emit_RPAREN (out)
) (* end of [val] *)
//
in
  // nothing
end // end of [emit2_ATSINSmove_llazyeval]

(* ****** ****** *)
//
#define
ATSEXTCODE_BEG "%%\n%% ATSextcode_beg()\n%%"
#define
ATSEXTCODE_END "%%\n%% ATSextcode_end()\n%%"
//
(* ****** ****** *)

implement
emit_d0ecl
  (out, d0c) = let
in
//
case+
d0ecl_node_view(d0c.d0ecl_node())
of // case+
//
| ~D0Cinclude _ => ()
//
| ~D0Cifdef _ => ()
| ~D0Cifndef _ => ()
//
| ~D0Ctypedef
    (id, def) => let
(*
    val () =
      emit_typedef(out, id, def)
    // end of [val]
*)
  in
(*
    typedef_insert (id.i0dex_sym(), def)
*)
  end // end of [D0Ctypedef]
//
| ~D0Cassume (id) =>
  {
    val () = emit_ENDL (out)
    val () =
      emit_text (out, "%% ATSassume(")
    val () = (
      emit_i0de (out, id); emit_text (out, ")\n")
    ) (* end of [val] *)
  }
//
| ~D0Cdyncst_mac _ => ()
//
| ~D0Cdyncst_extfun _ => ()
//
| ~D0Cdyncst_valdec _ => ()
//
| ~D0Cdyncst_valimp
    (id, s0e) => {
    val () = emit_ENDL (out)
    val () = (
      emit_text (out, "var "); emit_i0de (out, id)
    ) (* end of [val] *)
    val () = emit_text (out, "\n")
  }
//
| ~D0Cextcode(toks) =>
  {
    val () = emit_ENDL (out)
    val () =
      emit_text (out, ATSEXTCODE_BEG)
    // end of [val]
    val () = emit_extcode (out, toks) // HX: verbatim output
    val () =
      emit_text (out, ATSEXTCODE_END)
    // end of [val]
    val ((*void*)) = emit_newline (out)
  } (* end of [D0Cextcode] *)
//
| ~D0Cstatmp(tmp, opt) =>
  {
    val () = emit_ENDL (out)
    val () = (
      case+ gopt_view(opt) of
      | ~GOsome _ => () | ~GOnone () => emit_text(out, "/*\n")
    ) (* end of [val] *)
    val () = (
      emit_text (out, "var "); emit_tmpvar (out, tmp); emit_ENDL (out)
    ) (* end of [val] *)
    val () = (
      case+ gopt_view(opt) of
      | ~GOsome _ => () | ~GOnone () => emit_text(out, "*/\n")
    ) (* end of [val] *)
  } (* end of [D0Cstatmp] *)
//
| ~D0Cfundecl (fk, f0d) => emit_f0decl (out, f0d)
//
| ~D0Cclosurerize
    (fl, env, arg, res) =>
  {
    val () = emit_closurerize (out, fl, env, arg, res)
  }
//
| ~D0Cdynloadflag_init
    (flag) => (
//
// HX-2015-05-22:
// it is skipped as Erlang does not have a link-time!
//
  ) (* end of [D0Cdynloadflag_init] *)
//
| ~D0Cdynloadflag_minit
    (flag) => (
    emit_text (out, "%% dynloadflag_minit\n");
    emit_text (out, "var "); emit_tmpvar (out, flag); emit_text (out, " = 0;\n")
  ) (* end of [D0Cdynloadflag_minit] *)
//
| ~D0Cdynexn_dec(idexn) =>
  (
    emit_text(out, "%% dynexn_dec("); emit_i0de(out, idexn); emit_text(out, ")\n")
  ) (* end of [D0Cdynexn_dec] *)
| ~D0Cdynexn_extdec(idexn) =>
  (
    emit_text(out, "%% dynexn_extdec("); emit_i0de(out, idexn); emit_text(out, ")\n")
  ) (* end of [D0Cdynexn_extdec] *)
| ~D0Cdynexn_initize(idexn, fullname) =>
  (
    emit_text(out, "%% dynexn_initize("); emit_i0de(out, idexn); emit_text(out, ")\n")
  ) (* end of [D0Cdynexn_initize] *)
//
end // end of [emit_d0ecl]

(* ****** ****** *)
//
extern
fun
emit_f0ide
  : emit_type (i0de) = "ext#atscc2erl_emit_f0ide"
extern
fun
emit_flabel
  : emit_type (label) = "ext#atscc2erl_emit_flabel"
//
(* ****** ****** *)
//
extern
fun emit_f0arg : emit_type (f0arg)
extern
fun emit_f0marg : emit_type (f0marg)
extern
fun emit_f0head : emit_type (f0head)
//
extern
fun emit_f0headbd : emit_type (f0head)
extern
fun emit_f0headhd : emit_type (f0head)
//
extern
fun emit_f0body : emit_type (f0body)
extern
fun emit_f0body_0 : emit_type (f0body)
extern
fun emit_f0body_tlcal : emit_type (f0body)
extern
fun emit_f0body_tlcal2 : emit_type (f0body)
//
(* ****** ****** *)

implement
emit_f0arg
  (out, f0a) = let
(*
val () =
println!("emit_f0arg: f0a = ", f0a)
*)
in
//
case+
f0arg_node_view(f0a.f0arg_node())
of // case+
//
| ~F0ARGnone _ => emit_text(out, "__NONE__")
| ~F0ARGsome(arg, s0e) => emit_tmpvar(out, arg)
//
end // end of [emit_f0arg]

(* ****** ****** *)

implement
emit_f0marg
  (out, f0ma) = let
//
fun
loop
(
  out: FILEref, f0as: f0arglst, i: int
) : void =
(
case+ glist_view(f0as) of
| ~GLnil() => ()
| ~GLcons(f0a, f0as) => let
    val () =
      if i > 0 then emit_text(out, ", ")
    // end of [val]
  in
    emit_f0arg(out, f0a); loop(out, f0as, i+1)
  end // end of [list_cons]
)
//
in
  loop(out, f0ma.f0marg_node(), 0)
end // end of [emit_f0marg]

(* ****** ****** *)

implement
emit_f0head
  (out, fhd) = let
in
//
case+
f0head_node_view(fhd.f0head_node())
of // case+
| ~F0HEAD
    (fid, f0ma, res) =>
  {
//
    val () = emit_f0ide (out, fid)
//
    val () = emit_LPAREN (out)
    val () = emit_f0marg (out, f0ma)
    val () = emit_RPAREN (out)
//
  }
//
end // end of [emit_f0head]

(* ****** ****** *)

implement
emit_f0headbd
  (out, fhd) = let
in
//
case+
f0head_node_view(fhd.f0head_node())
of // case+
| ~F0HEAD
    (fid, f0ma, res) =>
  {
//
    val () =
    (
      emit_f0ide(out, fid); emit_text(out, "__");
    ) (* end of [val] *)
//
    val () = emit_LPAREN(out)
//
    val () =
    (
      emit_text(out, "1");
      if glist_is_cons(f0ma.f0marg_node())
        then (emit_text(out, ", "); emit_f0marg(out, f0ma))
      // end of [if]
    ) (* end of [val] *)
//
    val () = emit_text (out, ").\n")
//
  } (* F0HEAD *)
//
end // end of [emit_f0headbd]

implement
emit_f0headhd
  (out, fhd) = let
in
//
case+
f0head_node_view(fhd.f0head_node())
of // case+
| ~F0HEAD
    (fid, f0ma, res) =>
  {
//
    val () =
    (
      emit_f0ide(out, fid); emit_text(out, "__");
    ) (* end of [val] *)
//
    val () = emit_LPAREN(out)
    val () =
    (
      emit_text(out, "Funlab");
      if glist_is_cons(f0ma.f0marg_node())
        then (emit_text(out, ", "); emit_f0marg(out, f0ma))
      // end of [if]
    ) (* end of [val] *)
//
    val () = emit_RPAREN (out)
//
  } (* F0HEAD *)
//
end // end of [emit_f0headhd]

(* ****** ****** *)

implement
emit_f0body
  (out, fbody) = let
//
val k0 = f0body_classify(fbody)
val () = the_funbodyknd_set(k0)
(*
//
val () =
println!
  ("emit_f0body: knd = ", k0)
//
*)
//
val () = the_Casefunx_reset ()
//
val
tmpdecs =
f0body_get_tmpdeclst(fbody)
val () = the_tmpdeclst_set(tmpdecs)
//
val
inss_body =
f0body_get_bdinstrlst(fbody)
val () = the_funbodylst_set(inss_body)
//
val () = emit_text (out, "%{\n")
//
val () = emit_text (out, "%%\n")
val () = emit_text (out, "%% knd = ")
val () = (emit_int (out, k0); emit_ENDL (out))
//
val () =
  emit_tmpdeclst_initize (out, tmpdecs)
//
val () =
if k0 > 0 then
{
//
val () = emit_text (out, "%% var Funlab_erl\n")
//
} (* end of [if] *) // end of [val]
//
val () = emit_text (out, "%% var Tmplab, Tmplab_erl\n")
//
val () = emit_text (out, "%%\n")
//
val () = (
//
case+ k0 of
| 0 => emit_f0body_0(out, fbody)
| 1 => emit_f0body_tlcal(out, fbody)
| 2 => emit_f0body_tlcal2(out, fbody)
| _ => let val () = assertloc(false) in (*nothing*) end
//
) : void // end of [val]
//
val () = emit_text (out, "%} // end-of-function\n")
//
in
  // nothing
end (* end of [emit_f0body] *)

(* ****** ****** *)

implement
emit_f0body_0
  (out, fbody) = let
//
fun
auxlst
(
  out: FILEref, i: int, inss: instrlst
) : void =
(
case+ glist_view(inss) of
| ~GLnil () => ()
| ~GLcons
    (ins0, inss1) => let
    val-~GLcons (ins1, inss2) = glist_view(inss1)
//
    val () =
      if i > 0 then emit_ENDL (out)
    // end of [val]
//
    val () =
      emit2_ATSfunbodyseq(out, 2(*ind*), ins0)
    // end of [val]
(*
    val ((*ret*)) = emit2_instr_ln (out, 2(*ind*), ins1)
*)
//
  in
    auxlst (out, i+1, inss2)
  end // end of [list_cons]
//
) (* end of [auxlst] *)
//
in
//
case+
f0body_node_view(fbody.f0body_node())
of // case+
//
| ~F0BODY (tds, inss) =>
  {
    val () = auxlst (out, 0(*i*), inss)
  }
//
end // end of [emit_f0body_0]

(* ****** ****** *)

implement
emit_f0body_tlcal
  (out, fbody) = let
//
fun
auxlst
(
  out: FILEref, inss: instrlst
) : void =
(
case+ glist_view(inss) of
| ~GLnil () => ()
| ~GLcons
    (ins0, inss1) => let
    val-~GLcons (ins1, inss2) = glist_view(inss1)
//
    val () =
    emit2_ATSfunbodyseq (out, 4(*ind*), ins0)
//
    val () = emit_nspc (out, 4(*ind*))
    val () =
    emit_text
    (
      out, "%% if (Funlab_erl > 0) continue; else"
    ) (* end of [val] *)
    val () = emit2_instr_ln (out, 1(*ind*), ins1)
//
    val () = emit_nspc (out, 2(*ind*))
    val () = emit_text (out, "%} // endwhile-fun\n")
//
  in
    auxlst (out, inss2(*nil*))
  end // end of [list_cons]
//
) (* end of [auxlst] *)
//
val () = emit_nspc (out, 2(*ind*))
val () = emit_text (out, "%while(true) {\n")
val () = emit_nspc (out, 4(*ind*))
val () = emit_text (out, "%% Funlab_erl = 0;\n")
//
val () =
(
case+
f0body_node_view(fbody.f0body_node())
of // case+
//
| ~F0BODY (tds, inss) => auxlst (out, inss)
//
) (* end of [val] *)
//
in
  // nothing
end // end of [emit_f0body_tlcal]

(* ****** ****** *)
//
extern
fun
emit_the_funbodylst
  (out: FILEref): void
//
implement
emit_the_funbodylst
  (out) = let
//
fun auxfun
(
  out: FILEref
, ins0: instr, ins1: instr, i: int
) : void = let
//
val-~ATSfunbodyseq(inss) = instr_node_view(ins0.instr_node())
//
val-~GLcons (ins_fl, inss) = glist_view(inss)
val-~ATSINSflab (fl) = instr_node_view(ins_fl.instr_node())
//
val () = emit_nspc (out, 6)
val () =
(
  emit_text (out, "%case ");
  emit_int (out, i); emit_text (out, ": {\n")
)
val () = emit_nspc (out, 6)
val () =
(
  emit_int (out, i); emit_text(out, " ->\n")
)
//
val () = emit_nspc (out, 8)
val () = emit_text (out, "%% Funlab_erl = 0;\n")
val () = emit2_instrlst_end (out, 8(*ind*), inss, ";\n")
//
val () = emit_nspc (out, 8)
val () =
emit_text
(
  out, "%% if (Funlab_erl > 0) continue; else"
) (* end of [val] *)
val () = emit2_instr_ln (out, 1(*ind*), ins1)
//
val () = emit_nspc (out, 6)
val () = emit_text (out, "%} // end-of-case\n")
//
in
  // nothing
end // end of [auxfun]
//
fun auxlst
(
  out: FILEref, inss: instrlst, i: int
) : void =
(
case+ glist_view(inss) of
| ~GLnil () => ()
| ~GLcons _ => let
    val-~GLcons (ins0, inss) = glist_view(inss)
    val-~GLcons (ins1, inss) = glist_view(inss)
    val () = auxfun (out, ins0, ins1, i)
  in
    auxlst (out, inss, i+1)
  end // end of [auxlst]
) (* end of [auxlst] *)
//
in
  auxlst (out, the_funbodylst_get(), 1(*first*))
end // end of [emit_the_funbodylst]
//
(* ****** ****** *)

implement
emit_f0body_tlcal2
  (out, fbody) = let
//
val () = emit_nspc (out, 2(*ind*))
val () = emit_text (out, "%% Funlab_erl = 1;")
//
val () = emit_ENDL (out)
val () = emit_nspc (out, 2(*ind*))
val () = emit_text (out, "%while(true) {")
//
val () = emit_ENDL (out)
val () = emit_nspc (out, 4(*ind*))
val () = emit_text (out, "%switch(Funlab_erl) {\n")
val () = emit_nspc (out, 4(*ind*))
val () = emit_text (out, "case Funlab of\n")
//
val () = emit_the_funbodylst(out)
//
val () = emit_nspc (out, 6(*ind*))
val () = emit_text (out, "_ -> atscc2erl_caseof_deadcode(?FILE, ?LINE)\n")
val () = emit_nspc (out, 4(*ind*))
val () = emit_text (out, "end. %} // end-of-switch\n")
//
val () = emit_nspc (out, 2(*ind*))
val ((*closing*)) = emit_text (out, "%} // endwhile-fun\n")
//
in
  // nothing
end // end of [emit_f0body_tlcal2]

(* ****** ****** *)

implement
emit_f0decl
  (out, fdec) = let
//
(*
val () = println!("emit_f0decl")
*)
//
in
//
case+
f0decl_node_view(fdec.f0decl_node())
of // case+
| ~F0DECLnone (fhd) =>
  {
    val () =
      the_f0headopt_set(fhd)
    // end of [val]  
  }
| ~F0DECLsome (fhd, fbody) =>
  {
//
    val () =
      the_f0headopt_set(fhd)
    // end of [val]
//
    val () =
    emit_text (out, "\n%%fun%%\n")
//
    val () = emit_f0head(out, fhd)
    val k0 = f0body_classify(fbody)
//
    val () = emit_text (out, " ->\n")
//
    val () =
    if k0 >= 2 then
    (
      emit_nspc(out, 2); emit_f0headbd(out, fhd)
    ) (* end of [val] *)
//
    val () =
    if k0 >= 2 then
    (
      emit_f0headhd(out, fhd); emit_text(out, " ->\n")
    ) (* end of [val] *)
//
    val () = emit_f0body(out, fbody)
//
    val ((*endfun*)) = emit_newline(out)
//
  } (* end of [F0DECLsome] *)
//
end // end of [emit_f0decl]

(* ****** ****** *)

implement
emit_toplevel
  (out, d0cs) = let
//
fun
aux1
(
  d0c: d0ecl
) : void = (
//
case+
d0ecl_node_view(d0c.d0ecl_node())
of // case+
//
| ~D0Ctypedef
    (id, def) =>
  (
    typedef_insert (id.i0dex_sym(), def)
  )
//
| ~D0Cfundecl
    (fk, f0d) => 
  (
    case+
    f0decl_node_view(f0d.f0decl_node())
    of // case+
    | ~F0DECLnone (fhd) => f0head_insert(fhd)
    | ~F0DECLsome (fhd, _) => f0head_insert(fhd)
  )
//
| v0(* rest-of-D0C *) => (d0ecl_node_view_free(v0); ())
//
) (* end of [aux1] *)
//
fun
auxlst1
(
  d0cs: d0eclist
) : void =
(
//
case+ glist_view(d0cs) of
| ~GLnil () => ()
| ~GLcons
    (d0c, d0cs) =>
  (
    aux1 (d0c); auxlst1 (d0cs)
  ) // end of [list_cons]
//
)
//
fun
auxlst2
(
  out: FILEref, d0cs: d0eclist
) : void =
(
//
case+ glist_view(d0cs) of
| ~GLnil () => ()
| ~GLcons
    (d0c, d0cs) => let
    val () =
      emit_d0ecl (out, d0c)
    // end of [val]
  in
    auxlst2 (out, d0cs)
  end // end of [list_cons]
//
)
//
val () = auxlst1 (d0cs)
val () = auxlst2 (out, d0cs)
//
in
  // nothing
end // end of [emit_toplevel]

(* ****** ****** *)

(* end of [atscc2erl_emit2.dats] *)
