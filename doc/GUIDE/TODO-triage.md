<!--
SPDX-FileCopyrightText: 2026 Mikhail Sorochan
SPDX-License-Identifier: MIT
-->

# Triage of the HX-, TODO, FIXME and XXX markers in `src/`

This is a reading list, not a bug list. Nothing was opened as a GitHub issue
and no marker was deleted or changed. The markers are the comments of the
hand-written modules of the compiler (`src/pats_*.dats|sats|hats|cats`; the
generated `pats_*_gen*.hats`, `src/CBOOT` and `src/test` are not counted).

How the markers look in this tree:

- `TODO`, `XXX` and `FIXME` are almost absent: there is exactly one `FIXME`
  (group A, first item), no `TODO` and no `XXX`.
- The author's notes are `HX:` and `HX-YYYY-MM-DD:` comments (about 500
  dated ones). Almost all of them are explanations or history ("fixing
  bug-2016-06-26"), not open work. The ones that read as open questions are
  below: those that say "really?", "is this needed?", "deadcode", "not yet
  supported", "should be ...".
- `file:line` is the position in the tree at the commit of this document;
  lines move, so search for the quoted text.

Recommendation key: **issue** = worth one issue each; **group** = one issue
for the whole group; **leave** = a note that is fine as it is.

## A. Real bug suspicion

| file:line | marker | why it may be a bug | recommendation |
|---|---|---|---|
| `pats_trans2_dynexp.dats:1819` | `sc2laulst_coverck (loc0, sc2ls, s2t_pat) // FIXME!!!` | the only `FIXME`: the coverage check of a static `scase` is called but the author doubts it (it may report a wrong or no error) | **issue**: write a test with an incomplete `scase` and see what the compiler says |
| `pats_staexp2_szexp.dats:370` | `s2zexp_S2ZEbot () (* HX: really??? *)` | the size expression of an unknown application head silently becomes bottom; wrong sizes may follow | **issue** (with a test of the size of a type application of a non-constant) |
| `pats_trans3_env.dats:383,568,585,604` | `[sub] should be properly extended first` | four places call `stasub_s2varlst_instantiate_none` with a substitution that the author says is not extended first; the instantiation may miss variables | **issue**: one for the four |
| `pats_trans3_env_lstate.dats:380` | `assertloc (glist_is_nil (...ctrs ())) // [ctrs] should be nil!` | an `assertloc` on a state of the linear-state machinery; an abort instead of an error message if it ever fails | **group** with the `assertloc` ones below |
| `pats_trans1_e0xp.dats:188` | `assertloc (false) in false // this should be deadcode!` | an abort in a branch that the author believes unreachable | **group** |
| `pats_trans1_staexp.dats:364` | `should npf <= 0 be enforced?` | the proof-argument count is not checked at this point | **issue** (a malformed `s1exp` list with `|` may be accepted) |
| `pats_trans1_staexp.dats:1028` | `[fil] should be the includer instead of includee` | the file recorded for a constant declaration is the wrong one in an `#include`d file (the current file name is used); wrong file in error messages and in the tag output | **issue** (error message location) |
| `pats_trans3_p2at.dats:215` | `LABP2ATomit ... should an error be reported?` | an omitted label pattern is silently accepted with no bindings | **group** |
| `pats_trans2_decl.dats:207` | `should a warning be reported?` | a name that is already bound is replaced without a warning | **leave** unless users ask |
| `pats_dmacro2_eval1.dats:90` | `d2var_rename ... = d2v // HX: is this okay?` | the macro evaluator does not rename the variable (possible capture in a macro expansion) | **issue** (macro hygiene; needs a test) |
| `pats_e1xpval.dats:539` | `E1XPeval ... // HX: right?` | an evaluation level that the author is not sure of | **group** |
| `pats_utils.dats:413` | `'~' => ... // HX: should it be supported?` | the negative sign of a literal is accepted in a place where the author doubts it | **leave** |
| `pats_staexp2_util2.dats:121` | `1000 should be enough` (`S2EXP_LINKREM_DEPTH`) | a fixed depth of the link-removal; a deeper type gives a wrong result without an error | **issue**: make the depth overflow an error |
| `pats_main.dats:2023` | `A tool like patscc should be able to receive an error` | the abort on `nerror > 0` is how patscc sees a compiler error; nothing to do | **leave** |
| `pats_trans1_decl.dats:1443,1476,1512,1544` | `is it meaningful to continue?` | the compiler aborts at the first error of these four declarations (the other errors of the file are not reported) | **group**: error recovery |
| `pats_symbol.dats:108` | `symbol_null ... // HX: a hack!` | a null pointer as a symbol; every use must test it | **leave** (documented, no-GC design) |

## B. Missing features (reported to the user as "not supported")

The compiler says "not supported" or "not implemented" for these. They are
limits of the language implementation, not bugs.

| file:line | marker | recommendation |
|---|---|---|
| `pats_trans2_sort.dats:145` | `sort application is not supported.` | **leave** |
| `pats_staexp2_sort.dats:676`, `pats_staexp2.sats:301` | `tuple sort(s) not yet supported` (`s2rt_tup`) | **leave**, the same limit in two places |
| `pats_e1xpval.sats:68,73` | `tuple value / function value is not supported` (commented out `VE_E1XPlist`, `VE_E1XPfun`) | **leave** |
| `pats_ccomp_decl.dats:613` | `non-lambda function definition is not supported.` | **issue**: say what the user should write |
| `pats_ccomp_dynexp.dats:466` | `[sif] is not supported after proof-erasure.` | **leave** |
| `pats_trans2_impdec.dats:885` | `temp guards not supported` (`tmpgua = glist_nil`) | **issue** (a feature: guards on template implementations) |
| `pats_trans2_decl.dats:2482` | `Overloading declarations needs to be added` (HX-2017-01-30) | **issue**: check whether an overload declared in a staloaded file is seen by the includer |
| `pats_trans2_decl.dats:2928` | `d1ecl_tr: not implemented: d1c0 = ...` | **leave** (internal error text) |
| `pats_trans2_p1at.dats:827` | `p1at_tr: not yet implemented: p1t0 = ...` | **leave** |
| `pats_trans2_dynexp.dats:2190` | `not yet implemented: d1e0 = ...` | **leave** |
| `pats_dmacro2_eval1.dats:392` | `eval1_p2at: not implemented yet` | **issue**: patterns in `eval1` macros |
| `pats_trans3_syncst.dats:283,356,457` | `the suffix of the integer / floating point number is not supported.` | **leave** |
| `pats_typerase_dynexp.dats:1153` | `a non-value body for static lam-abstraction is not supported.` | **leave** |
| `pats_lintprgm_myint_gmp.dats:192` | `div11 is declared but not implemented in ATS1 (gmpknd)` | **issue**: implement it for gmpknd (or remove the declaration) |
| `pats_filename.dats:420` | `[getcwd_gc] of libats/libc is not implemented; the C code is below` | **issue**: use the library function now that it exists |
| `pats_trans2_decl.dats:1411`, `pats_trans3_util.dats:543` | `nonlinear heap allocation is not supported (no GC)` | **leave**: this is the no-GC rule (CLAUDE.md), not a gap |

## C. Obsolete notes (history, dead code, removed features)

None of these needs an issue; they are candidates for a later cleanup of the
comments (and of the code that the author calls dead).

| file:line | marker | recommendation |
|---|---|---|
| `pats_ccomp_funlab.dats:248,271`, `pats_hidynexp_util.dats:150,178` | `this is deadcode` (an `abort_interr` branch) | **leave**: an assertion for an impossible case |
| `pats_ccomp_template.dats:690,762` | `else true // HX: deadcode` | **group** with the next ones |
| `pats_staexp2.dats:706`, `pats_staexp2_skexp.dats:388`, `pats_staexp2_svar.dats:554`, `pats_staexp2_szexp.dats:499`, `pats_lexing.dats:1279`, `pats_fixity_fxty.dats:441`, `pats_staexp2_sort.dats:270` | `deadcode` / `this should be deadcode!` | **group** |
| `pats_trans3_env_dvar.dats:876` | `is this deadcode?` | **group** |
| `pats_staexp2_util2.dats:749` | `should be removed eventually!` | **group** |
| `pats_ccomp_hipat.dats:479,601,738` | `[d2v] is unused` | **leave** |
| `pats_trans3_env.dats:653` | `nerr: &int // HX: unused` | **leave** (an unused parameter) |
| `pats_trans2_staexp.dats:1210`, `pats_trans2_decl.dats:2509` | `is this really needed?` | **group** |
| `pats_lexing_token.dats:122` | `HX-2015-12-10: 'ref@' is removed for now` | **leave** |
| `pats_lexing_token.dats:516` | `[sta] is now deprecated` | **leave** |
| `pats_parsing_base.dats:264` | `LPAREN l0ab RPAREN // this is removed for now` | **leave** |
| `pats_parsing_decl.dats:894` | `HX-2012-05-23: removed this big hack!!!` (a commented-out `STAVAR` rule) | **leave** (delete in the dead-comment cleanup) |
| `pats_parsing_dynexp.dats:622` | `HX-2011-04-04: deprecated?` | **issue** only if the rule is not used by any test: otherwise **leave** |
| `pats_parsing_sort.dats:76` | `MINUSLTGT // what is this for?` | **leave** |
| `pats_fixity_prec.dats:73` | `for temporary infix status` | **leave** |
| `pats_trans2_dynexp.dats:1266,1787`, `pats_trans3_util.dats:443`, `pats_ccomp_claulst.dats:882,946,1070`, `pats_dynexp2_util.dats:300` | `Fixing a bug with ...`, `bug-YYYY-MM-DD.dats` | **leave**: these point to a regression file (`doc/BUGS`); they record a fix, not an open bug |

## Which to turn into issues

If only some are filed, in this order:

1. `pats_trans2_dynexp.dats:1819` (the `FIXME`, coverage check of `scase`).
2. `pats_staexp2_util2.dats:121` (silent depth limit).
3. `pats_staexp2_szexp.dats:370` (`really???`).
4. `pats_trans3_env.dats` `[sub] should be properly extended first` (4 places, one issue).
5. `pats_trans1_staexp.dats:1028` (wrong file in a message) and `:364` (`npf`).
6. `pats_dmacro2_eval1.dats:90` and `:392` (macro hygiene and patterns).
7. `pats_lintprgm_myint_gmp.dats:192` (`div11` for gmpknd) and `pats_filename.dats:420` (`getcwd_gc`).
8. One issue for the error recovery of `pats_trans1_decl.dats` ("is it meaningful to continue?", 4 places).
9. One issue to clean up the "deadcode" notes of group C.

The other markers are comments that are fine as they are.
