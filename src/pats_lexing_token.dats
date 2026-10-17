(***********************************************************************)
(*                                                                     *)
(*                         Applied Type System                         *)
(*                                                                     *)
(***********************************************************************)

(*
** ATS/Postiats - Unleashing the Potential of Types!
** Copyright (C) 2011-2013 Hongwei Xi, ATS Trustful Software, Inc.
** All rights reserved
**
** ATS is free software;  you can  redistribute it and/or modify it under
** the terms of  the GNU GENERAL PUBLIC LICENSE (GPL) as published by the
** Free Software Foundation; either version 3, or (at  your  option)  any
** later version.
** 
** ATS is distributed in the hope that it will be useful, but WITHOUT ANY
** WARRANTY; without  even  the  implied  warranty  of MERCHANTABILITY or
** FITNESS FOR A PARTICULAR PURPOSE.  See the  GNU General Public License
** for more details.
** 
** You  should  have  received  a  copy of the GNU General Public License
** along  with  ATS;  see the  file COPYING.  If not, please write to the
** Free Software Foundation,  51 Franklin Street, Fifth Floor, Boston, MA
** 02110-1301, USA.
*)

(* ****** ****** *)
//
// Author: Hongwei Xi
// Authoremail: gmhwxi AT gmail DOT com
// Start Time: March, 2011
//
(* ****** ****** *)

#include "share/atspre_staload.hats"

(* ****** ****** *)

staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _(*arena*) = "libats/DATS/arena.dats"

(* ****** ****** *)

staload "./pats_basics.sats"
staload "./pats_lexing.sats"

(* ****** ****** *)

#include "./pats_lexing_token_gen_dats.hats"

(* ****** ****** *)

#include "./pats_basics.hats"

(* ****** ****** *)

implement DOT = token_node_T_DOT()
implement QMARK = token_node_T_IDENT_alp  "?"
implement PERCENT = token_node_T_IDENT_alp  "%"

(* ****** ****** *)

implement ABSTYPE = token_node_T_ABSTYPE  (TYPE_int)
implement ABST0YPE = token_node_T_ABSTYPE  (T0YPE_int)
implement ABSPROP = token_node_T_ABSTYPE  (PROP_int)
implement ABSVIEW = token_node_T_ABSTYPE  (VIEW_int)
implement ABSVIEWTYPE = token_node_T_ABSTYPE  (VIEWTYPE_int)
implement ABSVIEWT0YPE = token_node_T_ABSTYPE  (VIEWT0YPE_int)

implement CASE = token_node_T_CASE  (CK_case)
implement CASE_pos = token_node_T_CASE  (CK_case_pos)
implement CASE_neg = token_node_T_CASE  (CK_case_neg)

implement DATATYPE = token_node_T_DATATYPE  (TYPE_int)
implement DATAPROP = token_node_T_DATATYPE  (PROP_int)
implement DATAVIEW = token_node_T_DATATYPE  (VIEW_int)
implement DATAVTYPE = token_node_T_DATATYPE  (VIEWTYPE_int)

implement FIX = token_node_T_FIX  (TYPE_int)
implement FIXAT = token_node_T_FIX  (T0YPE_int)

implement FN = token_node_T_FUN  (FK_fn)
implement FNX = token_node_T_FUN  (FK_fnx)
implement FUN = token_node_T_FUN  (FK_fun)
//
implement PRFN = token_node_T_FUN  (FK_prfn)
implement PRFUN = token_node_T_FUN  (FK_prfun)
//
implement PRAXI = token_node_T_FUN  (FK_praxi)
//
implement CASTFN = token_node_T_FUN  (FK_castfn)

implement IMPLMNT = token_node_T_IMPLEMENT  (0)
implement IMPLEMENT = token_node_T_IMPLEMENT  (1)
implement PRIMPLMNT = token_node_T_IMPLEMENT  (~1)

implement INFIX = token_node_T_FIXITY  (FXK_infix)
implement INFIXL = token_node_T_FIXITY  (FXK_infixl)
implement INFIXR = token_node_T_FIXITY  (FXK_infixr)
implement PREFIX = token_node_T_FIXITY  (FXK_prefix)
implement POSTFIX = token_node_T_FIXITY  (FXK_postfix)

implement LAM = token_node_T_LAM  (TYPE_int)
implement LAMAT = token_node_T_LAM  (T0YPE_int)
implement LLAM = token_node_T_LAM  (VIEWTYPE_int)
implement LLAMAT = token_node_T_LAM  (VIEWT0YPE_int)

implement MACDEF = token_node_T_MACDEF  (0) // short form
implement MACRODEF = token_node_T_MACDEF  (1) // long form

(* ****** ****** *)

(*
//
implement REF = token_node_T_IDENT_alp  "ref"
//
implement
REFAT = token_node_T_REFAT  // HX: flattened ref
//
// HX-2015-12-10: 'ref@' is removed for now
//
*)

(* ****** ****** *)
//
// HX: for introducing tkinds
//
implement
TKINDEF = token_node_T_TKINDEF()
//
(* ****** ****** *)
//
implement PROP = token_node_T_IDENT_alp  "prop"
implement VIEW = token_node_T_IDENT_alp  "view"
//
implement TYPE = token_node_T_IDENT_alp  "type"
implement TFLT = token_node_T_IDENT_alp  "tflt"
implement TBOX = token_node_T_IDENT_alp  "tbox"
//
implement VTYPE = token_node_T_IDENT_alp  "vtype"
implement VTBOX = token_node_T_IDENT_alp  "vtbox"
implement VTFLT = token_node_T_IDENT_alp  "vtflt"
//
implement VIEWTYPE = token_node_T_IDENT_alp  "viewtype"
(*
implement VIEWTBOX = token_node_T_IDENT_alp  "viewtbox"
implement VIEWTFLT = token_node_T_IDENT_alp  "viewtflt"
*)
//
(* ****** ****** *)
//
(*
implement TYPE = token_node_T_TYPE  (TYPE_int)
*)
implement TYPE_pos = token_node_T_TYPE  (TYPE_pos_int)
implement TYPE_neg = token_node_T_TYPE  (TYPE_neg_int)
//
implement T0YPE = token_node_T_TYPE  (T0YPE_int)
implement T0YPE_pos = token_node_T_TYPE  (T0YPE_pos_int)
implement T0YPE_neg = token_node_T_TYPE  (T0YPE_neg_int)
//
(* ****** ****** *)
//
(*
implement TYPES = token_node_T_IDENT_alp  "types" 
implement TYPES_pos = token_node_T_TYPE  (TYPES_pos_int)
implement TYPES_neg = token_node_T_TYPE  (TYPES_neg_int)
*)
//
(* ****** ****** *)
//
(*
implement PROP = token_node_T_TYPE  (PROP_int)
*)
implement PROP_pos = token_node_T_TYPE  (PROP_pos_int)
implement PROP_neg = token_node_T_TYPE  (PROP_neg_int)
//
(* ****** ****** *)
//
(*
implement VIEW = token_node_T_TYPE  (VIEW_int)
*)
implement VIEWAT = token_node_T_VIEWAT() // view@
implement VIEW_pos = token_node_T_TYPE  (VIEW_pos_int)
implement VIEW_neg = token_node_T_TYPE  (VIEW_neg_int)
//
(* ****** ****** *)
(*
implement VIEWTYPE = token_node_T_TYPE  (VIEWTYPE_int)
*)
implement VIEWTYPE_pos = token_node_T_TYPE  (VIEWTYPE_pos_int)
implement VIEWTYPE_neg = token_node_T_TYPE  (VIEWTYPE_neg_int)
//
implement VIEWT0YPE = token_node_T_TYPE  (VIEWT0YPE_int)
implement VIEWT0YPE_pos = token_node_T_TYPE  (VIEWT0YPE_pos_int)
implement VIEWT0YPE_neg = token_node_T_TYPE  (VIEWT0YPE_neg_int)

(* ****** ****** *)

implement PROPDEF = token_node_T_TYPEDEF  (PROP_int)
implement VIEWDEF = token_node_T_TYPEDEF  (VIEW_int)

implement TYPEDEF = token_node_T_TYPEDEF  (T0YPE_int)
implement VIEWTYPEDEF = token_node_T_TYPEDEF  (VIEWT0YPE_int)

(* ****** ****** *)

implement VAL = token_node_T_VAL  (VK_val)
implement VAL_pos = token_node_T_VAL  (VK_val_pos)
implement VAL_neg = token_node_T_VAL  (VK_val_neg)
(*
implement MCVAL = token_node_T_VAL  (VK_mcval)
*)
implement PRVAL = token_node_T_VAL  (VK_prval)

implement VAR = token_node_T_VAR  (0)
implement PRVAR = token_node_T_VAR  (1)

implement FOR = token_node_T_FOR()
implement FORSTAR = token_node_T_FORSTAR()
implement WHILE = token_node_T_WHILE()
implement WHILESTAR = token_node_T_WHILESTAR()

implement WITHTYPE = token_node_T_WITHTYPE  (T0YPE_int)
implement WITHPROP = token_node_T_WITHTYPE  (PROP_int)
implement WITHVIEW = token_node_T_WITHTYPE  (VIEW_int)
implement WITHVIEWTYPE = token_node_T_WITHTYPE  (VIEWT0YPE_int)

(* ****** ****** *)

implement
ADDR = token_node_T_IDENT_alp  "addr"
implement ADDRAT = token_node_T_ADDRAT()
implement
FOLD = token_node_T_IDENT_alp  "fold"
implement FOLDAT = token_node_T_FOLDAT()
implement
FREE = token_node_T_IDENT_alp  "free"
implement FREEAT = token_node_T_FREEAT()

(* ****** ****** *)

implement DLRDELAY = token_node_T_DLRDELAY (TYPE_int)
implement DLRLDELAY = token_node_T_DLRDELAY (VIEWTYPE_int)

(* ****** ****** *)
//
implement DLREFFMASK = token_node_T_DLREFFMASK()
//
implement DLREFFMASK_NTM = token_node_T_DLREFFMASK_ARG  (0)
implement DLREFFMASK_EXN = token_node_T_DLREFFMASK_ARG  (1)
implement DLREFFMASK_REF = token_node_T_DLREFFMASK_ARG  (2)
implement DLREFFMASK_WRT = token_node_T_DLREFFMASK_ARG  (3)
implement DLREFFMASK_ALL = token_node_T_DLREFFMASK_ARG  (4)
//
(* ****** ****** *)

implement
DLRLST = token_node_T_DLRLST  (~1) // unspecified
implement
DLRLST_T = token_node_T_DLRLST  (TYPE_int)
implement
DLRLST_VT = token_node_T_DLRLST  (VIEWTYPE_int)

(* ****** ****** *)

implement
DLRREC =
token_node_T_DLRREC (TYRECKIND_box) // unspecified
implement
DLRREC_T = token_node_T_DLRREC  (TYRECKIND_box_t)
implement
DLRREC_VT = token_node_T_DLRREC  (TYRECKIND_box_vt)

implement
DLRTUP =
token_node_T_DLRTUP (TYTUPKIND_box) // unspecified
implement
DLRTUP_T = token_node_T_DLRTUP  (TYTUPKIND_box_t)
implement
DLRTUP_VT = token_node_T_DLRTUP  (TYTUPKIND_box_vt)

(* ****** ****** *)

implement
DLRVCOPYENV_V = token_node_T_DLRVCOPYENV  (VIEW_int)
implement
DLRVCOPYENV_VT = token_node_T_DLRVCOPYENV  (VIEWTYPE_int)

(* ****** ****** *)

implement
INTZERO = token_node_T_INT  (10(*base*), "0", 0u(*sfx*))

(* ****** ****** *)

implement
tnode_is_comment
  (x) = case+ x of
  | _ when token_node_is_T_COMMENT_line (x) => true
  | _ when token_node_is_T_COMMENT_rest (x) => true
  | _ when token_node_is_T_COMMENT_block (x) => true
  | _ (*non-T_COMMENT_...*)=> false
// end of [tnode_is_comment]

(* ****** ****** *)

local
//
staload
"libats/SATS/hashtbl_linprb.sats"
staload _(*anon*) =
"libats/DATS/hashtbl_linprb.dats"
staload "libats/SATS/hashfun.sats"
staload _(*anon*) =
"libats/DATS/hashfun.dats"
//
#define HASHTBLSZ 193
//
typedef key = string
typedef itm = tnode
//
implement
hash_key<key> (x) =
  string_hash_multiplier (33UL, 5381UL, x)
implement
equal_key_key<key>
  (x1, x2) = (compare (x1, x2) = 0)
//
val the_tnodetbl =
  $UN.castvwtp0{ptr}(hashtbl_make_nil<key,itm> (i2sz(HASHTBLSZ)))
//
fun insert (
  k: string, i: tnode
) : void = () where {
  val tbl = $UN.castvwtp0{hashtbl(key,itm)}(the_tnodetbl)
  val opt = hashtbl_insert_opt<key,itm> (tbl, k, i)
  val () = (case+ opt of ~Some_vt _ => () | ~None_vt () => ())
  val _ = $UN.castvwtp0{ptr}(tbl)
} // end of [insert]
//
macdef ins (k, i) = insert (,(k), ,(i))
//
val () = ins ("@", token_node_T_AT())
val () = ins ("!", token_node_T_BANG())
val () = ins ("|", token_node_T_BAR())
val () = ins ("`", token_node_T_BQUOTE())
val () = ins (":", token_node_T_COLON())
val () = ins ("$", token_node_T_DOLLAR())
val () = ins (".", token_node_T_DOT())
val () = ins ("=", token_node_T_EQ())
val () = ins ("#", token_node_T_HASH())
val () = ins ("~", token_node_T_TILDE())
//
val () = ins ("..", token_node_T_DOTDOT())
val () = ins ("...", token_node_T_DOTDOTDOT())
//
val () = ins ("=>", token_node_T_EQGT())
val () = ins ("=<", token_node_T_EQLT())
val () = ins ("=<>", token_node_T_EQLTGT())
val () = ins ("=/=>", token_node_T_EQSLASHEQGT())
val () = ins ("=>>", token_node_T_EQGTGT())
val () = ins ("=/=>>", token_node_T_EQSLASHEQGTGT())
//
val () = ins ("<", token_node_T_LT()) // opening a tmparg
val () = ins (">", token_node_T_GT()) // closing a tmparg
//
val () = ins ("><", token_node_T_GTLT())
//
val () = ins (".<", token_node_T_DOTLT())
val () = ins (">.", token_node_T_GTDOT())
//
val () = ins (".<>.", token_node_T_DOTLTGTDOT())
//
val () = ins ("->", token_node_T_MINUSGT())
val () = ins ("-<", token_node_T_MINUSLT())
val () = ins ("-<>", token_node_T_MINUSLTGT())
//
(*
val () = ins (":<", token_node_T_COLONLT())
*)
//
val () = ins ("absprop", ABSPROP)
val () = ins ("absview", ABSVIEW)
//
val () = ins ("abstype", ABSTYPE)
val () = ins ("abst0ype", ABST0YPE)
//
val () = ins ("absvtype", ABSVIEWTYPE)
val () = ins ("absviewtype", ABSVIEWTYPE)
//
val () = ins ("absvt0ype", ABSVIEWT0YPE)
val () = ins ("absviewt0ype", ABSVIEWT0YPE)
//
val () = ins ("abstbox", ABSTYPE)
val () = ins ("abstflt", ABST0YPE)
val () = ins ("abstflat", ABST0YPE)
val () = ins ("absvtbox", ABSVIEWTYPE)
val () = ins ("absvtflt", ABSVIEWT0YPE)
val () = ins ("absvtflat", ABSVIEWT0YPE)
//
(*
val () = ins ("#absprop", ABSPROP)
val () = ins ("#absview", ABSVIEW)
val () = ins ("#abstype", ABSTYPE)
val () = ins ("#abstbox", ABSTYPE)
val () = ins ("#abstflt", ABST0YPE)
*)
//
val () = ins ("assume", token_node_T_ASSUME())
val () = ins ("reassume", token_node_T_REASSUME())
//
val () = ins ("absimpl", token_node_T_ASSUME())
val () = ins ("absreimpl", token_node_T_REASSUME())
//
(*
val () = ins ("#absimpl", token_node_T_ASSUME())
val () = ins ("#absreimpl", token_node_T_REASSUME())
*)
//
val () = ins ("as", token_node_T_AS())
//
val () = ins ("and", token_node_T_AND())
//
val () = ins ("begin", token_node_T_BEGIN())
//
(*
val () = ins ("case", CASE)
*)
//
val () = ins ("classdec", token_node_T_CLASSDEC())
//
val () = ins ("datasort", token_node_T_DATASORT())
//
val () = ins ("datatype", DATATYPE)
val () = ins ("dataprop", DATAPROP)
val () = ins ("dataview", DATAVIEW)
val () = ins ("datavtype", DATAVTYPE)
val () = ins ("dataviewtype", DATAVTYPE)
//
val () = ins ("do", token_node_T_DO())
//
val () = ins ("end", token_node_T_END())
//
val () = ins ("extern", token_node_T_EXTERN())
val () = ins ("extype", token_node_T_EXTYPE())
val () = ins ("extvar", token_node_T_EXTVAR())
//
val () = ins ("exception", token_node_T_EXCEPTION())
//
val () = ins ("fn", FN) // non-recursive
val () = ins ("fnx", FNX) // mutual tail-rec.
val () = ins ("fun", FUN) // general-recursive
//
val () = ins ("prfn", PRFN)
val () = ins ("prfun", PRFUN)
//
val () = ins ("praxi", PRAXI)
val () = ins ("castfn", CASTFN)
//
val () = ins ("if", token_node_T_IF())
val () = ins ("then", token_node_T_THEN())
val () = ins ("else", token_node_T_ELSE())
//
val () = ins ("ifcase", token_node_T_IFCASE())
//
val () = ins ("in", token_node_T_IN())
//
val () = ins ("infix", INFIX)
val () = ins ("infixl", INFIXL)
val () = ins ("infixr", INFIXR)
val () = ins ("prefix", PREFIX)
val () = ins ("postfix", POSTFIX)
//
val () = ins ("implmnt", IMPLMNT) // 0
val () = ins ("implement", IMPLEMENT) // 1
//
val () = ins ("primplmnt", PRIMPLMNT) // ~1
val () = ins ("primplement", PRIMPLMNT) // ~1
//
val () = ins ("import", token_node_T_IMPORT()) // for importing packages
//
(*
val () = ins ("lam", LAM)
val () = ins ("llam", LLAM)
val () = ins ("fix", FIX)
*)
//
val () = ins ("let", token_node_T_LET())
//
val () = ins ("local", token_node_T_LOCAL())
//
val () = ins ("macdef", MACDEF)
val () = ins ("macrodef", MACRODEF)
//
val () = ins ("nonfix", token_node_T_NONFIX())
//
val () = ins ("symelim", token_node_T_SYMELIM())
val () = ins ("symintr", token_node_T_SYMINTR())
val () = ins ("symload", token_node_T_SYMLOAD())
val () = ins ("overload", token_node_T_SYMLOAD()) // first-used
val () = ins ("#symload", token_node_T_SYMLOAD()) // ATS-Xanadu
//
val () = ins ("of", token_node_T_OF())
val () = ins ("op", token_node_T_OP())
//
val () = ins ("rec", token_node_T_REC())
//
val () = ins ("sif", token_node_T_SIF())
val () = ins ("scase", token_node_T_SCASE())
//
val () = ins ("sortdef", token_node_T_SORTDEF())
(*
// HX: [sta] is now deprecated
*)
val () = ins ("sta", token_node_T_STACST())
(*
val () = ins ("dyn", token_node_T_DYNCST ) // not in use
*)
//
val () = ins ("stacst", token_node_T_STACST())
val () = ins ("stadef", token_node_T_STADEF())
val () = ins ("static", token_node_T_STATIC())
(*
val () = ins ("stavar", token_node_T_STAVAR )
*)
//
val () = ins ("try", token_node_T_TRY())
//
val () = ins ("tkindef", token_node_T_TKINDEF()) // HX-2012-05-23
//
(*
val () = ins ("type", TYPE)
*)
//
// HX-2019-01-17: ATS3/Xanadu
//
val () = ins ("sexpdef", token_node_T_STADEF())
(*
val () = ins ("#sexpdef", token_node_T_STADEF())
*)
//
val () = ins ("typedef", TYPEDEF)
val () = ins ("propdef", PROPDEF)
val () = ins ("viewdef", VIEWDEF)
val () = ins ("vwtpdef", VIEWTYPEDEF)
//
(*
val () = ins ("#typedef", TYPEDEF)
val () = ins ("#propdef", PROPDEF)
val () = ins ("#viewdef", VIEWDEF)
val () = ins ("#vwtpdef", VIEWTYPEDEF)
*)
//
val () = ins ("vtypedef", VIEWTYPEDEF)
val () = ins ("viewtypedef", VIEWTYPEDEF)
//
(*
val () = ins ("val", VAL)
*)
val () = ins ("prval", PRVAL)
//
val () = ins ("var", VAR)
val () = ins ("prvar", PRVAR)
//
val () = ins ("when", token_node_T_WHEN())
val () = ins ("where", token_node_T_WHERE())
//
(*
val () = ins ("for", token_node_T_FOR())
val () = ins ("while", token_node_T_WHILE())
*)
//
val () = ins ("with", token_node_T_WITH())
//
val () = ins ("withtype", WITHTYPE)
val () = ins ("withprop", WITHPROP)
val () = ins ("withview", WITHVIEW)
val () = ins ("withvtype", WITHVIEWTYPE)
val () = ins ("withviewtype", WITHVIEWTYPE)
//
val () = ins ("$delay", DLRDELAY)
val () = ins ("$ldelay", DLRLDELAY)
//
val () = ins ("$arrpsz", token_node_T_DLRARRPSZ())
val () = ins ("$arrptrsize", token_node_T_DLRARRPSZ())
//
val () = ins ("$tyrep", token_node_T_DLRTYREP())
val () = ins ("$d2ctype", token_node_T_DLRD2CTYPE())
//
val () = ins ("$effmask", DLREFFMASK)
val () = ins ("$effmask_ntm", DLREFFMASK_NTM)
val () = ins ("$effmask_exn", DLREFFMASK_EXN)
val () = ins ("$effmask_ref", DLREFFMASK_REF)
val () = ins ("$effmask_wrt", DLREFFMASK_WRT)
val () = ins ("$effmask_all", DLREFFMASK_ALL)
//
val () = ins ("$extern", token_node_T_DLREXTERN())
val () = ins ("$extkind", token_node_T_DLREXTKIND())
val () = ins ("$extype", token_node_T_DLREXTYPE())
val () = ins ("$extype_struct", token_node_T_DLREXTYPE_STRUCT())
//
val () = ins ("$extval", token_node_T_DLREXTVAL())
val () = ins ("$extfcall", token_node_T_DLREXTFCALL())
val () = ins ("$extmcall", token_node_T_DLREXTMCALL())
//
val () = ins ("$literal", token_node_T_DLRLITERAL())
//
val () = ins ("$myfilename", token_node_T_DLRMYFILENAME())
val () = ins ("$mylocation", token_node_T_DLRMYLOCATION())
val () = ins ("$myfunction", token_node_T_DLRMYFUNCTION())
//
val () = ins ("$lst", DLRLST)
val () = ins ("$lst_t", DLRLST_T)
val () = ins ("$lst_vt", DLRLST_VT)
val () = ins ("$list", DLRLST)
val () = ins ("$list_t", DLRLST_T)
val () = ins ("$list_vt", DLRLST_VT)
//
val () = ins ("$rec", DLRREC)
val () = ins ("$rec_t", DLRREC_T)
val () = ins ("$rec_vt", DLRREC_VT)
val () = ins ("$record", DLRREC)
val () = ins ("$record_t", DLRREC_T)
val () = ins ("$record_vt", DLRREC_VT)
//
val () = ins ("$tup", DLRTUP)
val () = ins ("$tup_t", DLRTUP_T)
val () = ins ("$tup_vt", DLRTUP_VT)
val () = ins ("$tuple", DLRTUP)
val () = ins ("$tuple_t", DLRTUP_T)
val () = ins ("$tuple_vt", DLRTUP_VT)
//
val () = ins ("$break", token_node_T_DLRBREAK())
val () = ins ("$continue", token_node_T_DLRCONTINUE())
//
val () = ins ("$raise", token_node_T_DLRRAISE())
//
val () = ins ("$vararg", token_node_T_DLRVARARG())
//
val () = ins ("$vcopyenv_v", DLRVCOPYENV_V)
val () = ins ("$vcopyenv_vt", DLRVCOPYENV_VT)
//
val () = ins ("$showtype", token_node_T_DLRSHOWTYPE())
//
val () = ins ("$tempenver", token_node_T_DLRTEMPENVER())
//
val () = ins ("$solver_assert", token_node_T_DLRSOLASSERT())
val () = ins ("$solver_verify", token_node_T_DLRSOLVERIFY())
//
val () = ins ("#if", token_node_T_SRPIF())
val () = ins ("#ifdef", token_node_T_SRPIFDEF())
val () = ins ("#ifndef", token_node_T_SRPIFNDEF())
//
val () = ins ("#then", token_node_T_SRPTHEN())
//
val () = ins ("#elif", token_node_T_SRPELIF())
val () = ins ("#elifdef", token_node_T_SRPELIFDEF())
val () = ins ("#elifndef", token_node_T_SRPELIFNDEF())
//
val () = ins ("#else", token_node_T_SRPELSE())
val () = ins ("#endif", token_node_T_SRPENDIF())
//
val () = ins ("#error", token_node_T_SRPERROR())
//
val () = ins ("#prerr", token_node_T_SRPPRERR()) // outpui to stderr
val () = ins ("#print", token_node_T_SRPPRINT()) // output to stdout
//
val () = ins ("#assert", token_node_T_SRPASSERT())
//
val () = ins ("#undef", token_node_T_SRPUNDEF())
val () = ins ("#define", token_node_T_SRPDEFINE())
//
val () = ins ("#include", token_node_T_SRPINCLUDE())
//
val () = ins ("staload", token_node_T_SRPSTALOAD())
val () = ins ("#staload", token_node_T_SRPSTALOAD())
//
val () = ins ("dynload", token_node_T_SRPDYNLOAD())
val () = ins ("#dynload", token_node_T_SRPDYNLOAD())
//
val () = ins ("#require", token_node_T_SRPREQUIRE())
//
val () = ins ("#pragma", token_node_T_SRPPRAGMA()) // HX: general pragma
val () = ins ("#codegen2", token_node_T_SRPCODEGEN2()) // for level-2 codegen
val () = ins ("#codegen3", token_node_T_SRPCODEGEN3()) // for level-3 codegen
//
// HX: end of special tokens
//
in (* in of [local] *)
//
implement
tnode_search (x) = let
//
  val tbl = $UN.castvwtp0{hashtbl(key,itm)}(the_tnodetbl)
  val opt = hashtbl_search_opt<key,itm> (tbl, x)
  val _ = $UN.castvwtp0{ptr}(tbl)
//
in
  case+ opt of
  | ~Some_vt (tn) => tn
  | ~None_vt ((*void*)) => token_node_T_NONE()
end // end of [tnode_search]
//
end // end of [local]

(* ****** ****** *)

(* end of [pats_lexing_token.dats] *)
