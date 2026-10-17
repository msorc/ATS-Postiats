(* tests of pats_reader, pats_lexbuf, pats_lexing, pats_tokbuf (see lexdump.dats for the
   comparison against the ATS1 lexer) *)
#include "share/atspre_staload.hats"
staload UN = "prelude/SATS/unsafe.sats"
staload "libats/SATS/arena.sats"
staload _ = "libats/DATS/arena.dats"
staload _ = "libats/DATS/qlist.dats"
staload _ = "libats/DATS/hashtbl_linprb.dats"
staload _ = "libats/DATS/hashfun.dats"
staload FIL = "../pats_filename.sats"
staload LOC = "../pats_location.sats"
staload LBF = "../pats_lexbuf.sats"
staload TBF = "../pats_tokbuf.sats"
staload "../pats_basics.sats"
staload "../pats_lexing.sats"
dynload "../pats_utils.dats"
dynload "../pats_symbol.dats"
dynload "../pats_filename.dats"
dynload "../pats_location.dats"
dynload "../pats_basics.dats"
dynload "../pats_reader.dats"
dynload "../pats_lexbuf.dats"
dynload "../pats_lexing_token.dats"
dynload "../pats_lexing.dats"
dynload "../pats_lexing_error.dats"
dynload "../pats_lexing_print.dats"
dynload "../pats_tokbuf.dats"
implement $FIL.pkgsrcname_relocatize (given, ngurl) = given

fn isnode_ident (tok: token, name: string): bool =
  case+ token_node_view (tok.token_node()) of
  | ~T_IDENT_alp x => (x = name)
  | tn => let val () = token_node_view_free (tn) in false end

implement main0 () = {
  var tb: $TBF.tokbuf
  val () = $TBF.tokbuf_initize_string (tb, "fun f (x: int): int = x (* c *) + 0x10 \"s\"")
  val t1 = $TBF.tokbuf_getinc_token (tb)
  val () = assertloc (token_node_is_T_FUN (t1.token_node()))
  val t2 = $TBF.tokbuf_getinc_token (tb)
  val () = assertloc (isnode_ident (t2, "f"))
  val () = assertloc ($TBF.tokbuf_get_ntok (tb) = 2u)
  // backtracking
  val () = $TBF.tokbuf_set_ntok (tb, 1u)
  val t2b = $TBF.tokbuf_getinc_token (tb)
  val () = assertloc (isnode_ident (t2b, "f"))
  // reset drops the visited tokens
  val () = $TBF.tokbuf_reset (tb)
  val () = assertloc ($TBF.tokbuf_get_ntok (tb) = 0u)
  val t3 = $TBF.tokbuf_get_token (tb)
  val () = assertloc (token_node_is_T_LPAREN (t3.token_node()))
  // unget
  val () = $TBF.tokbuf_unget_token (tb, t2)
  val t4 = $TBF.tokbuf_getinc_token (tb)
  val () = assertloc (isnode_ident (t4, "f"))
  val () = $TBF.tokbuf_discard_all (tb)
  val () = $TBF.tokbuf_uninitize (tb)
  val () = assertloc (fprint_the_lexerrlst (stdout_ref) = 0)
  // errors
  var lb: $LBF.lexbuf
  val () = $LBF.lexbuf_initize_string (lb, "\"abc")
  val t5 = lexing_next_token (lb)
  val () = assertloc (token_node_is_T_STRING (t5.token_node()))
  val () = $LBF.lexbuf_uninitize (lb)
  val () = assertloc (fprint_the_lexerrlst (stdout_ref) = 1)
  val () = the_lexerrlst_clear ()
  // tnode_search
  val () = assertloc (token_node_is_T_NONE (tnode_search ("foo")))
  val () = assertloc (token_node_is_T_FUN (tnode_search ("fun")))
  val () = println! ("test_lexing: ok")
}
