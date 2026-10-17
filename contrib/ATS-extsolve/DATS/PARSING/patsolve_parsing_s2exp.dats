(*
** ATS-extsolve:
** For solving ATS-constraints
** with external SMT-solvers
*)

(* ****** ****** *)

(*
** Author: Hongwei Xi
** Authoremail: gmhwxiATgmailDOTcom
** Start time: May, 2015
*)

(* ****** ****** *)

macdef
JAG(x0, i) = jsonval_array_get(,(x0), ,(i))

(* ****** ****** *)

extern
fun
parse_s2exp_node{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s2exp_node(l)

(* ****** ****** *)

implement
parse_s2exp
  (ar, tbls, jsnv0) = let
//
val s2t =
parse_s2rt
(
  ar, tbls
, jsonval_get_field_exn(jsnv0, "s2exp_srt")
)
val s2en =
parse_s2exp_node
(
  ar, tbls
, jsonval_get_field_exn(jsnv0, "s2exp_node")
)
//
in
  s2exp_make_node(ar, s2t, s2en)
end // end of [parse_s2exp]

(* ****** ****** *)

implement
parse_s2exp_node
  (ar, tbls, jsnv0) = let
//
val name = jsonval_get_name(jsnv0)
val x0 = jsonval_get_value(jsnv0)
//
macdef
s2exp(x) = parse_s2exp(ar, tbls, ,(x))
macdef
s2explst(x) = parse_s2explst(ar, tbls, ,(x))
macdef
s2varlst(x) = parse_s2varlst(ar, tbls, ,(x))
macdef
symbol(x) = parse_symbol(ar, tbls, ,(x))
//
in
//
case+ name of
| "S2Eint" =>
    s2exp_node_S2Eint(ar, parse_int(JAG(x0, 0)))
| "S2Eintinf" =>
    s2exp_node_S2Eintinf
      (ar, astring_make(ar, parse_string(JAG(x0, 0))))
    // s2exp_node_S2Eintinf
| "S2Ecst" => let
    val s2c =
      parse_s2cst(ar, tbls, JAG(x0, 0))
    // end of [val]
  in
    s2cst_incby1_nused(ar, s2c); s2exp_node_S2Ecst(ar, s2c)
  end // end of [S2Ecst]
| "S2Evar" =>
    s2exp_node_S2Evar(ar, parse_s2var(ar, tbls, JAG(x0, 0)))
| "S2EVar" =>
    s2exp_node_S2EVar(ar, parse_s2Var(ar, tbls, JAG(x0, 0)))
| "S2Eeqeq" => let
    val s2e1 = s2exp(JAG(x0, 0))
    val s2e2 = s2exp(JAG(x0, 1))
  in
    s2exp_node_S2Eeqeq(ar, s2e1, s2e2)
  end // end of [S2Eeqeq]
| "S2Esizeof" =>
    s2exp_node_S2Esizeof(ar, s2exp(JAG(x0, 0)))
| "S2Eapp" => let
    val s2e_fun = s2exp(JAG(x0, 0))
    val s2es_arg = s2explst(JAG(x0, 1))
  in
    s2exp_node_S2Eapp(ar, s2e_fun, s2es_arg)
  end // end of [S2Eapp]
| "S2Emetdec" => let
    val s2es_met = s2explst(JAG(x0, 0))
    val s2es_bound = s2explst(JAG(x0, 1))
  in
    s2exp_node_S2Emetdec(ar, s2es_met, s2es_bound)
  end // end of [S2Emetdec]
| "S2Etop" => let
    val knd = parse_int(JAG(x0, 0))
    val s2e = s2exp(JAG(x0, 1))
  in
    s2exp_node_S2Etop(ar, knd, s2e)
  end // end of [S2Etop]
| "S2Einvar" =>
    s2exp_node_S2Einvar(ar, s2exp(JAG(x0, 0)))
| "S2Efun" => let
    val npf = parse_int(JAG(x0, 0))
    val s2es = s2explst(JAG(x0, 1))
    val s2e = s2exp(JAG(x0, 2))
  in
    s2exp_node_S2Efun(ar, npf, s2es, s2e)
  end // end of [S2Efun]
| "S2Euni" => let
    val s2vs = s2varlst(JAG(x0, 0))
    val s2ps = s2explst(JAG(x0, 1))
    val s2e = s2exp(JAG(x0, 2))
  in
    s2exp_node_S2Euni(ar, s2vs, s2ps, s2e)
  end // end of [S2Euni]
| "S2Eexi" => let
    val s2vs = s2varlst(JAG(x0, 0))
    val s2ps = s2explst(JAG(x0, 1))
    val s2e = s2exp(JAG(x0, 2))
  in
    s2exp_node_S2Eexi(ar, s2vs, s2ps, s2e)
  end // end of [S2Eexi]
| "S2Etyrec" => let
    val knd = parse_tyreckind(ar, tbls, JAG(x0, 0))
    val npf = parse_int(JAG(x0, 1))
    val ls2es = parse_labs2explst(ar, tbls, JAG(x0, 2))
  in
    s2exp_node_S2Etyrec(ar, knd, npf, ls2es)
  end // end of [S2Etyrec]
| "S2Eextype" =>
    s2exp_node_S2Eextype(ar, symbol(JAG(x0, 0)))
| "S2Eextkind" =>
    s2exp_node_S2Eextkind(ar, symbol(JAG(x0, 0)))
| "S2Eignored" => s2exp_node_S2Eerror(ar)
| _(*unrecognized*) => 
  let
    val () =
    prerrln!
      ("parse_s2exp_node: ", name)
    // end of [val]
    val ((*exit*)) = assertloc(false)
  in
    exit(1)
  end // end of [unrecognized]
//
end // end of [parse_s2exp_node]

(* ****** ****** *)

implement
parse_labs2exp
  (ar, tbls, jsnv0) = let
//
val name = jsonval_get_name(jsnv0)
val x0 = jsonval_get_value(jsnv0)
//
in
//
case+ name of
| "SL0ABELED" => let
    val lab =
      parse_label(ar, tbls, JAG(x0, 0))
    val s2e =
      parse_s2exp(ar, tbls, JAG(x0, 2))
  in
    labs2exp_SLABELED(ar, lab, s2e)
  end // end of [SL0ABELED]
| _(*unrecognized*) => 
  let
    val () =
    prerrln!
      ("parse_labs2exp: ", name)
    // end of [val]
    val ((*exit*)) = assertloc(false)
  in
    exit(1)
  end // end of [unrecognized]
//
end // end of [parse_labs2exp]

(* ****** ****** *)

(* end of [patsolve_parsing_s2exp.dats] *)
