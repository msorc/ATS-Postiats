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
//
#define
ATS_PACKNAME
"PATSOLVE_PARSING"
//
(* ****** ****** *)
//
#staload
"libats/SATS/arena.sats"
#staload
"./patsolve_cnstrnt.sats"
//
(* ****** ****** *)
//
// HX-2026-10: no GC
// A jsonval is a json-c object borrowed from the
// root object of the input; the root is freed once the
// parsing is done (by [parse_fileref_constraints]). So a
// jsonval should never escape the parsing functions.
//
abstype
jsonval_type = ptr
typedef
jsonval = jsonval_type
//
fun
jsonval_is_null(jsnv: jsonval): bool
//
// HX: a null jsonval if [key] is not found
//
fun
jsonval_get_field
  (jsnv: jsonval, key: string): jsonval
//
(* ****** ****** *)
//
// HX:
// the tables built during parsing
// (they are kept in the arena)
//
abstype
ptables_type(l:addr) = ptr
typedef
ptables(l:addr) = ptables_type(l)
//
fun
ptables_make_nil
  {l:addr}(ar: !arena(l)): ptables(l)
//
fun
ptables_get_symtbl
  {l:addr}(ar: !arena(l), tbls: ptables(l)): symtbl(l)
//
(* ****** ****** *)
//
fun
the_s2cstmap_insert{l:addr}
  (ar: !arena(l), tbls: ptables(l), s2c: s2cst(l)): void
fun
the_s2cstmap_search{l:addr}
  (ar: !arena(l), tbls: ptables(l), key: stamp): Option_vt(s2cst(l))
//
// HX: the constants are sorted by their stamps
//
fun
the_s2cstmap_listize{l:addr}
  (ar: !arena(l), tbls: ptables(l)): s2cstlst_vt(l)
//
fun
the_s2varmap_insert{l:addr}
  (ar: !arena(l), tbls: ptables(l), s2v: s2var(l)): void
fun
the_s2varmap_search{l:addr}
  (ar: !arena(l), tbls: ptables(l), key: stamp): Option_vt(s2var(l))
//
fun
the_s2Varmap_insert{l:addr}
  (ar: !arena(l), tbls: ptables(l), s2V: s2Var(l)): void
fun
the_s2Varmap_search{l:addr}
  (ar: !arena(l), tbls: ptables(l), key: stamp): Option_vt(s2Var(l))
//
fun
the_s2rtdatmap_get{l:addr}
  (ar: !arena(l), tbls: ptables(l)): s2rtdatlst(l)
fun
the_s2rtdatmap_set{l:addr}
  (ar: !arena(l), tbls: ptables(l), s2tds: s2rtdatlst(l)): void
//
(* ****** ****** *)
//
typedef
parsefn(l:addr, a:t@ype) =
  (!arena(l), ptables(l), jsonval) -> a
//
fun parse_int (jsnv: jsonval): int
fun parse_string (jsnv: jsonval): string
fun parse_stamp (jsnv: jsonval): stamp
//
fun
parse_symbol{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): symbol(l)
fun
parse_location{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): loc_t(l)
fun
parse_label{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): label(l)
fun
parse_tyreckind{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): tyreckind(l)
//
fun{
a:t@ype
} parse_list{l:addr}
(
  ar: !arena(l), tbls: ptables(l), jsnv: jsonval, f: parsefn(l, a)
) : alist(l, a) // end of [parse_list]
//
(* ****** ****** *)
//
fun
parse_s2rt{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s2rt(l)
fun
parse_s2rtlst{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s2rtlst(l)
//
fun
parse_s2rtdat{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s2rtdat(l)
fun
parse_s2rtdatlst{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s2rtdatlst(l)
//
fun
parse_s2cst{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s2cst(l)
fun
parse_s2cstlst{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s2cstlst(l)
//
fun
parse_s2var{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s2var(l)
fun
parse_s2varlst{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s2varlst(l)
//
fun
parse_s2Var{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s2Var(l)
//
fun
parse_s2exp{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s2exp(l)
fun
parse_s2explst{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s2explst(l)
//
fun
parse_labs2exp{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): labs2exp(l)
fun
parse_labs2explst{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): labs2explst(l)
//
fun
parse_s3itm{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s3itm(l)
fun
parse_s3itmlst{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s3itmlst(l)
fun
parse_s3itmlstlst{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): s3itmlstlst(l)
//
fun
parse_h3ypo{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): h3ypo(l)
//
fun
parse_c3nstr{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): c3nstr(l)
fun
parse_c3nstropt{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): c3nstropt(l)
//
(* ****** ****** *)
//
fun
parse_constraints{l:addr}
  (ar: !arena(l), tbls: ptables(l), jsnv: jsonval): c3nstr(l)
//
// HX: exiting with an error message if parsing fails
//
fun
parse_fileref_constraints{l:addr}
  (ar: !arena(l), tbls: ptables(l), filr: FILEref): c3nstr(l)
//
(* ****** ****** *)

(* end of [patsolve_parsing.sats] *)
