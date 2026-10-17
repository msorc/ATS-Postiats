> **Note (src2 renamed to src).** This file was written while the ATS2 port of the compiler lived in `src2/` next to the ATS1 compiler in `src/`.
> The ATS1 sources were removed and `src2/` was renamed to `src/` (`patsopt2` is now `patsopt`, `libatsopt2.a` is `libatsopt.a`, the object
> directory `patsopt2.obj/` is `patsopt.obj/`, `make libatsopt2test` is `make libatsopttest`). The text below is kept as written: read `src2/` as `src/`
> and `src/` (the ATS1 sources, "the old src") as the ATS1 sources of the git history (see `README` in this directory). Build, bootstrap and test:
> see `README` and `CBOOT/README` in this directory.

# Porting `src/` (ATS1) to `src2/` (ATS2, no GC)

Keep the file names and the external C names (`= "patsopt_..."`) of `src/`.
`make check` typechecks everything ported; `make test` also compiles, links and
runs one driver per module (`test/`, each shows how to dynload/link a module).

    export PATSHOME=<repo root>; export PATH=$PATSHOME/bin:$PATH
    patsopt --typecheck -s X.sats      # a .sats needs -s (not -d)
    patsopt --typecheck -d X.dats
    patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h -I.. -o t t.dats ../X.dats

Done (typecheck + run): pats_basics, utils, intinf (gmp and `-DATS C3NSTRINTKND=intknd`),
counter, stamp, error, errmsg, symbol, filename, location, label, fixity
(`pats_fixity.sats`, `_prec.dats`, `_fxty.dats`), symmap, symenv.
Copied unchanged (still ATS1 syntax where they use it): none; `pats_params.hats`
and `pats_basics.hats` are verbatim copies.

## Rules (ATS1 -> ATS2 / no GC)

### Toolchain and prelude
1. Prelude names. `staload ATSPRE = "./pats_atspre.dats"` becomes
   `#include "share/atspre_staload.hats"` at the top of every `.dats`.
   `$UN` is not predefined (only `$UNSAFE`): add
   `staload UN = "prelude/SATS/unsafe.sats"`. `$UN.cast2ptr(x)` -> `$UN.cast{ptr}(x)`,
   `$UN.cast2int` -> `$UN.cast{int}`, `ptrget` -> `ptr0_get<T>`.
2. libc moved: `"libc/SATS/stdlib.sats"` -> `"libats/libc/SATS/stdlib.sats"` (same for
   fcntl, stdio, string, unistd). Some are declared but have no implementation:
   `strtoll0`, `getcwd_gc`, `fildes_read_all_err`, `strtoll_errnul`. Declare your own
   (`extern fun strtoll_c(...) = "mac#strtoll"`) or write C (see `pats_filename.dats`).
3. `printf`/`sprintf`/`fprintf`/`printf_c` are gone.
   `fprintf(out, "%li(line=%i)", @(a, b))` -> `fprint_lint(out, a); fprint_string(out, "(line="); fprint_int(out, b)`.
   `sprintf("%s%c%s", ..)` -> `string0_append3(a, $UN.castvwtp1{string}(sep1), b)` (returns `Strptr1`).
   A variadic C function can still be declared with a fixed arity:
   `fun prerrf_ifdebug(fmt: string, loc: string, msg: string): void = "ext#patsopt_prerrf_ifdebug"`.
4. Integers: `uint_of(x)` -> `g0int2uint_int_uint(x)`, `int_of(u)` -> `g0uint2int_uint_int(u)`,
   `a \land_uint_uint b` -> `g0uint_land_uint(a, b)`, `\lor_` -> `g0uint_lor_uint`, `~u` ->
   `g0uint_lnot_uint(u)`; `lt_int_int` -> `g0int_lt_int` (`g0int_compare_int` returns `int`, not `Sgn`:
   write `if a < b then ~1 else (if a > b then 1 else 0)` when `Sgn` is needed).
   `llint_of_int` -> `g0int2int_int_llint`. `1` is an `int`, not a `size_t`: use `i2sz(1)`.
   `string1_of_string(s)` -> `g1ofg0(s)`. `p + 1` on `ptr` is gone: `ptr0_succ<char>(p)`,
   `ptr0_add_guint<byte>(p, i2sz(8))`; `null` -> `the_null_ptr`; use `ptr0_*` (not `ptr1_*`), the
   latter leaves an unsolvable `l+sizeof > null` constraint.
5. Strings. Any `string` that must outlive its creator is copied with
   `the_garena_strdup(str)` (never freed). `string_of_strptr`, `stropt_of_strptr`, `string0_copy(..): string`
   are gone (a `Strptr1` must be freed with `strptr_free`, or converted with `the_garena_strdup`).
   `stropt_none(*void*)` -> `stropt_none()`. `string_make_substring` returns `strnptr`; cast with
   `$UN.castvwtp0{Strptr1}(sbp)` (do not use `strnptr2strptr`: it leaves `n >= 0` unsolved).
6. Char literals `'\{'` and `'\}'` need the backslash; a line `////` (e.g. `//` + `//` after a
   generated edit) silently ends the file: the rest is not typechecked.
7. Effects and metrics. `fun f(..):<> T` that is not recursive must be `fn`
   ("termination metric is missing"). Pure (`:<>`) declarations in a `.sats` that are implemented with
   libats/arena/linear code need `$effmask_all` / `$effmask_wrt` in the body (the checks are stricter:
   a `&`-argument assignment is `wrt`). `-<fun>` means *pure* function in ATS2 (the old
   `-<fun>` = non-closure is `->`): write `(a, a) -> int`.
8. Patterns on linear lists: `list_vt_cons (x, !p_xs)` -> `@list_vt_cons (x, xs1)`; `fold@` only after
   an `@` pattern (never after `list_vt_nil`). `List_vt(T)` can have negative length for `&`
   arguments: use `List0_vt(T)`.

### No-GC data (see CLAUDE.md "No GC")
9. `List(T)`/`Option(T)` -> `glist(T)`/`gopt(T)` (`staload "libats/SATS/arena.sats"` in the `.sats`;
   `staload _ = "libats/DATS/arena.dats"` in the `.dats`). Construct with `glist_nil()`, `glist_cons(x, xs)`,
   `glist_sing(x)`; match with
   `case+ glist_view(xs) of | ~GLnil() => .. | ~GLcons(x, xs1) => ..` (the view is linear: always `~`,
   a `_` pattern does not typecheck). `'[a, b]` -> `glist_cons(a, glist_sing(b))`. `Some_vt/None_vt` stay.
10. A datatype with arguments, or a record `'{...}`, is generated by `utils/arenagen/arenagen.py --global`
    from a spec (`pats_location.spec`, `pats_label.spec`, `pats_fixity.spec`; `make gen`), and the
    result is `#include`d into the `.sats` (`pats_X_gen.hats`) and `.dats` (`pats_X_gen_dats.hats`).
    Before/after:

        datatype label = LABint of int | LABsym of symbol        // ATS1
        label_view(l) matches ~LABint(i) | ~LABsym(s)            // ATS2: [case+ label_view(l) of ..]
        LABint(3)  ->  label_LABint(3)                           // constructors are label_CON(..)
        loc.beg_ntot   ->  loc.beg_ntot()                        // field getters are called x.F()

    Several modules of this kind are `abstype T_type = ptr` in the `.sats`.
    An enum-only datatype (`assoc`, `funkind`..) is unchanged. `FUNCLOclo of int` (a payload on one
    constructor of an otherwise enum type) became `FUNCLOcloptr | FUNCLOclo0 | FUNCLOcloref` plus
    `FUNCLOclo(knd)` and `funclo_get_clokind`. A one-constructor tuple datatype becomes a flat tuple:
    `datatype labeled(a) = LABELED of (label, a)` -> `typedef labeled(a) = @(label, a)`.
    `DCKfun of ()` -> `DCKfun`.
11. Abstract boxed types become `abstype X_type = ptr` (the `= ptr` is mandatory in ATS2 `.sats`); the
    `assume X_type = ptr` in the `.dats` and cells in the global arena
    (`the_garena_alloc(sizeof<T>)` with `$UN.ptr0_get/ptr0_set`; `symbol`, `filename`, `counter`, `intinf`).
    When the abstype is assumed to be `ptr`, `=` on two of them is ambiguous with `eq_ptr0_ptr0`: use
    `ptr_is_null(..)` or compare through accessors.
12. Global mutable state: a toplevel `var` plus `ref_make_viewptr{T}(view@ v | addr@ v)`
    (`pats_basics.dats`, symbol stamp), or an arena cell. `ref_make_elt`, `vbox_make_view_ptr`,
    `ref(..)` heap allocation are gone. A linear list in a global is replaced by an immutable `glist`
    in the cell (`pats_filename.dats`: the file/path stacks).
13. Closures. `cloref`/`lam` stored in data are rejected. Closures used locally are lambda-lifted: drop the
    `:<cloref1>` annotation of a nested `fun` that is called directly. A closure stored in a shared
    structure is closure-converted by hand: `fxfn1(a) = @(env, fun(env, a))` with the `env` allocated in the
    arena (`pats_fixity.sats`). `lam (..) => ..` arguments become named functions with `->` types. A hash/
    set/map comparison closure becomes `implement compare_key_key<K>(x, y) = ..` (a template).
14. libats changes: `funset_listord`/`funmap` (nonlinear) are gone: use a sorted `glist` (`charset`,
    `intinfset`) or linear `linset_avltree`/`linmap_avltree` with the comparison given as
    `implement $LS.compare_elt_elt<T>(x,y)` / `compare_key_key<K>(x,y)` (no `cmp` closure argument).
    `hashtbl_linprb` keys/items are plain types; `hashtbl_insert_any` and `linmap_insert_any`
    assert that the key is absent: use `hashtbl_insert_opt` / `linmap_insert` and discard the result
    (`opt_clear`). `ptr_alloc<T>()` returns `(pfat, pfgc | p)` (the order was swapped; the second is
    erased with `$UN.castview0{void}(pfgc)`). `libats/linqueue_arr`, `deque_arr` are gone.

### Templates and linking
15. A non-template function cannot be polymorphic in a result or an argument that is stored/returned by
    value (`{a:vt@ype}():(a)`, `{a:type}(x: a)`) nor call a template at an abstract type: C code like
    `PMVtmpltcstmat[..]` or `atstyvar_type` is produced. Make it a template: `fun{a:vt0p} abort(): a`,
    `fun{itm:type} symmap_search(..)`, `implement{a} ...`; callers write `abort<void>()`,
    `symmap_search<d2itm>(m, k)`.
16. The implementation of every template that an instantiation (transitively) needs must be in scope at
    the call site: `staload _ = "./pats_symmap.dats"` AND `staload _ = "libats/DATS/linmap_avltree.dats"`
    AND `qlist.dats` ... `mylibies.hats` lists the libats ones; `#include` it in drivers and in the
    modules that instantiate libats templates.
17. Module initialisation. Do NOT `#define ATS_DYNLOADFLAG 0` in a `.dats` (this removes `__dynload`
    altogether). Compile the `.dats` as is, and in the driver (`pats_main.dats`) use
    `dynload "./pats_X.dats"` (plus `staload _ = "./pats_X.dats"` when the driver instantiates its templates).
    Initialisation order = dynload order: symbol before filename, counter before stamp, etc.
    A `.sats` with `exception ..` declarations must also be compiled (`patsopt --output x_sats.c --static
    x.sats`) and linked (`pats_error.sats`); compile with `-D_GNU_SOURCE -include alloca.h` (try/exception
    frames use `alloca`).
18. `val x : T` in a `.sats` needs a C name: `val symbol_ADD : symbol = "ext#patsopt_symbol_ADD"`
    (`implement symbol_ADD = ..` stays). `fun f : T -> U` becomes `fun f (x: T): U`.
    `fun theDirSep_get(): char = "..."` needs the `ext#` prefix when the C function is defined in the
    `.dats` `%{$`.
19. Macros: `macdef f (x) = g (..., ,(x))` keeps the `,(x)` quoting (a bare `x` is "refers incorrectly to a
    macro argument"); `#FILENAME` is gone (`$mylocation`, a string); `PATS_fVER` is unchanged.
20. `#if (MACRO) #include "x.hats" #endif` inside a `.dats` that is *staloaded* (the template user does
    `staload _ = "x.dats"`) takes the false branch: include the `.hats` unconditionally (`pats_symmap.dats`).
    From the command line, `-DATS C3NSTRINTKND=intknd` still selects the `intinf` variant.

### Inline C (`%{^ .. %}` / `%{$ .. %}`)
21. Types: `ats_ptr_type`/`ats_int_type`/`ats_void_type`... -> `atstype_ptr`/`atstype_int`/`atstype_void`...
    (`sed -E 's/\bats_([a-z]+)_type\b/atstype_\1/g'`). `ATSextfun()` -> `ATSextern()`. `ATS_FREE` ->
    `ATS_MFREE`. `ATS_MALLOC`, `ATS_REALLOC` are unchanged. Names of functions of the arena: `atslib_the_garena_alloc`.
    Add a prototype for any C function that the ATS code calls through a name without `mac#`/`ext#`
    declaration (C99: no implicit declarations), and `#include <unistd.h>` etc. yourself.
    For a `.cats` copied from `src/`, apply the same renaming (`pats_location.cats`).

## Open problems

* `pats_utils.sats`: `queue_get_strptr1` (needs `libats/linqueue_arr`, removed) is NOT ported. Its only user is
  `pats_lexbuf.dats`, which has to do its own buffer (or use `dynarray`).
* `pats_utils.dats` `tostring_fprint`: the template argument `prfx` is no longer used (it was a mkstemp prefix);
  the output goes through `tmpfile()`.
* `pats_fixity.sats`: closures stored in `fxopr` are now explicit `(env, fun)` pairs (rule 13). The callers
  in `pats_trans1_dynexp.dats` (`FXOPRpre (foldat_prec_dyn, f)` where `f` captures `s1as`, `loc0`...) must allocate
  an `env` in the global arena and call `fxopr_FXOPRpre<d1exp>(prec, @(env, fn))`; `appf`/`locf` are plain function
  pointers (the ones in trans1 capture nothing). `fxopr_make`, `fxitm_app`, `fixity_resolve` are templates
  (`<d1exp>` etc.).
* `pats_filename.sats`: `pkgsrcname_relocatize` is implemented in `pats_filename_reloc.dats`, not ported yet
  (the tests stub it). `pats_main.dats` calls `the_prepathlst_push` through `libatsopt_the_prepathlst_push`.
* `pats_symmap_htlinprb.hats` (a disabled experiment) is not ported; `pats_symmap.dats` no longer mentions it.
* Faithfully kept ATS1 oddities, probably bugs: `pats_counter.sats` `overload > with lt_count_count` (and `>=` with
  `lte_`), `pats_symbol.sats` `overload != with eq_symbol_symbol`, `pats_basics.sats` `lte_impkind_impkind (k1, k1)`.
* `pats_intinf_gmp.hats` does not use `contrib/atscntrb-hx-libgmp`: gmp is called through thin C wrappers
  (`patsopt_mpz_*`) on `mpz_t` cells from the global arena; gmp's own allocator is libc's.
* Everything that is shared lives in the global arena and is never freed (symbols, filenames, locations,
  intinf, stamps' strings). Expect `LeakSanitizer` to report only the linear temporaries, not these.
* Not in the slice but needed by the above: `pats_atspre.dats` (ATS1 prelude extras), `pats_params.hats` users.

## Lexer step: pats_reader, pats_lexbuf, pats_lexing*, pats_tokbuf (rules L1-L9)

Done and validated: all of them (`pats_lexing_{token,error,print}.dats` too). The tokens of 84 files (prelude,
libats, src, doc/EXAMPLE, src2 and 5 hand-written error files; ~152000 token lines) are identical to those of the
ATS1-built lexer, in 5 reading modes (`test/lexcompare.sh`, `test/lexdump.dats`, `test/lexdump1.dats`).

L1. A big datatype with arguments (`token_node`, 179 constructors) is a spec for arenagen like any other
    (`pats_lexing_token.spec`, `make gen`; the `'{token_loc, token_node}` record is `type token` with named fields).
    Before/after:

        T_IDENT_alp (x)   (construct)  ->  token_node_T_IDENT_alp (x)       T_EOF  ->  token_node_T_EOF()
        case+ tok.token_node of T_AT () => ..   ->  case+ token_node_view (tok.token_node()) of ~T_AT () => ..
        case+ tnode of T_NONE () => a | _ => b  ->  if token_node_is_T_NONE (tnode) then a else b
        tok.token_loc / '{token_loc= l, token_node= n}  ->  tok.token_loc() / token_TOKEN (l, n)

    A catch-all branch of a `_view` match must free the view: `| tn => token_node_view_free (tn)` (else a leak).
    An enum used only locally (`lexsym`) stays a plain `datatype` (`LS_X of ()` -> `LS_X`).
L2. `libats/linqueue_arr` and `ngc/deque_arr` are gone: the lookahead queue of `lexbuf` and the token queue of
    `tokbuf` are `static inline` C ring buffers in the `.cats`; the ATS side sees them through `mac#` functions on a
    `$extype_struct "..." of {..}` that lists only the fields ATS touches. The string being collected by
    `lexing_DQUOTE` is a malloc-ed buffer (`patsopt_strbuf_*`) returned as a `Strptr1`.
L3. Initialising a flat struct with C-only fields: declare `vtypedef T_pre = $extype_struct "T" of {.., f= F?}`,
    `fun T_init (x: &T? >> T_pre) = "mac#.."`, then `F_initize (x.f)` makes the type `T` by itself (no `prfun` casts).
L4. A closure stored in a struct becomes a tagged struct (`reader`: kind + `ptr` + index, see `pats_reader.cats`).
    A `() -<cloptr1> int` argument is `() -<lincloptr1> int`; keep it as `ptr` with `$UN.castvwtp0{ptr}(f)`, call it
    through `$UN.castvwtp0{() -<lincloptr1> int}(p)` and free it with `cloptr_free($UN.castvwtp0{cloptr(void)}(f))`.
    `FILE m @ l | p` proofs became a `FILEref` (`reader_initize_filp (r, fp)` closes it in `reader_uninitize`).
L5. Missing runtime/prelude pieces (declared, no C): `g0int2uint_lint_uint`, `g0uint2int_size_lint` (use
    `$UN.cast{uint}(..)` in a small `fn`), `fopen_exn`/`fopen_ref_exn` (own C wrapper), `string_isnot_atend`,
    `string_contains`, `char_isspace`, `char_isdigit` (-> `isspace_char`, `isdigit_char`, `isxdigit_char`; scan a
    string with `$UN.ptr0_get<char>` until `'\000'`), `break`/`continue` (recurse), `fn*` with `{m,n}` indices.
L6. A string kept in a token: `string_of_strptr(s)` -> `strptr2gstring(s)` = `the_garena_strdup` + `strptr_free`.
L7. Hash table keyed by `string` (`hashtable_linprb` -> `hashtbl_linprb`): `hashtbl_make_nil<string,V>(i2sz(N))`
    kept in a toplevel `val ... = $UN.castvwtp0{ptr}(..)`, borrowed with `castvwtp0{hashtbl(..)}` around each
    `hashtbl_insert_opt`/`hashtbl_search_opt` (see `pats_symbol.dats`, `pats_lexing_token.dats`). `hash_key<string>`
    is `string_hash_multiplier (33UL, 5381UL, x)`.
L8. `list_vt` patterns: `case+ xs of list_vt_cons _ => .. xs ..` does not unfold (no `fold@`); `val list_vt_cons (!p, _) = xs`
    -> `val+ @list_vt_cons (x, _) = xs` ... `prval () = fold@ (xs)`; a flat `position` goes in with `var x: position`.
    `fn`/`fun` declared `a -> b` stays a function pointer: pass a named function (`ftesting_seq0 (buf, pos, DIGIT_test)`).
L9. Validation recipe (ATS1 reference): link a tiny ATS1 driver with the `src/pats_*_dats.o` of the modules
    (`test/lexdump1.sh`, `ATSHOMERELOC=ATS-0.2.12`; `pkgsrcname_relocatize` stubbed; the dynload order is the one of
    `pats_main.dats`) and diff its dump (`fprint_location` + `fprint_token` + kind of case/fun/val/fixity + int
    suffix + char code + the lexer errors) with `test/lexdump`. `patsopt` itself has no tokenize flag.

Open problems (lexer): the string reader keeps the ATS1 quirk (a char >= 0x80 is read as negative, i.e. EOF; the file,
getc and charlist readers are unsigned); `T_CDATA` is `(ptr, size_t)` (the lexer never makes it); every token node
(also a nullary one) is a 32-byte arena cell, never freed (a cache of the nullary ones would save ~1 cell per token);
`tokbuf_initize_filp`/`lexbuf_initize_filp`/`reader_initize_filp` take a `FILEref` (callers in `pats_parsing.dats`
must open the file with `fopen`, not `fopen_exn`, see L5); `fprint_token` still prints `CASE(...)`, `FUN(...)` etc.

## Arena AST (pats_syntax; the template for staexp1/dynexp1/staexp2/dynexp2/dynexp3/hidynexp)

`pats_syntax.sats/.dats`, `pats_syntax_print.dats` (the level-0 tree, 3 files ~6k lines) are ported. Spec:
`pats_syntax.spec` (387 lines, 69 records + 86 datatypes with 211 constructors); `make gen` produces
`pats_syntax_gen.hats` (included in the `.sats`) and `pats_syntax_gen_dats.hats` (`--compact`, included in the `.dats`).
`test/test_syntax.dats` builds trees with the real lexer tokens and prints them (`test_syntax.expected` was derived by hand
from `src/pats_syntax_print.dats`; `make test` diffs).

### Design (conventions to repeat in the later phases)

1. **Keep the ATS1 shape, change only the syntax.** An ATS1 record `'{x_loc= .., x_node= ..}` plus its datatype `x_node`
   become two arena types: `record x (x_loc: location, x_node: x_node)` and `type x_node` (constructors). The ATS1 field
   and constructor names are unchanged, so most of a function is renamed by a script. One more allocation per node than
   a merged "loc in every constructor" encoding, but the code of the phases stays line-for-line comparable with `src/`
   (`d2exp_make_node(loc, node)` and a `node` computed apart from the `loc` are frequent in trans*).
2. **Names** (for a spec type `T`; all of them non-templates, in the global arena, never freed):
   * record `R`: `R_new(a0, ..)` (was `'{..}`; `_make` is left to the hand-written smart constructors), getters `R.f` ->
     `x.f()` and `f(x)` (the field name itself, overloaded as `.f`). No tag word, no view.
   * datatype `N`: `N_CON(a0, ..)` (was `CON(..)`), `N_view(x)` (linear `datavtype N_view` with the original constructors,
     for pattern matching), `N_tag(x)`, `N_is_CON(x)`, `N_encode`, `N_view_free`. A one-constructor `type` with named
     fields gets `N_get_F(x)` and `x.F()`.
   * `typedef`/`vtypedef` lines of the spec are copied to the `.sats` after the abstypes: `s0explst = glist(s0exp)`,
     `s0expopt = gopt(s0exp)`, `s0explst_vt = List_vt(s0exp)`. `List`/`Option` of ATS1 -> `glist`/`gopt` (the
     tuples `sl0abeled(a)`/`dl0abeled(a)` became the records `labs0exp`/`labd0exp`: no polymorphic type in the spec).
   * Enum-only datatypes (`srpifkind`, `macsynkind`, `cstsp`, `e0xpactkind`) stay datatypes: `MSKxstage` in an expression,
     `MSKxstage ()` in a pattern. A constructor name used twice (`D0Cextype` of 2 and of 3 arguments) is renamed
     (`D0Cextype2`).
3. **Matching.** `case+ x.s0exp_node of | S0Eapp (a, b) => ..` becomes
   `case+ s0exp_node_view(x.s0exp_node()) of | ~S0Eapp (a, b) => ..` (`~` always). A wildcard arm cannot be written (the
   scrutinee is linear and not a left value): `| v => (s0exp_node_view_free(v); default)`, or, for a mere test,
   `s0exp_node_is_S0Eapp(x.s0exp_node())`. Lists and options: `case+ glist_view(xs) of ~GLnil() | ~GLcons(x, xs)`,
   `gopt_view(o) of ~GOnone() | ~GOsome(x)`, as in rule 9. The view costs a malloc/free (~11 ns per match, `-O2`,
   measured over 20M matches; `N_is_CON` ~3 ns): fine for a compiler, avoid it in a hot loop that only needs the tag.
4. **Cheap generated code: `--compact`.** The default `--global` output (`arena_store<T>(ptr_add<byte>(p, k), a)` per field)
   makes patsopt instantiate a template per field per use: for this spec 408k lines / 14.7 MB of C, `gcc -O0` 4.0 s.
   With `--compact` (new, used here) a field is a word read/written by 2 non-template helpers with casts
   (`$UN.cast{ptr}($UN.cast{lint}(a))`, no warnings): 162k lines / 6.4 MB (2.3x smaller), `gcc -O0` 1.8 s,
   `-O2` 3.9 s (the rest is instances of `glist_view<..>` etc. at each match, ~300 sites). Fields must be scalars of at
   most 8 bytes (int, bool, char, enums, pointers/handles). Use `--compact` for all the new specs; the 4 older specs
   (`location`, `label`, `fixity`, `lexing_token`) can be switched by adding it to `make gen`.
5. **Where tokens/the parser come in.** `token` is the lexer's. Everything that was `val-T_STRING(s) = tok.token_node`
   is a helper of `pats_syntax_token.hats` (`token_string_get`, `token_int_rep`, `token_knd_get`, `token_fixity_get`,
   `token_srpif_get`, ...; a wrong token is `assertloc(false)`, the `MatchError` of ATS1). The only thing taken from the
   parser, `parerr_p0at_as` and `parerr_add_ifunclosed` (in `pats_syntax_boundary.sats`), must be implemented by
   `pats_parsing` (the tests give stubs).
6. **Mechanical help.** `utils/arenagen/spec_from_sats.py X.sats > draft.spec` drafts a spec from an ATS1 `.sats`;
   `utils/arenagen/port_ats1.py X.spec src/X.dats draft.dats` does the record/constructor/case/field/option/list rewriting
   (read its header); the rest of the port is by hand: wildcard arms (about 15 in all), `glist_last_opt` (a small
   template at the top of `pats_syntax.dats`: it is `list_last_opt`), closures (`s0exp_lams` aux was lambda-lifted),
   `List_vt` of unknown length -> `List0_vt` (`e0xp_funize`), `{n:nat}` list indices (dropped), `fun` vs `fn`.
   Most of the ~290 functions of `pats_syntax.dats` came out of the script unchanged; ~15 needed a hand edit.
7. **The arenagen changes** (`utils/arenagen/arenagen.py`, upward compatible, the 3 old generated files are unchanged):
   `record NAME (f: T, ..)` (flat, no tag, `NAME_new`, getters `f`), `typedef/vtypedef` pass-through lines, `--compact`.
   Mutual recursion needed nothing: all the types of one spec are one `datavtype .. and ..` group declared after all
   the abstypes. Not done: a field wider than 8 bytes, a parametric type, a `T_view` that does not allocate.

Scalability data (this spec): generator 0.1 s; `patsopt -d pats_syntax.dats` 0.4-0.6 s (print: 0.25 s); typecheck of
the `.sats` 0.05 s; C 162k lines (2.6 MB without comments) for 2161 functions; object 142 KB (`-O2`). For comparison
the ATS1 C of `src/pats_syntax.dats` is 12k lines / 557 KB. The ATS1 source is 3.6k+1.6k lines, ours 3.0k+1.7k+6.4k (generated).
Expect the same per-constructor cost (a C function of ~40 lines for the constructor, one for `_is_`, one for each of
view/free/encode arms) in the later phases; `s2exp`/`d2exp`/`hidexp` with 100+ constructors are fine.

### Open problems (pats_syntax)

* `pats_parsing` must provide `parerr_p0at_as` and `parerr_add_ifunclosed` (declared in `pats_syntax_boundary.sats`);
  `d0ecl_pragma_process` (location pragma) is ported and calls `$LOC.the_location_pragma_set`.
* The view is a malloc per match. A flat alternative (return the fields through `&` arguments, or generate `N_CON_get_k`
  accessors for tag-tested code) was not generated.
* `synent` (the boxed union of the parser) is `synent_type = ptr` with template `synent_null<a>()`; the parser decides
  whether it is still needed.
* `fprint_staloadarg`/`fprint_guadecl` stay commented out as in ATS1. `D0Cextype2` (3 arguments) is a rename.
* Not covered by `test_syntax`: the statics of `d0ecl_datdecs_*`, `v0ardec_make`, `d0ecl_staload_*` (they typecheck, are
  mechanical and need filenames/parsing state). `make test` has no sanitizer run; I ran the driver once with
  `-fsanitize=address` (no error, no leak report).

## Parser, phase 1 (pats_parsing.sats, _util, _base, _error, _kwds, _e0xp, _sort, _staexp, pats_parsing.dats, _toplevel)

Done: everything in the title, plus `pats_parsing.hats` (token-payload helpers). Typechecked, linked into `test/pardump`
(`make test` diffs it with `test/pardump.expected`, produced by the ATS1-built parser) and compared with the ATS1 parser on
271343 fragments (see "Validation" below): 0 differences, no AddressSanitizer error or leak.
NOT done (declared in `pats_parsing.sats`, implemented by phase 2 = `pats_parsing_{dynexp,p0at,decl}.dats`): `p_p0at`, `p_pi0de`,
`p_labp0at`, `p_f0arg1/2`, `p_d0exp`, `p_di0de`, `p_d0ynq`, `p_dqi0de`, `p_labd0exp`, `p_arrqi0de`, `p_tmpqi0de`, `p_eqd0expopt`,
`p_d0expsemiseq`, `p_i0fclseq`, `p_c0lauseq`, `p_sc0lauseq`, `p_d0ecl`, `p_d0ecl_sta`, `p_d0ecl_dyn`, `p_d0eclseq_{fun,sta,dyn}`,
`p_d0atsrtdecseq`, `p_s0rtdefseq`, `p_s0taconseq`, `p_s0tacstseq`, `p_t0kindef`, `p_s0expdefseq`, `p_s0aspdec`, `p_e0xndecseq`,
`p_d0atdecseq`, `p_m0acdef`, `p_d0cstdecseq`. Already-ported code that needs them (marked TODO in the files): `p_S0Ed2ctype`
(`p_di0de`, `p_dqi0de`, `p_tmpqi0de`), `p_a0typ` (`p_pi0de`), `p_e0xndec`/`p_d0atcon` (`p_di0de`), `p_toplevel_sta/dyn` and
`parse_from_*_toplevel` (`p_d0ecl_sta/dyn`). `test/pardump.dats` stubs `p_di0de p_pi0de p_dqi0de p_tmpqi0de p_d0ecl_sta p_d0ecl_dyn`
(abort): phase 2 must delete the stubs (and may add `pats_parsing_{dynexp,p0at,decl}.dats` to `PARSRC` in `test/Makefile`).

### Rules (P1-P12)

P1. **Parser type.** `typedef parser(a:type) = (&tokbuf, int(*bt*), &int(*err*)) -> a` is a plain function pointer; a parser is declared in
    the `.sats` as `fun p_X : parser(T)` and implemented with `implement p_X (buf, bt, err) = ..` (this ATS2 form works). Local
    parsers are `fun p_Y (buf: &tokbuf, bt: int, err: &int): T`. Failure = `synent_null<T>()` (a null pointer) and `err := err + 1`; the
    caller never looks at the value (like ATS1). `parser_tok(a)` and `ptokwrap_fun<a>(buf, bt, err, f, PE_X)` are unchanged.
P2. **Combinators are templates** (`fun{a:type} pstar_fun(buf, bt, f: parser(a)): List0_vt(a)`, `popt_fun`, `pstar_sep_fun`, `pstar_fun0_{sep,BAR,COMMA,
    SEMICOLON,BARSEMI}`, `pstar_fun1_{sep,AND}`, `pstar1_fun`, `pseq2_fun`, `pseq3_fun`, `ptest_fun`, `plist12_fun`, `p1list12_fun`, `pif_fun`,
    `ptokwrap_fun`, `ptokentopt_fun`, `tokbuf_set_ntok_null`, `list12_free`, `parse_from_string_parser`). Always write the type
    argument (`pstar_fun0_COMMA<s0exp>(buf, bt, p_s0exp)`, `synent_null<s0exp>()`, `pif_fun<token>(buf, bt, err, p_RPAREN, err0)`,
    `tokbuf_set_ntok_null<d0ecl>(buf, n0)`): it is inferred in most places but not all. A `.dats` that calls one must have
    `staload _ = "./pats_syntax.dats"` (for `synent_null`) and `staload _ = "./pats_parsing_util.dats"` (rule 16); `pats_parsing.dats` also
    `staload _ = "./pats_error.dats"` (`abort<void>`), and a driver that calls them does the same (see `test/pardump.dats`).
    The ATS1 `pstar_fun` filled a cell in place with `fold@`; here an accumulator is reversed at the end (same calls, same order, same `err`
    handling). A `List_vt(T)` result is written `List0_vt(T)` (rule 8): `s0explst_vt = List_vt(..)` of `pats_syntax.sats` gives an unsolved
    constraint in `glist_make_list_vt`, write `List0_vt(s0exp)`.
P3. **Lists and options of the tree.** The ATS1 abbreviations are `#define l2l glist_make_list_vt` (`List_vt` -> `glist`) and
    `#define t2t gopt_make_option_vt` (`Option_vt` -> `gopt`); `Some(x)`/`None()` are `gopt_some(x)`/`gopt_none()`; `case+ opt of Some s0t => ..` is
    `case+ gopt_view(opt) of ~GOsome s0t => .. | ~GOnone() => ..`. A glist/gopt that is empty is a null pointer, exactly like the
    `synent_null` of a failed parser (as in ATS1).
P4. **Tokens.** `case+ tok.token_node of T_X _ => .. | _ => ..` is an `if .. else if` chain on `token_node_is_T_X(tnd)` with `val tnd = tok.token_node()`
    (order preserved, a `_ when ptest_fun(..)` arm is an `if ptest_fun<T>(..)` arm). A pattern with a payload (`T_IDENT_alp(x)`) is a match
    on `token_node_view(tnd)` with `~T_IDENT_alp(x) => .. | v => (token_node_view_free(v); <default>)`. `val-T_STRING(s) = tok.token_node` is
    `token_string_get(tok)` (`pats_syntax_token.hats`); the `int` of `T_DLRTUP/T_DLRREC/T_WITHTYPE` is `token_knd2_get(tok)` (`pats_parsing.hats`;
    add the helpers that dynexp/p0at/decl need there). `is_X(tnode)` (`pats_parsing_kwds.dats`) are `token_node_is_T_X(x)` (`||` for several).
P5. **`ptest_fun` needs an initialized `ent`:** `var ent: synent = synent_null<synent>()` (it was `var ent: synent?`): ATS2 cannot merge a
    `synent?` with a `synent` over the branches that do not call `ptest_fun` ("fails to merge"), and a `synent` cannot be passed to a
    `&synent? >> synent` argument. The signature is now `ent: &synent >> synent`. `synent_decode{i0de}(ent)` as before. In the same way an
    `&filename? >> filename` argument (`parse_from_givename_toplevel2`) cannot get an already initialized variable: pass a fresh `var fil1: filename`.
P6. **Errors** (`pats_parsing_error.dats`): `parerr_node` is an enumeration (`PE_fname_unclosed`, `PE_DISCARD` lost their `of ()`), `parerr` a flat
    record `@{parerr_loc, parerr_node}` (read `x.parerr_loc`), the list of errors a `glist` in an arena cell (as `pats_lexing_error.dats`),
    messages are the same (`fprintf` -> `fprint_string`). `parerr_p0at_as` and `parerr_add_ifunclosed` of `pats_syntax_boundary.sats` are
    implemented here (the tests of `pats_syntax` keep their stubs, they do not link the parser).
P7. **`case+ 0 of _ when .. =>`** chains and `break/continue`: `if`/`else if` and recursion; a `where`/`let` that bound `bt` to 0 in an arm
    still shadows it for the rest of the arm (kept: it decides whether an error is recorded).
P8. **I/O of `pats_parsing.dats`:** `fopen_exn` -> `fileref_open_exn(fname, file_mode_r)` (the file is closed by `tokbuf_uninitize`); the `getc` closure of
    `parse_from_fileref_toplevel` is `llam () => fgetc0(inp)` (freed by the tokbuf); `givenames` is a `glist(string)`; `$raise` is written as
    the last expression of its branch (`val () = $raise ..` does not typecheck). `parse_from_string_parser` returns `Option_vt(a)`.
P9. **A comment glued to a call.** `glist_nil(*deadcode*)` is the function `glist_nil` followed by a comment, not a call: write `glist_nil((*void*))`.
P10. **Local `var ent` etc. inside the `case`-less chains** are fine; `val ~SYNENT2 (ent1, ent2) = pseq2_fun<i0de,token>(..)` replaces `val+~SYNENT2`.

### Validation (ATS1 reference)

`test/pardump1.dats` (ATS1) and `test/pardump.dats` (ATS2) are generated from one table by `test/pardump_gen.py`: they read a file of
fragments `KIND<TAB>text`, call the parser of that kind through `parse_from_string_parser`, print the result with the `fprint_*`
of the syntax tree (or a custom printer with locations for `s0arg s0marg a0srt a0msrt d0atsrtconseq witht0ype s0vararg e0fftaglst colonwith
extnamopt datsdef t0mpmarg`), then the lexer and parser error lists (`FAIL` if the parser failed). 40 kinds: `s0rt s0exp atms0exp e0xp e0xpseq
s0rtext s0quaseq s0qua q0margseq s0exparg labs0exp p0rec l0ab i0de i0dext i0de_dlr si0de s0rtid s0rtq s0taq sqi0de .. i0nt s0tring ..`.
`test/parcorpus.py` builds the corpus: fragments cut from the sources of `prelude libats doc contrib src src2` (RHS of `stadef/typedef/sortdef/#define`,
`: sort` annotations, `{..}`/`(..)`/`[..]` groups, tokens, line prefixes/suffixes), random token sequences (`FUZZ=N`), grammar-directed random
static expressions with mutations (`GFUZZ=N`), and `parcorpus.hand` (416 cases: unbalanced brackets, `@(..)`, `'{..}`, `$extype..`, `lam`, `@[a][n]`, ...).
Environment of `make -C test pardump1`: as for `lexdump1` (ATS1 `ATSHOME`, `ATSHOMERELOC=ATS-0.2.12`, gcc wrapper) and the objects built in `src/`.

    FUZZ=60000 GFUZZ=150000 python3 parcorpus.py 70 $(find ../../prelude ../../libats ../../doc ../../contrib ../../src ../../src2 -name '*.[sdh]ats') > corpus.txt
    make parcompare CORPUS=corpus.txt           # 271343 cases, 901807 output lines: identical

Result: 271343 cases (85420 succeed, the rest are error paths: the error lists and their locations are compared too), 0 mismatches;
the AddressSanitizer build (`-fsanitize=address`) of `pardump` ran 60000 cases without error and 20000 with leak detection without a leak report.
Not covered: `$d2ctype(..)` (calls `p_di0de`..), `a0typ`, `d0cstarg`, `e0xndec`, `d0atcon` (the dynamic stubs), `parse_from_*_toplevel` (need `p_d0ecl_*`).

### Open problems (parser phase 1)

* `parse_from_*_toplevel`, `p_toplevel_*` and the `p_S0Ed2ctype` path link only with phase 2; their ports are line-for-line but untested.
* The error recovery state (`the_parerrlst`) is global (as in ATS1); `fprint_the_parerrlst` empties it.
* `fprint_parerr` keeps the ATS1 oddity `PE_DOT => KN(x, ",")` (the message says `,`).
* Each token test allocates nothing (`token_node_is_T_X`), but a payload match is a malloc/free (rule 3 of "Arena AST"): `p_si0de`, `p_i0de` and
  friends do one per call; if the parser turns out to be slow, add `token_ident_alp_get`-style helpers that return the string without a view.

## Parser, phase 2 (pats_parsing_p0at, pats_parsing_dynexp, pats_parsing_decl)

Done: the three modules (5.35k lines of ATS1 -> 5.85k of ATS2), `pats_parsing.hats` (more token helpers), the template
`p_d0eclseq_fun` (moved to `pats_parsing_util.dats`), the stubs of `test/pardump.dats` are gone, `src2/Makefile` and
`test/Makefile` list the new files. Every parser of `pats_parsing.sats` is implemented (`p_c0har`, `p_f0loat` are declared and
never implemented in ATS1 either). `utils/arenagen/port_parser.py` made the first draft of the three files (about 90% of the text);
the hand work was ~30 edits, listed below.

### Rules (P11-P18; P1-P10 above still apply)

P11. **`case+ tok.token_node of` is an `if` chain** (script: `port_parser.py`; the arms keep their order, `_ when f(..)` is
     `if f(..)`, `tnd when is_X(tnd)` binds `tnd`):

         case+ tok.token_node of                         let val tnd = tok.token_node() in
         | T_DLRLST (lin) => body1             ==>       if token_node_is_T_DLRLST(tnd) then (let val lin = token_ival_get(tok) in body1 end)
         | _ when ptest_fun(buf, p_x, ent) => b2          else if ptest_fun<x>(buf, p_x, ent) then (b2) else (b3) end

     The payload of a token is a helper of `pats_parsing.hats`: `token_ival_get` (the `int` of DLRLST/DLRTUP/DLRREC/ABSTYPE/MACDEF/TYPEDEF/
     DATATYPE/VAR/IMPLEMENT/LAM/FIX/DLRVCOPYENV/DLRDELAY/DLREFFMASK_ARG), `token_sval_get` (the `string` of IDENT_alp/sym/arr/tmp/dlr and STRING),
     `token_fun_get` (funkind), `token_val_get` (valkind). A `where {..}` after the last arm belongs to that arm (the ATS1 rule),
     keep it inside the parentheses of the arm.
P12. **`(())` is not `()`**: an arm whose body is `()` must not be wrapped in parentheses (`then ()`), `(())` is a 1-tuple and the arm types
     differ ("S2Etyrec(flt0)" vs void).
P13. **A template is instantiated only where its implementation is visible**: `p_d0eclseq_fun` is used by dynexp and decl, its implementation
     is in `pats_parsing_util.dats` (every user has `staload _ = "./pats_parsing_util.dats"`). The ATS1 version filled a cell in place
     (`fold@`); the new one reverses an accumulator, the semantics are the same (the first failing item ends the sequence and is dropped).
P14. **`fun` in a `.dats` that the `.sats` declares is a different static function in ATS2**: `p_t0kindef` and `p_s0aspdec` were `fun` in
     ATS1 and are `implement` here (the program linked, but nothing called them from outside; in ATS1 they are not exported either, so they
     have no `pardump` kind -- they are reached through `d0ecl_sta/dyn`).
P15. **Strings**: `"$" + name` -> `val dn = string0_append("$", name)`, `i0de_make_string(loc, $UN.strptr2string(dn))`, `strptr_free(dn)`
     (`symbol_make_string` copies the name into the arena). A datatype constructor with a prefix: `STLDfname(loc, name)` -> `staloadarg_STLDfname(loc, name)`.
P16. **Type aliases of vt-lists**: `p0atlst_vt`, `d0eclist_vt`.. -> `List0_vt(p0at)`, `List0_vt(d0ecl)` (rule 8: `n >= 0` is unsolved otherwise);
     `viewtypedef` -> `vtypedef`; `Option(T)` -> `gopt(T)`; `Some/None/list_cons/list_nil` as in P3; `(l2l)xs` -> `l2l(xs)`.
P17. **Template arguments** of the combinators are always written (`pseq3_fun<l0ab,token,p0at>`), also `synent_null<T>()` and
     `tokbuf_set_ntok_null<T>(buf, n0)` with `T` the result type of the enclosing parser; when the result is an option it is `gopt(i0nvresstate)` etc.
P18. **`var _ent: synent?`** (the name may begin with `_`) is `var _ent: synent = synent_null<synent>()` (P5).

### Validation (all against the ATS1 parser built from `src/`; `make -C test parcompare|parfiles`)

* `test/pardump_gen.py` now has 77 parser kinds (+ TOPsta/TOPdyn: text, FILEsta/FILEdyn: path, PGN*/PFR*/PGNL*: the entry points
  `parse_from_givename_toplevel2`, `parse_from_fileref_toplevel`, `parse_from_givenames_toplocal2` of `pats_parsing.dats`, TIME*: speed). New kinds
  p0at pi0de labp0at f0arg1 f0arg2 d0exp di0de d0ynq dqi0de arrqi0de tmpqi0de labd0exp eqd0expopt d0expsemiseq i0fclseq c0lauseq sc0lauseq
  S0Ed2ctype a0typ d0cstarg e0xndec d0atconseq q0marg d0ecl d0ecl_sta d0ecl_dyn d0eclseq_sta d0eclseq_dyn d0atsrtdecseq s0rtdefseq s0taconseq
  s0tacstseq s0expdefseq e0xndecseq d0atdecseq m0acdef d0cstdecseq (the phase 1 kinds are unchanged).
* **`test/deepdump_gen.py`** generates from `pats_syntax.spec` a *complete* dumper of the level-0 tree (every field, every location; 110 records/datatypes and the list/option aliases) in
  ATS1 (`deepdump1.hats`) and ATS2 (`deepdump.hats`). `fprint_d0ecl` of `pats_syntax_print.dats` prints `D0Cfundecs(...)`, so it cannot be used to
  compare trees. In ATS1 `labs0exp`, `labd0exp`, `datsdef` are one-constructor datatypes (`SPECIAL1` in the script).
* `test/parcorpus.py` additions: statements cut from the files (comments blanked, split at blank lines, `\x01` stands for a newline in a text and
  is mapped to `\n` by `pardump.cats`), fragments of every line for the new kinds, token-level mutations of statements, a grammar-directed
  generator of patterns/expressions/declarations (`DGFUZZ`), random token sequences (`DFUZZ`), mutations of whole files (`FMUT`, toplevel error
  recovery), `SEED`. `parcorpus.hand` has 1373 lines (all constructs and their truncations).
* Results: **3.09 million fragments** (4 seeds, `FUZZ=20000 GFUZZ=40000 DFUZZ=120000..150000 DGFUZZ=200000..300000 FMUT=3000..4000`; 566888 + 2521407 cases,
  all 80 kinds; ~45% fail on purpose, the error lists with locations are compared too): **0 differences**. **Whole files**: 2637 paths
  (2141 distinct files: prelude, libats, src, src2, doc, contrib, utils, npm-utils, share; 2114 under prelude libats src src2 doc/EXAMPLE contrib
  with symlinks followed) parsed with the toplevel parser and dumped completely, 238 MB of dump, 101 of the files have lexing or parsing errors
  (ATS1 sources in contrib, doc/BUGS): **0 differences** (`make parfiles`, 3 s). The entry points `PGN/PFR/PGNL` on the 2497 error-free files: 0 differences
  (the abort `FatalErrorExn` of a file with a lexing error happens at the same place with the same message).
* Coverage of the ATS2 code (gcc `--coverage` with `patsopt --gline`, gcov by ATS line) with the corpus above: p0at 360/360 executable lines, toplevel 62/62,
  decl 765/765 (after `parcorpus.hand`), dynexp 1044/1045 (a line that gcov attributes to a template instance).
* AddressSanitizer (`-fsanitize=address`, leak detection on) on 400000 fragments + `parcorpus.hand` + 280 whole files + the entry-point chunks:
  no error, no leak (the arena is reachable from the global arena handle; only the harness's own file buffer leaked and is fixed).

### Open problems / notes (parser phase 2)

* **Speed.** Parsing `src/pats_syntax.dats` (76 KB) 40 times: ATS1 (`-O2` objects of `src/`) 0.37 s, ATS2 `patscc -O2` 0.35 s, ATS2 `patscc` without `-O`
  2.66 s (the default of `make test`; the views `token_node_view` do a malloc/free per payload match, `-O2` inlines most of it). Memory 134 MB for the 40
  parses vs 186 MB (ATS1, no GC either). A `patsopt` built from `src2/` must be compiled with `-O2`.
* `p_t0kindef` / `p_s0aspdec` have no fragment kind (not exported by ATS1); `p_c0har` / `p_f0loat` do not exist.
* The `(let val tnd = .. in if .. end)end` shapes of the generated chains are ugly but regular; a hand-written parser would use a `tokbuf_get_tnode`.
* `parse_from_tokbuf_toplevel` aborts (`$ERR.abort`) when there is an error, as in ATS1: the `PGN*`/`PFR*` kinds are only run on error-free files.
* `parse_from_stdin_toplevel` and `parse_from_string_toplevel` are not exercised (same code as `PFR*`/`TOP*`).

## Level 1: pats_effect, pats_staexp1, pats_dynexp1, pats_e1xpval (+ the e1xpenv of pats_trans1_env)

Done: `pats_effect.{sats,dats}` (needed by staexp1: `effset` is the field of `EFFCSTset`), `pats_staexp1.{sats,dats}`, `pats_staexp1_print.dats`,
`pats_dynexp1.{sats,dats}`, `pats_dynexp1_print.dats`, `pats_e1xpval.{sats,dats}`, `pats_e1xpval_error.dats`, and a PARTIAL
`pats_trans1_env.{sats,dats}` that only has the environment of the `#define`d expressions (`the_e1xpenv_add/addperv/find/pop/push_nil`; the
`e1xpval` evaluator needs `the_e1xpenv_find`; the trans1 port must extend these two files, not replace the declarations). Specs
(`make gen`, all `--global --compact`): `pats_staexp1.spec` (14 datatypes, 29 records, 73 constructors), `pats_dynexp1.spec` (5 datatypes, 18
records, 139 constructors), `pats_e1xpval.spec` (`valerr`, 14 constructors). Sizes: ATS2 sources 8.0k lines (ATS1: 8.4k; the types are in the 3 specs),
generated hats 0.25 MB, C 225k lines (-O0).

### Rules (L1-1 .. L1-8; the rules of "Arena AST" and P1-P18 still apply)

L1-1. **Names.** As for pats_syntax: `e1xp_new(loc, node)`, `e1xp_node_E1XPide(id)`, `case+ e1xp_node_view(e.e1xp_node()) of ~E1XPide id => ..`,
      `s1exp_node_is_S1Eide(..)`. A datatype without record (`v1al`, `effcst`, `s1vararg`, `i1mparg`, `witht1ype`, `wths1explst`) is used directly:
      `v1al_V1ALint(3)`, `case+ v1al_view(v) of ~V1ALint i => ..`. The one-constructor datatypes `sl0abeled(s1exp)` / `dl0abeled(d1exp)`
      (`labs1exp`, `labd1exp`) are records `labs1exp_new(l, name, s1e)` (fields `labs1exp_lab/_nam/_elt`), like `labs0exp`. `D1Cextype` of 3
      arguments is `D1Cextype2` (as `D0Cextype2`). `Stropt` (`D1Cpackname`), `effset`, enums, `bool` and `char` are plain words of a field.
L1-2. **A double in a field.** `--compact` casts every field through `lint`: wrong for a `double` (`V1ALfloat`). `arenagen.py` now stores a field whose type
      is in `DWORD` (= `double`) by value (`<stem>_ldd/_std`); the 4 older generated files are byte-identical.
L1-3. **`val x : T` of a boxed type** (`v1al_true`, `effcst_nil..wrt`, `i1nvresstate_nil`, `effect_ntm`, `effset_*`) needs a C name (rule 18):
      `val effcst_nil : effcst = "ext#patsopt_effcst_nil"`; they are built when the module is dynloaded (arena first).
L1-4. **Closures that capture a location become parameters.** `s1exp_make_e1xp`, `e1xp_make_s1exp`, `p1at_make_e1xp`, `e1xp_make_p1at`,
      `d1exp_make_e1xp`, `e1xp_make_d1exp` had `aux`/`auxlst` with `:<cloptr1>`/`:<cloref1>` capturing `loc0`: now top-level `fun X_aux (loc0, e)`
      / `X_auxlst (loc0, es)` and `implement X (loc0, e) = X_aux (loc0, e)`. Nothing is stored in a data structure at this level.
L1-5. **The local environments of the evaluator** (`lenv`, an abstract linear list of `@(symbol, a)` with a `list_assoc_fun` and a `lam` comparison) are
      `vtypedef lenv(a) = List0_vt(@(symbol, a))`, the lookup a template `lenvfind<a>` that compares with `eq_symbol_symbol` (no closure). The
      `v1al` of a pair of operands is read with `v1al_int_get/_float_get/_string_get` and `v1al_is_V1ALint` (no view per match: the ATS1
      `case+ (v1, v2) of (V1ALint i1, V1ALint i2) => ..` became `if is_int v1 andalso is_int v2 then ..`, same order of evaluation and errors).
      `string + string`: `string0_append` then `the_garena_strdup` (the result may outlive the call). `double_of_string` is `g0string2float_double`,
      `int_of_llint` is `$UN.cast{int}`, `string_is_empty` needs `g1ofg0`.
L1-6. **The global state**: the error list of the evaluator is a `glist` in an arena cell (`gcell_make`, as pats_lexing_error); the e1xpenv is a
      never freed `symenv(e1xp)` kept as a `ptr` and borrowed with `$UN.ptr0_vtake{symenv(e1xp)}` (`pats_trans1_env.dats`). The proofs
      `e1xpenv_push_v` of ATS1 are dropped (`the_e1xpenv_pop (): symmap(e1xp)`, `the_e1xpenv_push_nil (): void`).
L1-7. **An exhaustive match must keep its `_` arm as explicit arms**: `fprint_d1ecl` ended with `| _ => prstr "D1C...(...)"` (dead code for all the
      constructors but `D1Ctkindef` and `D1Creassume`): a `_` arm makes the linear scrutinee "not a left value"; list the constructors.
      A `fold@` is wrong after `list_vt_nil` (rule 8); a function that reads a `!List0_vt` goes through `@list_vt_cons` + `fold@`.
L1-8. **`port_ats1.py` changes** (backward compatible): the case scrutinee is wrapped also when a comment separates `of` from the first arm, and the
      string literals are no longer rewritten (`prstr "E1XPint("` stayed `"e1xp_node_E1XPint("` before; the old output was repaired by a post-pass).
      Still by hand: wildcard arms, `where` blocks on a rewritten arm, closures (L1-4), `fprintf`, `fold@`, the header (`#include "share/atspre_staload.hats"`,
      arena, `pats_lexing.sats`, `pats_syntax_boundary.sats`, `pats_syntax_token.hats`, the `*_gen_dats.hats` include: ONE `.dats` includes it).

### Validation (ATS1 reference = the objects of `src/`; `make -C test e1xcompare|e1xfiles|treecompare`)

* **trees and printers** (`test/tree1_gen.py` -> `treecases.hats`/`treecases1.hats`, `deepdump_l1.hats`/`deepdump1_l1.hats`; drivers `treedump.dats` / `treedump1.dats`):
  2663 cases, each dumped completely (`dd_T`, every field and location) and with the `fprint_T` of the ATS1 printers (32 printers): a tree for each of the 212
  constructors (73 + 139; also `lists` of 0/1/2 elements, options none/some), the 47 records, and a call of 267 functions of the two `.sats` files (every smart
  constructor; `s1exp_list`, `p1at_list`, `d1exp_list`, `s1rt_list` with 0/1/2 elements for the singleton elimination; every constructor of the argument for the
  conversions `*_make_e1xp/_s1exp/_p1at/_d1exp/_v1al` and `d1exp_sing`, `d1exp_is_metric`, `d1exp_ann_funclo_opt`, `s1rt_is_arrow`, `wths1explst_*`, `effcst_contain`)
  plus the constants and the `pats_effect` operations: 7995 lines, **identical** (also under `-fsanitize=address`: no error, no leak). The 5 functions that the ATS1
  `.sats` declare and nobody implements (`fprint_d1atcon`, `fprint_d1atdec`, `fprint_s1var`, `s1var_make`, `sp1at_arg`) are not implemented here either.
* **the evaluator** (`e1xdump.dats` / `e1xdump1.dats`, `e1xcorpus.py`): the driver parses `KIND<TAB>text` lines with the toplevel parser and plays the
  directives of the declarations: `#define`/`#undef` (e0xp -> e1xp translation = `e0xp_tr` with a precedence climbing for a fixed operator table in place of the
  fixity environment, add to the e1xpenv, print the e1xp, `e1xp_valize`, `e1xp_normalize`), `#print`/`#error`/`#assert` (evaluate and print),
  `#if/#ifdef/#ifndef/#elif/#else` (`e1xp_valize_if`, the chosen branch is played); `FatalErrorExn` of an aborting evaluation is caught (`ABORT`), each case in a fresh
  scope of the e1xpenv. Corpus: 82 hand cases (every branch of `pats_e1xpval.dats`, deep recursion, arities, `defined`, floats, strings, shadowing), 8 chains of
  defines, 3000 random programs and 3000 well-typed programs (seed 1): 6090 cases, 265139 output lines (8463 `VAL V1ALint`, 2273 floats, 2216 strings, 12449
  `#print` errors, all the error kinds of `fprint_valerr` but the dead `<<`/`>>` natural-number check, 3417 conditions): **identical**; the whole-file mode
  (`make e1xfiles`: the 2658 `.sats/.dats/.hats` of the repository, 2947 directives, `#if` chains of the libraries): **identical**; ASan on all of them: no error;
  one leak report only when an evaluation aborts inside `e1xp_normalize` (the linear `lenv` is not freed on the exception path, as in ATS1).
* Sensitivity: 3 deliberate bugs (an `npf+1` in `d1exp_list`, `<=` -> `<` in `lteq`, a changed string in `fprint_s1exp`) are caught (5 and 62 differing lines).
* `make test` (no ATS1 needed): `e1xdump e1xcorpus.hand` is diffed with `e1xdump.expected`, the md5 of `treedump` with `treedump.md5` (both from ATS1).

### Notes for the trans1 port

* Needs from this level: `staexp1/dynexp1` (all constructors, `*_make` smart constructors with the ATS1 names), `e1xpval` (`e1xp_valize`, `e1xp_valize_if`,
  `e1xp_normalize`, `v1al_is_true`, `fprint_the_valerrlst`, `the_valerrlst_add`), `pats_effect`, and `pats_trans1_env` (to be completed: fixity env, staload table, ...).
  The ATS2 `.dats` that includes the `*_gen_dats.hats` is the only one that may; others use the `.sats` functions (`e1xp_node_view`, ...).
* `e0xp_tr` of `pats_trans1_e0xp.dats` is the piece that needs `pats_fixity`: its `appf` and `e1xp_get_loc` are closed (no free variable): plain function
  pointers for `fxitm_app<e1xp>`/`fixity_resolve<e1xp>`; the `lam (loc, x, loc_arg, xs) => e1xp_app (..)` of `e1xp_make_opr` is a named function. The test drivers
  show an alternative (`e1xdump.dats`, operators by a table through a C buffer shared by the ATS1 and ATS2 drivers).
* `the_e1xpenv_pop/push_nil` have no proof argument. `e1xpenv` values are `e1xp` (a `type`), so `symenv<e1xp>` templates need `#include "./mylibies.hats"`.
* A trans1 function that matches a `v1al` / `e1xp_node` / ... is a malloc/free per match (rule 3); use `*_is_*` for tests.
* Dynload order: error, basics, utils, symbol, label, filename, location, effect, lexing modules, syntax, staexp1(_print), dynexp1(_print), symmap, symenv,
  trans1_env, e1xpval(_error).

### Open problems (level 1)

* `pats_trans1_env` is partial; `the_e1xpenv_localjoin/save/restore` are not ported.
* The e0xp -> e1xp translation of the tests is not the real `e0xp_tr` (no fixity environment): the ATS1/ATS2 comparison is of the evaluator and the trees, not of
  trans1; the operator table (`e1xdump.cats`) is `* / + - << >> comparisons && ||`, left associative, prefix `~`.
* `/` by zero kills both programs (SIGFPE, as in ATS1): excluded from the random corpus. `e1xplevenv_valize_asl/asr` are dead code (as in ATS1, `<<`/`>>` are not dispatched).
* Errors of `s1exp_make_e1xp` etc. are written with a local `prerr_error1_loc` to stderr (not `pats_errmsg`), as in ATS1; the comparison merges stderr into stdout.
* `treecases*.hats` are 1.1 MB each (generated; `make -C test gen`); `patscc` of `treedump.dats` takes 40 s (no `-O`).

## Level 1 translation: pats_trans1*, pats_global, pats_filename_reloc (rules T1-1 .. T1-12)

Done: `pats_trans1.sats` (+ `pats_trans1.spec`, `pats_trans1_gen*.hats`: `trans1err` generated by arenagen), `pats_trans1_env.{sats,dats}` (completed: the fixity
environment, `the_trans1_env_push/pop/localjoin/save/restore`, the `staload` table, the `atsreloc` list and its printers, `the_EXTERN_PREFIX_*`,
`the_trans1_env_initialize`; the e1xpenv is unchanged; `pats_trans1_env.spec` generates `atsrelocitm`), `pats_trans1_error`, `_effect`, `_sort`, `_staexp`,
`_p0at`, `_dynexp`, `_decl`, `_e0xp`, `_syndef` (about 6.4k lines of ATS2 for 8.1k of ATS1), plus two modules the translation needs and that were not in the
list: `pats_global.{sats,dats}` (the flags `PACKNAME`, `ATSRELOC`, `DYNLOADFLAG`.. kept in arena cells) and `pats_filename_reloc.dats`
(`pkgsrcname_relocatize`: without it `{$PATSPRE}/DATS/x.dats`, which every `#include "share/atspre_staload.hats"` uses, is not found). Same file and external names as `src/`;
`pats_trans1.hats` is a helper included by the `.dats` files (`glist_map_fun`, `trans1_env_make/get`, `trans1_strptr2gstring`).
`utils/arenagen/port_ats1.py` accepts several specs (`a.spec:b.spec:c.spec`); the first draft of the ten files was made with
`pats_syntax.spec:pats_staexp1.spec:pats_dynexp1.spec`, the rest by hand.

### Rules

T1-1. **A closure stored in a `fxopr`** (`FXOPRpre (prec, f)` with `f` capturing `loc0`, `s1qs`, ...) is a top-level `fn f (env: ptr, x: a): fxitm a` and
      `fxopr_FXOPRpre<a> (prec, @(env, f))`. The environment is the location itself when it is the only variable (`$UN.cast{ptr}(loc0)` in the call,
      `$UN.cast{location}(env)` in `f`: nothing is allocated), else a tuple in the global arena: `trans1_env_make<@(location, int, s1qualst)> (@(loc0, knd, s1qs))`,
      read by `trans1_env_get<..> (env)`. A constant `knd` is a different function (`f_invar_ref_r`, `f_invar_ref_w`..). The `appf` (application) and the
      `locf`/`appf` of `fxopr_make` have no free variable: `fxitm_app<a> (loc, @(the_null_ptr, appf))`, `fxopr_make<a> (get_loc, make_app, opr, fxty)`, with
      `make_app (loc, x, loc_arg, xs)` a named function. Every call of a template of `pats_fixity` writes `<a>`, and the module has `staload _ = "./pats_fixity_fxty.dats"`
      (rule 16) and `#include "./mylibies.hats"`.
T1-2. **`list_map_fun (xs, f)`** is `glist_map_fun<a,b> (xs, f)` of `pats_trans1.hats` (head first, like ATS1, so the errors and the other side effects of the translation
      come out in the same order; `glist_map_loop<a,b>` returns the `List0_vt` for `s1exp_list2`). Recursion on a list that is not a `map` (`aux_itemlst`) keeps the
      ATS1 order too: the items of an application are translated from the last one to the first. A `where` that binds before the call (`flag1` of
      `d0exp_tr_lams_dyn`) is evaluated before it.
T1-3. **`case+ x.d0exp_node of`** with guards (`S0Eide id when id = AMPERSAND`) is `case+ s0exp_node_view (..) of ~S0Eide id => if id = .. then .. else if ..`; the arms keep
      their order, a catch-all arm is `| v => (X_view_free (v); default)` (rules 3, P4). A match of an enum payload (`FK_fn ()`) is unchanged.
T1-4. **`fcopt` is `Option_vt (funclo)`** (linear, `pats_basics.sats`): `e0fftaglst_tr` returns `@(fcopt, lin, prf, efc)` and the caller consumes the first component
      (`case+ ofc of ~Some_vt fc => .. | ~None_vt () => ..`); `d0exp_tr_lams_dyn` takes it as an argument. Updating the one that a loop holds in a `var`
      consumes the old value first (`fcopt_set` of `pats_trans1_effect.dats`). `Option(location)` is `gopt(location)`.
T1-5. **The proofs of ATS1 are gone**: `the_trans1_env_push ()`, `the_trans1_env_pop ()`, `_save/_restore/_localjoin ()` (also `the_fxtyenv_*`); the proofs of
      `the_filenamelst_push/pop` are still the `absview` of `pats_filename.sats`. `the_fxtyenv_pop` returns a `symmap(fxty)` to give to
      `the_fxtyenv_pervasive_joinwth` (`pats_main.dats` `the_fixity_load`).
T1-6. **A table in a never freed cell.** The `staload` table is a `linmap_avltree` (key: the stamp of the full file name, value: `@(ldflag, d1eclist)`); it is kept in a cell
      of the arena that contains the map (`$UN.ptr0_vtake{map}(cell)`): a nil map is the null pointer, so the pointer itself cannot be the address of the map.
T1-7. **`exit {void} (1)`** (`#error`, `#assert`) is `$extfcall (void, "exit", 1)`: the polymorphic `exit` leaves an `atstype_ptr` return in a `void` function (rule 15).
T1-8. **Strings.** `sprintf ("%s%s", ..)` is `string0_append` + `trans1_strptr2gstring` (copy in the arena, free the strptr); the C helpers `patsopt_extnam_ismac/issta/isext` are
      ATS functions on the characters (`ext#xxx` -> the copy of what follows `#`); `patsopt_string_suffix_is_dats` is a `static` function of a `%{^`.
T1-9. **Token payloads**: `token_string_get`, `token_char_get` of `pats_syntax_token.hats`; the integer and floating tokens have local helpers
      (`token_int_rep`, `token_float_base/rep`), `T_CASE` has `token_case_get`; `T_FUN`/`T_VAL` of `token_get_dcstkind` are matched through the view.
T1-10. **Comments glued to a call** (P9) again: `stropt_none (*void*)`, `gopt_none (*efcopt*)` are *functions* followed by a comment, write `((*void*))`.
T1-11. **`pats_global`**: one arena cell per flag; `Stropt` values are stored as `ptr`; `the_IATS_dirlst` is a `glist(string)` in a cell.
T1-12. **`pats_filename_reloc`** is the ATS1 file with `Strptr1` replaced by arena strings (`my_make_substring`: `memcpy` into `the_garena_alloc`); it implements
      `$FIL.pkgsrcname_relocatize` (so a driver must not stub it any more) and has a `dynload` function (the driver `dynload`s it).

### Validation (ATS1 reference = the objects of `src/`; `make -C test d1files|t1compare|t1test`)

* **The driver** `test/d1dump.dats` (ATS2) / `test/d1dump1.dats` (ATS1) / `test/d1dump.cats` (shared C): it does what `pats_main.dats` does for `patsopt -s/-d file`:
  `patsopt_PATSHOME_set`, `the_prepathlst_push (PATSHOME)`, `the_trans1_env_initialize ()`, `the_fixity_load (PATSHOME)` (parse `prelude/fixity.ats`, push a fxtyenv,
  `d0eclist_tr_errck`, pop, `pervasive_joinwth`), then for each file `parse_from_givename_toplevel`, `d0eclist_tr_errck`, `trans1_finalize ()` (inside a push/pop of the
  trans1 environment) and the complete dump of the `d1eclist` with the generated dumpers (`deepdump(1).hats` for the level 0 types, `deepdump(1)_t1.hats`, generated by
  `tree1_gen.py`: the same as `deepdump_l1.hats` but the `d1eclist` of a `D1Cstaload` (the cached translation of the staloaded file, shared) is dumped
  the first time only, afterwards `<staloaded>`), then `DYNLOADFLAG`, `DYNLOADNAME`, `MAINATSFLAG`, `STATIC_PREFIX`, `PACKNAME` after `trans1_finalize`. Input: lines
  `KIND<TAB>path`: `FILE` (as `pats_main`), `RAW` (`d0eclist_tr`, then the check of the errors: the tree is dumped also when there are errors) and `REL` (`FILE` with the
  option `--atsreloc`: the list of `atsrelocitm` is printed) + `sta`/`dyn`. stdout (the dump) and stderr (the errors, with `BEGIN` marks) are compared separately. An exception or an
  `exit` of the translation ends the process after a mark; `d1chunk.sh` restarts it with the next line (the state after an exception is not meaningful).
* **Whole files** (`make d1files`, `d1files.sh`): the 2744 `.sats/.dats/.hats` of the repository (links followed; 2221 under prelude, libats, src, src2, doc/EXAMPLE, contrib) in
  the 3 modes = 8232 translations, chunks of 40 files per process: stdout 6.8 GB (7049 complete trees, 1414 runs end in an exception: ATS1 sources of `src/`
  and `contrib/` (`staload "./pats_atspre.dats"`), `CODEGEN/*_atxt.dats`, `doc/BOOK`, missing files) and 17287 lines of errors: **identical**.
* **Hand-written cases** `test/t1cases/` (58 files, 3 modes): fixity declarations (`infixl/infixr/infix/prefix/postfix/nonfix`, `(opr + n)` adjustments, uses in static
  expressions, patterns, dynamic expressions, backslash), 22 files of operators that are not applied or whose fixity cannot be resolved, `#define/#undef/#if/#ifdef/#elif/#print/
  #assert/#error`, `ATS_PACKNAME/DYNLOADFLAG/DYNLOADNAME/STATIC_PREFIX/MAINATSFLAG/EXTERN_PREFIX` (right and wrong), `$extval/$extfcall/$extmcall/$extype/$extkind/$tyrep/$literal/$effmask*`,
  static and dynamic `overload`/`symintr`/`symelim`, `staload/#staload/dynload/#require/#include` (relative, `{$PATSHOME}`, a file that is staloaded twice, missing files, an
  include loop, a staload loop), `abstype/abst@ype/absview/absprop/absvt@ype/sortdef/datasort/stacst/stadef/tkindef/assume/reassume`, every data declaration, exceptions, `local`, `where`,
  templates and implementations with template arguments, all the effect tags (`<!ntm,exn,ref,wrt>`, `<cloref1>`, `<!laz>`.., one unknown), the declaration errors of `d0cstdec_tr`, functions of every
  kind, `lam/llam/fix`, `case/sif/scase/ifcase/try/for/while`: **identical** (`make t1compare`); `t1cases.md5` is the md5 of the ATS1 output (the directory removed), `make t1test` (in `make test`)
  checks the ATS2 build without ATS1.
* **Sensitivity**: 6 deliberate bugs (an argument order in `d1exp_app_proc`, a knd of `&?` in `staexp`, the two branches of `#if/#else`, `!laz` in `effect`, the order of
  `println!` in `syndef`, a dropped static argument in `p0at`) were each detected (15..121 of the 206 chunks differ).
* **AddressSanitizer** (`make d1dump_asan`, leak detection on): 1022 files of prelude, libats, src2, doc/EXAMPLE and contrib/atscntrb in the modes FILE and RAW (2044 translations): no
  error; the only leak reports (14 processes) are the linear accumulator of `glist_map_loop` on the path of an exception that ends the process.
* **Speed** (`make d1dump_o2`, 701 files without errors of prelude, libats, src2 and doc/EXAMPLE in one process, `time` mode = parse + level-1 translation, no dump, fixity load included):
  ATS2 `-O2` 1.30 s (max RSS 528 MB), ATS1 (`-O2` objects of `src/`) 1.32-1.38 s (696 MB); ATS2 without `-O` 8.2 s.

### Notes for trans2

* Needs from this level: `d0eclist_tr_errck`, `trans1_finalize` (pops the file of `parse_from_givename_toplevel` and sets `DYNLOADFLAG`.. in `pats_global`), the
  `d1ecl` trees (`D1Cstaload (idopt, filename, ldflag, d1eclist)` carries the cached list: a file that is staloaded twice gives the same list), `the_EXTERN_PREFIX_set/_set_none`,
  `the_trans1_env_push/pop` and `the_fxtyenv_*` (`pervasive_load` and `the_fixity_load` of `pats_main.dats` are not ported: `test/d1dump.dats` has `the_fixity_load`),
  `the_atsrelocitmlst_get`, `fprint_atsrelocitmlst`, `$GLOB.the_PACKNAME_get/set_name`, `the_STATIC_PREFIX_get`, `the_DYNLOADFLAG_get` (used by dynexp2_dcst, ccomp).
  The `S1Ed2ctype` and `S0Ed2ctype` are placeholders (the same pointer): `S0Ed2ctype_tr` casts the translated `d1exp`.
* `trans1err` has no consumer other than `the_trans1errlst_finalize` (it counts them and raises `PATSOPT_TRANS1_EXN`).

### Open problems (level 1 translation)

* The accumulator of `glist_map_loop` (a linear `List0_vt`) is not freed when an exception leaves the translation of an element; the exceptions end the process in
  `patsopt` (as the leaks of ATS1 do).
* `fprint_the_fxtyenv` (prints the stamps of the symbols, which depend on the order of creation) and `the_trans1_env_localjoin` of the e1xpenv alone are not compared directly: the
  fixity is checked through the trees it produces.
* The recursion of `f0undeclst_tr`, `d0cstdeclst_tr`, `m0acarglst_tr`, `aux1lst`.. is not a tail call (as in ATS1): the depth is the number of `and` clauses.
* `#error` and `#assert` call libc `exit` (as ATS1): a driver cannot recover from them; `d1chunk.sh` restarts the process.
* `process_PATSRELOCROOT` (the `PATSRELOCROOT` variable of `pats_main.dats`) is not ported: `$PATSRELOCROOT` is the default text of `pkgsrcname_get_gurl1` only.

## Level 2, slice 1: pats_staexp2*, pats_namespace (rules S2-1 .. S2-14)

Done (typecheck, link, differential test, see Validation): `pats_staexp2.{sats,dats}` (+ `pats_staexp2.spec`, `pats_staexp2.hats`), `pats_staexp2_{sort,svar,svvar,scst,dcon,error,hole,
print,pprint,szexp,skexp,ctxt,util1}.dats`, `pats_staexp2_error.{sats,spec}`, `pats_staexp2_util.sats` (all the declarations, also those of util2/util3), `pats_namespace.{sats,dats}`
and one module that ATS1 does not have, `pats_avlmap.{sats,dats}` (the persistent AVL trees of the static sets). 11.3k lines of ATS1, 11.1k of ATS2 (+ 4.5k generated).
NOT done (next slice): `pats_staexp2_util2.dats`, `_util3.dats`, `_solve.{sats,dats}`, `pats_stacst2.{sats,dats}`. Same file names and external names as `src/`
(`patsopts2cst_set_isabs`); the values that the sats declares without a C name have `ext#patsopt_<name>` (`s2rt_int`, `s2eff_nil`, ...).

### The representation (read this before the next slice)

S2-1. **Immutable trees = the arena AST of the earlier levels** (`pats_staexp2.spec`, `make gen` / the rules of `src2/Makefile`, `--global --compact`):
      `s2rt s2rtbas s2itm tyreckind s2exp_node s2lab s2eff s2rtext wths2explst sp2at_node s2kexp s2zexp s2vararg s2exparg_node` are datatypes
      (`s2exp_node_S2Eint (i)`, `case+ s2exp_node_view (e.s2exp_node ()) of ~S2Eint i => ..`, `s2exp_node_is_S2Eint`), `s2exp sp2at s2exparg t2mpmarg s2tavar s2aspdec s2qua`
      and the former one-constructor datatypes/tuples are records (`s2exp_new (srt, node)`, `e.s2exp_srt ()`). Names that ATS1 wrote as boxed tuples or
      `SLABELED/SKLABELED/SZLABELED`: `labs2exp (labs2exp_lab/_nam/_elt)`, `labs2kexp`, `labs2zexp`, `locs2exp (locs2exp_loc/_exp)`, `syms2rt (syms2rt_sym/_srt)`,
      `d2conpair (d2conpair_0/_1)`; new aliases `s2expoptopt` (`Option(s2expopt)`), `d2conpairopt` (`Option@(d2con,d2con)`), `intlst`, `stringopt`, `d2conlstopt`, `syms2rtlstlst`.
      `FUNCLOclo(knd)` is no pattern any more (rule 10): match `FUNCLOclo0 | FUNCLOcloptr | FUNCLOcloref`.
      `s2rt_view (x)` of the generated code would clash with the constant `s2rt_view` (the sort of views): new arenagen line `viewfn s2rt s2rt_viewof` renames the
      function, so a sort is matched with `s2rt_viewof (s)` (the datavtype is still `s2rt_view`).
S2-2. **The mutable parts are explicit cells: records with `mut` fields.** The ATS1 `ref (struct)` of `s2cst`, `s2var`, `s2Var`, `d2con`, `s2rtdat`, `s2rtVar` (and the
      immutable `s2hole`, `s2VarBound`, `s2ctxt`) are records of the spec, allocated in the global arena and never freed; the address is the identity (a cell never moves).
      `utils/arenagen/arenagen.py` got `record R (a: T, mut b: U)`: a `mut` field also gets `set_b (x, v)` (README of arenagen). The raw getters are `s2cst_sym (x)`..; the
      API of ATS1 (`s2cst_get_sym`, `s2cst_set_def`, ..) is a thin layer over them (also `s2cst_set_isabs` with the C name `patsopts2cst_set_isabs`). Fields: `s2cst`
      21 (mutable: def isabs isasp iscpy islst dconlst sup supcls sVarset dstag extdef), `s2var` 5 (tmplev sVarset), `s2Var` 9 (link szexp sVarlst lbs ubs; the always-`None`
      field `s2Var_svar` of ATS1, with no accessor, is dropped), `d2con` 15 (tag), `s2rtdat` 3 (sconlst), `s2rtVar` 1 (`s2rtVar_srt`, null = unassigned, was `s2rtnul`).
      `s2Var_szexp` starts as `S2ZEVar (itself)`: the cell is created, then `set_s2Var_szexp`. Equality of two cells is `compare` of stamps (as in ATS1), of two `s2rtVar` the order of
      the addresses (ATS1: of the pointers; the order of two distinct variables is not comparable between ATS1 and ATS2).
S2-3. **Sets and maps: `pats_avlmap`** = a persistent AVL tree in the global arena keyed by pointers (`avlcmp = (ptr, ptr) -> int`; nodes of 5 words; insert/remove/union
      copy a path, `avlmap_keys` lists in ascending order). `s2varset s2Varset s2cstset d2conset s2rtdatset` and the `_vt` (linear) variants are casts of an `avlmap`
      (`s2varset_vt_free` and the like consume the value and do nothing: nothing is freed, keep them for the linearity), `s2cstmap(a)` is a map to the item (templates
      `s2cstmap_nil<a>` etc., rule 15), `s2varbindmap` a linear `avlmap` held in a `&` variable. `s2varmset` (a multiset, ATS1: `funmset_listord`) is a descending list of
      (count, element) nodes of 3 words, written out in `pats_staexp2_svar.dats` (the same insert/remove/union/compare as `libats/funmset_listord`).
S2-4. **A template whose implementation is in a `.dats` cannot use a function that is local to it** (`local .. in`): at the instance the name is `PMVerr` in the C code. `s2cstmap_*` call
      `compare_s2cst_ptr` and `the_namespace_search` calls `the_namespace_get_fenvlst/_fenvlstlst`; both are declared in the sats (internal) for that reason.
      The user of `s2cstmap_*`, `the_namespace_search`, `synentlst_app` has `staload _ = "./pats_staexp2_scst.dats"` / `"./pats_namespace.dats"` / `"./pats_staexp2.dats"`.
S2-5. **Closures became (env, function)**: `the_namespace_search<a> (env: ptr, f: (ptr, filenv) -> Option_vt a)` (was `!filenv -<cloptr1> Option_vt a`, `a` must be a boxed type),
      `synentlst_app<a> (xs, env, app)` with `app: (a, !appenv) -> void`. The local `:<cloref1>` loops of the pprinter and `s2explst_alpha` are lambda-lifted/plain `fun`s.
S2-6. **`stasub` is a `List0_vt (@(s2var, s2exp))`** (`assume` in `pats_staexp2_util1.dats`, as `absvtype stasub_vtype = ptr` in the sats); the functions that push take
      `&stasub >> _` (otherwise "var preservation" complains: the length index changes). `stasub_find` and `stasub_occurcheck` walk the list with `@list_vt_cons`.
S2-7. **Global state in arena cells**: the error list (`the_staerrlst`, at most 100 recorded and the count; `staerr` is generated from `pats_staexp2_error.spec`, `staerr_view` to
      match), the namespace lists (the current file environments, the stack, and the stack of the saved pairs as two parallel lists), the name counters `the_s2var_name_counter`,
      `the_s2Var_name_counter` (`$CNTR.counter_make ()` at the dynload). The lists are immutable `glist`s and are replaced, never changed.
S2-8. **Dynload order** (adds to the earlier lists): `.. effect, syntax, staexp1(_print), avlmap, staexp2_sort, staexp2, _scst, _svar, _svvar, _dcon, _hole, _ctxt, _error, _print, _pprint,
      _szexp, _skexp, _util1, namespace`. Only sort (the base sorts: after symbol), staexp2 (`s2eff_nil/all`: after effect), svar/svvar (counters), error and namespace have initialisers.
S2-9. **Shared by the dats files**: `pats_staexp2.hats` (`l2l`, `ptr_eq`, `ptr_cmp`, `glist_is_sing/pair`). Only `pats_staexp2.dats` includes `pats_staexp2_gen_dats.hats`.
      The generated files (`pats_staexp2_gen*.hats`, `pats_staexp2_error_gen*.hats`) are not in git (`.gitignore`): `make -C src2 check` makes them.
S2-10. **The match of a linear view with a wildcard** (rule 3) was needed ~65 times: `| v => (X_view_free (v); dflt)`. Do not write `case+ x of | A _ => .. | _ => ..` on a view.
       `fn`/`:<>`: the getters declared `:<>` in the sats (`s2var_get_sym`, `d2con_get_*`, `s2exp_is_nonvar`, set `ismem`..) are implemented with `$effmask_all`.
S2-11. **`util1` has two functions of ATS1's `util2`: `s2hnf2exp` and `s2exp2hnf_cast`** (casts; the printers and `s2varbindmap_insert` need them). The next slice must not implement them again.
S2-12. **Compiler quirks met** (the ATS1-built `patsopt`): `val h = (if a then b else c) + 1` and `val h: int = <if>` followed by `h + 1` give "g1uint size_t" errors (use a helper `fn max2`);
       `val ans = if .. then Some_vt (x) else f (..)` of a linear option needs `if .. then (.. Some_vt) else (let val r = f () in r end)` with the `fold@` before; a negative literal is `~1`
       and `a = ~f (x)` does not parse; `List_vt (T)` as a result is `List0_vt (T)`; `atstype_bool` is 4 bytes (a table of `bool` is 4 bytes per entry); `exit` in a `.dats` needs `$extfcall`.
S2-13. **Declared in ATS1 and never implemented** (not implemented here either, no test can call them): `d2con_make_list_nil/_cons`, `filenv_get_name` (the dynamic level will), `fprint_s2vararg`,
       `print_s2rtdat`, `prerr_s2rtdat`, `s2eff_contain_s2eff`, `s2explst_tszeq`, `s2var_is_boxed/_unboxed`, `stasub_get_domain`, `s2exp_bool/_char`, `s2rt_is_char`. Implemented here although ATS1 has no
       body (trivial getters, untested against ATS1): `s2cst_get_arylst`, `s2cst_get_iscpy/_set_iscpy`, `s2rt_is_string`.
S2-14. **ATS1 bugs and oddities that are kept** (the test covers them): `s2zexp_subst_flag` loops forever on a fresh `S2ZEVar` (the `szexp` of V is `S2ZEVar (V)`) and `s2zexplst_subst_flag` returns
       the old elements; `s2zexp_merge` has no occurs check (merging V with a term that contains V makes a cyclic solution, a later merge loops); `s2rt_npf_lin_prf_prgm_boxed_labs2explst`
       (`val-list_cons`) aborts when `npf` exceeds the length; `s2cst_make`/`d2con_make`: `s2exp_cstapp` aborts on a constant that has no function sort; `s2rt_impred` of an unknown kind
       aborts; `s2ctxt_hrepl` of a non-hole returns the `s2e` part (`else s2e0` in `S2Eat`).

### Validation (ATS1 reference = the objects of `src/`; `make -C test s2compare|s2test|s2cover|s2dump_asan`, `python3 s2mutate.py REF.out REF.err`)

* **`test/s2_gen.py` + `s2_cases.py`** generate, from the two specs, (a) in ATS2 and in ATS1 the wrapper `K_<CON>` of every constructor and record, typed list/option helpers and a COMPLETE
  dumper `dd_<T>` of every type (every field; the cells are dumped through their getters, `chk_s2cst` etc. print all their fields: 35 types, 111 constructors) and (b) ONE neutral
  program (the common subset of ATS1/ATS2, `s2common1/2.hats`, `s2case_pre*.hats`) of 504 scenarios (126 x `S2SCALE=4`, seed `S2SEED=1`), 47 chunk files of 133k lines, compiled by the ATS2 driver `s2dump.dats`
  and the ATS1 driver `s2dump1.dats` (`s2dump1.sh`, linked with `src/*.o`). A scenario creates cells (csts of every sort kind, vars, existential vars, holes, data constructors) and random trees of depth 3
  (every constructor; sorts, lists, options, effects, tyreckinds, `s2itm`, `s2kexp`, `s2zexp`), calls the functions of the modules on them and dumps the results: families `sort` (all `s2rt_*`, unification
  with variables, datasorts), `lfc` (the kinds of records), `exp` (every smart constructor, `uns2exp_exiuni`, predicates, the three printers, pprint), `print` (every `fprint_/print_/prerr_/fpprint_`), `cell`
  (every getter/setter/order function of s2cst, d2con, s2var, s2Var, s2hole; the sets, the multiset, the bind map, the const map; big sets of 6-8 elements for the rotations), `subst` (`stasub_*`,
  `s2exp_subst(_flag)`, lists, options, `s2zexp_subst_flag`, `s2exp_alpha`, binders), `zk` (s2zexp/s2kexp of trees of the "identity domain" and their merges), `ctxt` (`hrepl`), `error` (100 recorded
  errors and the count, the printer), `ns` (random sequences of add/push/pop/localjoin/save/restore and the searches, first match included), `misc`, `rec` (a tree of every type), `target` (bound variables,
  constants with a definition, merges of lists of different lengths, linear records, linked variables in the pprinter, chains of 104 links).
  **Result: stdout 96247 lines and stderr 2589 lines (the `prerr` of the printers and the error list), byte-identical in ATS1 and ATS2** (`s2compare`; `s2dump.md5` keeps the md5 of the ATS1 output: `make test` checks
  the ATS2 build without ATS1). The first full run found one real bug of the port (`s2exp_hrepl_flag`: `else s2e` for `else s2e0`).
* **Coverage** (`make s2cover`): 111/111 constructors and 13/13 non-cell records are built by the cases (the 9 cells through their makers); of the 503 functions declared in the 4 sats, 459 are implemented
  by the ATS1 sources and testable (the others: util2/util3/trans3_env and S2-13), 456 are called (the 3 others are internal helpers called by templates). gcov by ATS line (`patsopt --gline`, `-O0 --coverage`):
  **4618 of 4677 executable lines of the 16 modules (98.7%)**; the rest is dead code (`s2rt_impred` of an unknown kind aborts, the `deadcode` arms), the three trivial getters of S2-13 and the lines
  of `pats_avlmap.dats` that only `test_avlmap` (below) reaches.
* **`test/test_avlmap.dats`** (ATS2 only): 20000 random insert/remove/union of the AVL trees against a table, persistence of an old version, height bound, ascending/descending insertions, removal of everything: 0 errors.
* **Mutation test** (`python3 s2mutate.py`, 15 deliberate bugs in 13 modules, e.g. the contravariance of function sorts, the order of a multiset, the union of the AVL trees without the right subtree, the sum of
  two effects, a merge of closures, a space in a printer, the linearization of sort names, the real arity of a constructor, the replacement in a context, the join of the namespace, the number of recorded errors,
  the substitution under a binder, the contravariance of function kinds, the upper bounds as lower bounds): **15/15 detected** (the ones that were first missed made me add big sets, first-match searches and
  sup-class relations to the cases).
* **AddressSanitizer** (`make s2dump_asan`, leak detection on): the whole run: no error, no leak (the arena is reachable from its global handle; the linear lists/options/`stasub` of the cases are all consumed).
* **Stubs.** `pats_staexp2_util1.dats` (`s2exp_is_lin2`, `s2eff_contain_set/_exp`), `_szexp.dats`, `_skexp.dats` call `s2exp_hnfize`, `s2exp2hnf`, `s2explst_syneq`, `s2exp_syneq` of util2: both drivers define the same stubs
  (`s2stub_hand.hats`, `s2stub1_hand.hats`: identity and a structural equality of ints/constants/variables) and the generator only gives them trees on which the real hnfize is the identity (no `S2Etop`, `S2Einvar`,
  `S2Elam` as the head of an application, no linked `S2EVar`; `s2exp_hnfize_flag_svar` is not used). Delete the stubs and add util2 to `S2MODS`/`s2dump1.sh` when util2 is ported, then relax `idom`.

### Notes for util2, util3, solve, stacst2, dynexp2, trans2

* util2 needs (this slice): `s2exp_hnfize*` (S2Evar -> `s2exp_hnfize_flag_svar` of trans3_env, link following of `S2EVar` via `s2Var_get_link`), `s2exp_linkrem`, `topize`, `syneq*`, `absuni/opnexi`; the helpers `s2exp_ptr_type`,
  `s2exp_unit_prop` come from stacst2. Do not implement `s2hnf2exp`/`s2exp2hnf_cast` (S2-11). `s2Var_occurcheck_s2exp` is declared with a flat result `@(int, s2cstlst, s2varlst, s2Varlst)`.
* Matching idioms: `s2exp_node_view (e.s2exp_node ())`, `s2rt_viewof`, `glist_view`/`gopt_view`; use `*_is_*` (no malloc) and `glist_head/_tail/_is_cons` for tests; records of lists `labs2exp_lab (x)`.
  The persistent sets are O(log n) per operation but allocate in the never freed arena: `s2exp_freevars` (util3) builds `s2varset_vt` by `s2varset_vt_add`: expect memory ~ n log n per call.
* The test harness is reusable: add the new functions to the `fam_*` of `s2_cases.py` (or a new family), `S2MODS` (test/Makefile) and `s2dump1.sh`; `make s2compare` must stay identical.
* dynexp2 will define `filenv` (the sats has `abstype filenv_type = ptr` and `filenv_get_name`, stubbed in the drivers) and the `d2*` types in the same style (spec + `mut` fields for `d2var`, `d2cst`, `d2mac`..).

### Open problems (level 2, slice 1)

* The cells are never freed (as all arena data); the sets copy paths (S2-3). If trans3 turns out to be slow, `s2varset_vt` could become a mutable tree with real frees.
* `compare_s2rtVar_s2rtVar` of two different variables follows the addresses: not reproducible. `eq` is exact.
* The generated cases depend on Python's `random` (`S2SEED`); `s2dump.md5` is the md5 of the ATS1 output for the default seed and scale: regenerate it (`s2dump1.sh`, `s2cmp.sh`) after a change of `s2_cases.py`.
* `s2cst_get_arylst/iscpy`, `s2rt_is_string` are not tested against ATS1 (S2-13). The behaviour of the stubbed functions is only tested modulo the stub.
* `make -C test s2dump1` compiles 47 chunks with ATS1 (`JOBS=8` in parallel, about 100 s sequentially); `make s2dump` about 12 s with `-j16`. `make all` of `test/` must not run with `-j` (the older tests write `pats_X_dats.c` into the same directory).

## Level 2, slice 2: pats_staexp2_util2, _util3, _solve, pats_stacst2 (rules S2B-1 .. S2B-12)

Done (typecheck, link, differential test, see Validation): `pats_staexp2_util2.dats` (hnfize, syneq, prenex forms), `pats_staexp2_util3.dats` (free variables, occurrence check,
`s2exp_isbot`), `pats_staexp2_solve.{sats,dats}` (equality, subtyping, hypothetical equality, the primitive checks), `pats_stacst2.{sats,dats}` (the pervasive static constants:
118 `the_xxx: s2cstref`, the `s2exp_xxx` constructors and `un_s2exp_xxx` destructors) and two PARTIAL interfaces of modules that are not ported: `pats_trans2_env.sats`
(`the_s2expenv_pervasive_find`) and `pats_trans3_env.sats` (what solve calls). Same file and function names as `src/`. 8.4k lines of ATS1, 7.6k of ATS2.
The slice-1 stubs are deleted (`s2stub*_hand.hats`; the hand-written language layers `s2compat*_hand*.hats` are renamed `s2glue{1,2}_{pre,mid,post}.hats`: they are not stubs,
they hold `mkloc`, the dumpers of the cells, the wrappers of the templates; the ATS1 and ATS2 versions of one file are the same program).

S2B-1. **The exception `SYNEQexn` became a `bool`.** `s2hnf_syneq_exn`/`s2exp_syneq_exn`/`s2explst_syneq_exn`/`s2eff_syneq_exn` etc. raise on the first difference; an exception would leak the
       views of the pending matches. They are `*_syneq_aux` returning `bool`, with `andalso`/`if` in the order of the ATS1 tests (the order of `hnfize` and of the side effects is kept).
       `s2eff_syneq` keeps the ATS1 oddity `s2eff_syneq_exn(s2fe21, s2fe22)` for `S2EFFadd` (the second test compares a component of the second effect with the other one) and
       `knd1 != knd2` on `tyreckind` is `eq_tyreckind_tyreckind` (`overload != with eq_tyreckind_tyreckind` of `pats_staexp2.sats`, an ATS1 bug kept): the syntactic equality
       of two records of the same kind is false (unless they are the same node), see `fam_target2`.
S2B-2. **Matches of a pair with guards** (`case+ (s2en10, s2en20) of (S2Einvar _, _) => .. | (_, S2Einvar _) => .. | (S2EVar _, _) when .. =>`, in `solve`, `hypequal`, `s2eff_subeq`) are
       an `if` chain on `s2exp_node_is_XXX` in the order of the arms (no allocation), the payload read by a one-arm `un_XXX` view match, and then ONE view match on the left node for the
       arms of the form `(CON .., _)`, each of which always returns. The default arm (`s2hnf_is_abscon` both, `s2hnf_syneq2`, `trans3_env_add_eqeq`) is a local `fn auxdflt`.
S2B-3. **Environments of bound variables** (`!s2varlst_vt`, ATS1 `$UN.linlst2lst`) are scanned in place with `@list_vt_cons` and `fold@` (`aux0`.. `aux2_0` of `s2var_syneq_env`):
       converting to a `glist` would allocate in the never freed arena for each comparison. `auxenv` copies the linear list (`list_vt_copy<s2var>`) and pushes the binders
       (`reverse_append` of ATS1, the last binder first).
S2B-4. **`s2cstref` is a two-word cell of the global arena** (the symbol, the constant or null); `s2cstref_get_cst` looks the name up with `the_s2expenv_pervasive_find` the first time
       and caches the constant (so the pervasive environment must be complete before the first use: the test does it in the first scenario). The vals `the_xxx` have C names
       `ext#patsopt_the_xxx`; they are made when the module is dynloaded (before `pats_staexp2_sort` is fine: only `symbol_make_string`).
       `the_add_eff_eff`, `the_sub_eff_eff` are declared and never implemented (ATS1 too), as `s2cstref_get_exp`/`s2cstref_unget_exp`, `s2explst_opnexi`, `s2explstlst_hnfize` (S2-13).
S2B-5. **`val-list_cons (x, _) = xs`** (the un_ functions, `s2cst_get_argsrtss`) is `glist_head` guarded by `glist_is_cons`, else `$ERR.abort_interr<T> ()` (ATS1 raises `MatchError`).
       The cases never call them with a short list (the arguments of the constants of a function sort have the arity, and `argsrtss` have 4 entries).
S2B-6. **Partial interfaces.** `pats_trans2_env.sats` declares only `the_s2expenv_pervasive_find`; `pats_trans3_env.sats` only `trans3_env_push/pop_and_add_main/add_proplst_vt/add_eqeq/
       hypadd_prop/hypadd_bind/hypadd_eqeq`, `s2hnf_absuni_and_add/opnexi_and_add`, `s2exp_exi/uni_instantiate_all` (flat result `@(s2exp, s2explst_vt)`) and `s2var_occurcheck_s2exp`.
       The proof `trans3_env_push_v` is dropped (T1-5): `trans3_env_push (): void`, `trans3_env_pop_and_add_main (loc): void`. The trans2/trans3 slices must EXTEND these files
       (their other declarations depend on dynexp2/dynexp3) and implement the functions in `pats_trans2_env.dats`, `pats_trans3_env.dats`; `s2exp_hnfize_flag_svar` (declared in
       `pats_staexp2_util.sats`, ATS1: `the_s2varbindmap_search`) is implemented there too.
S2B-7. **Templates.** `auxlst` of util3 is `fun{a:type}` (rule 15) with `auxlst<s2exp> (.., aux2_s2exp)` (function pointers of type `(s2Var, a, &int, &s2cstlst, &s2varlst, &s2Varlst) -> void`);
       the `&s2varlst_vt` results of `prenexize` need `>> _` (var preservation, S2-6). `glist_pair` is in `pats_staexp2.hats`.
S2B-8. **The wildcard arm of a view match** frees the view (`| v => (s2exp_node_view_free (v); ..)`, S2-10), also for `s2eff_view`, `s2lab_view`, `wths2explst_view`, `s2zexp_view`, `s2itm_view`.
S2B-9. **Dead code kept** (ATS1 has it too, nobody calls it): `labs2explst_hnfize_flag`, `s2hnflst_syneq_exn`, `s2explst_prenexize`, `labs2explst_prenexize`.

### Validation (ATS1 reference = the objects of `src/`; `make -C test s2compare|s2test|s2cover`, `sh s2gcov.sh`, `python3 s2mutate.py REF.out REF.err`)

* The generator (`test/s2_gen.py` + `s2_cases.py` + `s2_cases2.py`) now makes 605 scenarios in 78 chunks (S2SEED=1, S2SCALE=4). New families: `setup` (the 118 pervasive constants are
  created and put in the table of the test double of trans2_env, `stacst2_initialize`), `hnf` (every constructor as the root with bound variables, linked existential variables and constants
  with definitions, acyclic by construction (`Sc.restrict`); beta redexes; lists/options; `s2eff_hnfize` of every effect form), `topize`, `syneq` (every constructor, structural copies (`twin`) and
  copies with one node replaced, alpha-equivalent binders `lam/exi/uni`, the environment functions), `prenex` (`s2exp_absuni/opnexi`, `s2exp_freevars`, `s2Var_occurcheck_s2exp`, `s2exp_isbot`),
  `solve` (the primitive checks, the effects, equality and subtyping of twins/mutated twins/random pairs/every constructor, applications of constants with variances and superclasses,
  quantifiers, existential variables, the list/record/with-type functions), `hypeq`, `target2` (shapes that random trees reach rarely), `stacst`, `stacst2`.
  The trans3_env/trans2_env functions are test doubles written twice (`s2env2.hats`, `s2env1.hats`): recorders that print "T3 ..." lines (push, pop, add_eqeq, hypadd_*, add_svarlst, ..),
  tables for the pervasive constants and for the bindings of static variables, the instantiation of quantifiers by fresh existential variables, `s2var_occurcheck_s2exp` through `s2exp_freevars`.
* Result: see the numbers at the end of this section (stdout/stderr identical, constructors, functions, gcov, mutations, ASan). `s2dump.md5` was regenerated from the ATS1 output.
* ATS1 side: `s2dump1.sh` links the objects `src/pats_{staexp2_util2,util3,stacst2,staexp2_solve}_dats.o` and the `_sats.o` of trans2_env/trans3_env/dynexp2/dynexp3/patcst2/jsonize/dyncst2
  (the static loading functions of the sats that they staload) and needs `staload _ = "prelude/DATS/list.dats"`/`list_vt.dats`/`reference.dats` for the templates of the test doubles.
* Build times: `patsopt` is superlinear in the length of one function: a scenario of more than ~4000 lines (`solve`) costs minutes; the generator keeps them at 1500-4000 lines.
  The whole `make s2dump` takes about 4 minutes with -j10, `s2dump1.sh` about the same.

### Result (slice 2)

* **603 scenarios** (76 chunks, 232k lines of cases; `S2SEED=1 S2SCALE=4`): stdout 174650 lines and stderr 18650 lines, **byte-identical** in the ATS1 and ATS2 builds (exit codes 0); `s2dump.md5`
  is REGENERATED from the ATS1 output (`s2dump1`); `make s2test` checks the ATS2 build against it without ATS1. The output contains 12965+ `T3 ..` recorder lines, 4.5k+ recorded static errors
  of every `STAERR_*` kind (equal/tyleq of terms, effects, labels, stamps, funclo, linearity, pfarity, refval, boxity, tyreckind, zexp merges, srtck of variables, list lengths, with-type shapes).
* **Coverage**: 111/111 constructors and 13/13 records built; 596 of the 599 functions (declared in the six `.sats`, implemented by ATS1 and callable) are called by the cases
  (the 3 others are the internal helpers `compare_s2cst_ptr`, `the_namespace_get_fenvlst/_fenvlstlst`); `sh s2gcov.sh` (gcov by ATS line, `-O0 --coverage`) of the new modules:
  util2 1079/1145 (94.2%), util3 455/458 (99.3%), stacst2 750/765 (98.0%), solve 965/986 (97.9%): **3249 of 3354 executable lines (96.9%)**. The rest: the abort paths (`s2exp_linkrem`
  panic after 1000 links, `s2cstref_get_cst` of an absent constant), the dead code of S2B-9 (labs2explst_hnfize_flag, s2hnflst_syneq, s2explst/labs2explst_prenexize, ~60 lines),
  and single-token lines (`then ()`, `else false`) that gcov does not attribute.
* **Mutations**: 24 new deliberate bugs in the four modules (`s2mutate.py`; hnfize of an application, syneq of integers/tops/the S2EFFadd oddity, bound variables of the environments,
  prenex kinds, topize, binders, occurrence check, isbot, error links of free variables, boolean constants, effect constants, sum of propositions, constant heads, top kinds of equality and
  subtyping, variance of function arguments, order of variable hypotheses, labels, abstract constructors, subset of effects, constants): with the 15 of slice 1, **39/39 detected**
  (one, the `flag <= flag0` of `s2exp_invar_flag`, was first missed: `fam_topize` now has an invar around unlinked/linked existential variables).
* **AddressSanitizer** (`make s2dump_asan`, leak detection on) over the whole run: no error, no leak report, same stdout/stderr.

### Notes for dynexp2, dmacro2, trans2, trans3

* `pats_stacst2.sats` is complete (the `the_xxx` vals have C names `patsopt_the_xxx`). trans2 must implement `the_s2expenv_pervasive_find` (EXTEND `pats_trans2_env.sats`, do not replace it) and call
  `stacst2_initialize ()` after the prelude's static constants exist: `s2cstref_get_cst` caches the first constant it finds, so the pervasive environment must hold every constant
  that is used (`sizeof_t0ype_int`, `at_vt0ype_addr_view`, the `invar_*`, `unit_p`, `ptr_type`, ...) before the first `s2exp_hnfize` of a `S2Etop`.
* trans3 must implement (EXTEND `pats_trans3_env.sats`): `trans3_env_push/pop_and_add_main/add_proplst_vt/add_eqeq/hypadd_prop/hypadd_bind/hypadd_eqeq`, `s2hnf_absuni_and_add`,
  `s2hnf_opnexi_and_add`, `s2exp_exi/uni_instantiate_all` (flat result tuple), `s2var_occurcheck_s2exp`, and `s2exp_hnfize_flag_svar` (consults `the_s2varbindmap`). The recorders of
  `test/s2env2.hats` are a specification of the order of calls that solve makes; `s2exp_hnfize_flag_svar` must call `s2exp_hnfize` on the bound term and add 1 to `flag`.
* Using the API: `s2exp_syneq*` and `hnfize` allocate no linear data that the caller must free (the `_env` functions borrow `!s2varlst_vt`); the `_solve_err` functions take `err: &int`
  and record errors with `the_staerrlst_add` (printed/emptied by `prerr_the_staerrlst`, `the_staerrlst_get` also empties the list). `s2Var` links, `s2cst` definitions, `szexp` of variables
  are mutated by solve: a scenario that reuses a variable sees the earlier solution.
* The match idioms of S2B-2 are the template for the big matches of dynexp2/trans3 (tag tests with `_is_`, one-arm `un_` views, one view match for the main dispatch).

### Open problems (level 2, slice 2)

* `patsopt` and `atsopt` are superlinear in the size of a single function: the generated scenarios are limited to ~4000 lines; the full run needs about 4 minutes of `make s2dump -j10`
  and 25+ minutes (mostly the three largest chunks) for `s2dump1.sh`.
* `s2hnf_tyleq_solve_lVar_err`/`rVar_err` have no occurs check: a variable that is solved against a term that contains it makes a cyclic `s2zexp` and the next merge recurses forever (ATS1
  and ATS2 alike, S2-14); the cases avoid it (the occurrence tests use `equal`). `val-list_cons` failures (`argsrtss` shorter than the arguments) abort with `abort_interr` instead of `MatchError`.
* The test doubles of trans2_env/trans3_env (`s2env1.hats`/`s2env2.hats`) are written twice by hand; `s2var_occurcheck_s2exp` of the double is via `s2exp_freevars` (which also sets the link of
  an unsolved existential variable to an error expression, S2B notes), not the traversal of trans3_env.
* `s2cstref_get_exp`, `s2cstref_unget_exp`, `the_add_eff_eff`, `the_sub_eff_eff`, `s2explst_opnexi`, `s2explstlst_hnfize` are declared and not implemented (ATS1 too).

## Level 2 dynamic (dynexp2): pats_dynexp2, _dcst, _dmac, _dvar, _mapgen, _print, _util (rules D2-1 .. D2-12)

Done (typecheck, link, differential test, see Validation): `pats_dynexp2.{sats,dats}` (+ `pats_dynexp2.spec`, generated `pats_dynexp2_gen*.hats`, not in git),
`pats_dynexp2_{dcst,dmac,dvar,mapgen,print,util}.dats`, and the two generic traversals that `_mapgen` includes: `pats_staexp2_appenv.hats` and `pats_dynexp2_appenv.hats`
(ATS1 has them as `.hats` too; `pats_constraint3_mapgen` will include the first one). 7.0k lines of ATS1 (+1.6k of `.hats`), 4.5k lines of ATS2 plus the 1.6k `.hats`, the sats 1.6k (+5.4k generated).
NOT done (as asked): `pats_dynexp2_dyncst` / `dyncst2` (needs `pats_trans2_env`). Same file names and C names as `src/` (`patsopt_p2at_set_type`, `patsopt_i2nvresstate_nil`).

### Rules

D2-1. **Immutable trees = arenagen records and datatypes** (`pats_dynexp2.spec`, `--global --compact`, rules of "Arena AST" and S2-1): `d2itm d2pitm d2vfin m2acarg p2at_node labp2at d2ecl_node d2exp_node
      d2exparg d2lab_node d2lval` are datatypes (152 constructors: `d2exp_node_D2Ecst (c)`, `case+ d2exp_node_view (e.d2exp_node ()) of ~D2Ecst c => ..`, `d2exp_node_is_D2Ecst`), and
      `p2at d2ecl d2exp d2lab i2nvarg i2nvresstate loopi2nv i2fcl gm2at c2lau sc2lau f2undec v2aldec v2ardec prv2ardec i2mpdec d2sym labd2exp` are records (`d2exp_new (loc, node)`, `e.d2exp_loc ()`);
      the record/node split of ATS1 (`d2exp_make_node (loc, node)`) is kept. `labd2exp` is the former `dl0abeled (d2exp)` (fields `labd2exp_lab`, `labd2exp_elt`, like `labd1exp`); `d2pitm` is a one-constructor
      datatype (`~D2PITM (pval, d2i) = d2pitm_view (x)`). `pckind` is an enumeration of the sats (`PCKcon`, no payload, no spec): it is stored as a word like `funkind`.
D2-2. **The cells are records with `mut` fields** (S2-2): `d2cst` (13 fields; mutable: hisexp funlab def), `d2var` (15; mutable: level linval isfix isprf decarg addr view finknd type hisexp mastype utimes),
      `d2mac` (6; mutable: def). The raw getters are `d2var_level (x)`, the setters `set_d2var_level (x, v)`; the API of ATS1 (`d2var_get_level`, `d2var_set_level`, `d2var_inc_linval`, ..) is a thin layer over them.
      The recursion `d2var_view : d2varopt2` (a `d2varopt` hidden by a castfn in ATS1 to break the type recursion) is a plain `d2varopt` here (all the types of a spec are one group). The identity is the address.
      `d2cst_set_decarg` is declared in ATS1 and never implemented (the field is immutable here); `d2cst_is_fun` is in `pats_hidynexp_util` (not ported); `d2symset_vt_*` are declared and implemented nowhere.
D2-3. **`ref (d2varlst)` of `D2Elam_met` is the record `d2varlstref`** (`record d2varlstref (mut d2varlstref_val: d2varlst)`): `d2varlstref_new (xs)`, `r.d2varlstref_val ()`, `set_d2varlstref_val (r, xs)`
      (ATS1: `ref (xs)`, `!r`, `!r := xs`). `d2exp_lam_met_new (loc, met, body)` makes a fresh one. A `ref` can only be made from memory that is never freed (CLAUDE.md), so every user of the metric
      list (trans3) goes through this record.
D2-4. **`p2at_type` is a `mut` field** of the record `p2at` (ATS1: the C function `patsopt_p2at_set_type` writes `atslab_p2at_type`): `p2at_set_type (p, opt)` keeps its C name (`ext#patsopt_p2at_set_type`) and is
      `set_p2at_type` in the `.dats`. `p2at_svs`/`p2at_dvs` are `lstord (s2var)` / `lstord (d2var)` of `pats_utils` (a `glist` underneath), named `s2varord` / `d2varord` in the spec; the comparison functions
      are `fun cmp_s2vsym (x, y): int` (a function pointer, not a closure) and the folds of ATS1 (`list_fold_left_fun` with `lam`) are plain recursive functions with the same order.
D2-5. **Sets and maps are `pats_avlmap`** (S2-3): `d2cstset d2varset` (+ `_vt`) are casts of an `avlmap` keyed by the pointer with the stamp order (`compare_d2cst_ptr`, `compare_d2var_ptr`), `d2cstmap(a) d2varmap(a)
      d2varmap_vt(a)` are maps to the item (the item is stored as a `ptr`, the functions are templates `fun{a:type}`, rule 15), `d2varmaplst_vt(a)` maps a key to an immutable `glist(ptr)` (a stack): `_insert` pushes
      and says whether the key was there, `_search` returns the top, `_remove` pops and drops the key when the stack becomes empty. `_vt_free` and `d2varmap_vt_free` consume the value and free nothing.
      `d2varmap_insert` replaces an existing key and returns `true`, as `funmap_insert`; `d2varmap_listize` and `d2varset_listize` are ascending by stamp. A user of the templates has
      `staload _ = "./pats_dynexp2_dvar.dats"` / `"./pats_dynexp2_dcst.dats"` (S2-4: the three internal functions `compare_d2cst_ptr`, `compare_d2var_ptr`, `d2varmap_zip_ptr` are declared in the sats for that reason).
D2-6. **`mapgen` and the two `appenv.hats`**: the traversal is a set of templates `fun{} X_app (x: T, env: !appenv): void` (ATS1: `fun{} X_app : synent_app (T)`), the same file can be included by several modules with
      different `s2cst_app`/`d2var_app`; the recursion through `synentlst_app<T> (xs, env, X_app<>)` passes the instance `X_app<>` as the function pointer (non-template functions `s2cst_app` etc. are passed as they are).
      The environment is a `datavtype myenv` cast to `appenv` (`castvwtp0`) and borrowed with `castvwtp1`, unfolded with `val+ @MYENV (s2cs, _, ..) = env2` / `fold@` / `$UN.castvwtp0{void} (env2)`.
      The ATS1 `| _ => ()` arm of `d2ecl_app` (`D2Csaspdec`, `D2Creassume`, `D2Cpragma`, `D2Ccodegen`) lists the constructors (L1-7). `d2eclist_mapgen_all` returns a flat `@(s2cstset_vt, s2varset_vt, s2Varset_vt, d2conset_vt, d2cstset_vt, d2varset_vt)`.
D2-7. **Printers** (`pats_dynexp2_print.dats`): `fprint! (out, ..)` is not used (it needs a `fprint_val` for each type): every argument is an explicit call; the tokens of `D2Ei0nt/c0har/f0loat/s0tring` are read with
      `token_int_rep`, `token_char_get`, `token_float_rep`, `token_string_get` of `pats_syntax_token.hats` (included); the `| _ => prstr "D2C...(...)"` of `fprint_d2ecl` lists `D2Csymintr D2Csymelim D2Csaspdec D2Creassume D2Cexndecs`.
      The ATS1 oddities are kept: `D2Elst` does not print its `lin`, `D2Ederef`/`D2Earrsub` hide the symbol, `P2Trec` prints `P2Ttup(` and `D2LVALvar_mut` prints `D2LVALvar_mul(`.
D2-8. **`pats_dynexp2_util.dats`**: every `d2exp_node` match with a wildcard is `| v => (d2exp_node_view_free (v); dflt)` (rule 3); `d2con_select_arity` builds the filtered `glist` recursively in the same order
      (`list_filter_vclo`); `aritest` is a pair of mutually recursive `fun` (`fn*` is gone); `d2exp_get_seloverld_root` accumulates a `glist` and `glist_reverse`s it (`list_vt_reverse`); `val-D2Eselab (..) = ..`
      is `assertloc (false)` on the other arm (the MatchError).
D2-9. **Strings**: `d2var_ptr_viewat_make` makes `nam + "$view"` by `string0_append`, `symbol_make_string ($UN.strptr2string ..)` and `strptr_free` (P15); the other strings are shared.
D2-10. **Declared pure, implemented with side effects**: the getters declared `:<>` in the sats (`d2var_get_*`, the set operations, `d2varmap_*`) are implemented with `$effmask_all`; the templates `d2cstmap_search`,
       `d2varmap_search`.. are `$effmask_all let ... in` as `s2cstmap_find`.
D2-11. **The Makefile pitfalls found by the tests**: the chunks of the test instantiate the templates of `pats_dynexp2_{dcst,dvar}.dats`, `pats_avlmap.dats`, `pats_staexp2*.dats`, `pats_utils.dats`: an object that is
       not rebuilt when one of them changes hides a bug (`D2TMPL` in `test/Makefile`); `pats_dynexp2_mapgen_dats.o` includes the two `appenv.hats`. A hand-made mutation of a `.hats` was "undetected" before these rules.
D2-12. **`filenv`** stays `abstype filenv_type = ptr` of `pats_staexp2.sats` (the field of `D2Cstaload` / `D2Cstaloadloc`); `pats_trans2_env` will give it `filenv_get_name` and its constructor, the tests cast an `int`.
       `hisexp` and `funlab` are placeholders (`dynexp2_hisexp_type = ptr`, `dynexp2_funlab_type = ptr`) that `pats_hidynexp`/`pats_ccomp` must replace by their real types (they are stored as words).

### Validation (ATS1 reference = the objects of `src/`; `make -C test d2compare|d2test|d2cover|d2dump_asan`, `python3 d2mutate.py REF.out REF.err`)

* **`test/d2_gen.py` + `d2_cases.py`** generate, from `pats_staexp2.spec` and `pats_dynexp2.spec`, in ATS2 and in ATS1 (a) the wrapper `K_<CON>` of every constructor and record, typed list/option helpers and a COMPLETE dumper `dd_<T>` of
  every type (every field; the cells through `chk_d2cst`/`chk_d2var`/`chk_d2mac`, which print all the fields and all the predicates) and (b) ONE neutral program (the common subset: `d2common1/2.hats`, `d2case_pre*.hats`,
  the hand parts `d2compat*_hand*.hats` for the enumerations, the tokens, `lstord` and the template wrappers `t_dcmap_*`, `t_dvmap*_*`, `t_mapgen`) of 95 scenarios (`D2SCALE=5`, seed `D2SEED=1`), 29 chunks of 50.6k lines,
  compiled by the ATS2 driver `d2dump.dats` and the ATS1 driver `d2dump1.dats` (`d2dump1.sh`, linked with `src/*.o`). Families: `cst` (d2cst makers, setters, predicates, order, sets of 6-10 elements inserted up,
  down and shuffled, maps, `d2cst_match_def` against 11 `d1exp` shapes), `var` (setters, finalization kinds, view variables, the order, sets, persistent/linear maps and stacks of 6-11 variables, printers), `mac`, `itm`
  (items, overloads, `d2sym`), `pat` (the 19 patterns by the smart constructors, `lstord` unions with duplicate names, `p2at_set_type`), `exp` (the 85 expressions by the smart constructors, `app_sta/dyn/sta_dyn` merging,
  `ifcasehd` else-kind, `seq2`, `lvalize` of nonlinear/linear/mutable variables, `get_seloverld(_root)`, `is_lam`, `is_varlamcst`), `inv` (invariants, `i2nvarg_get_type` of a mutable variable, loops, clauses), `decl` (the
  29 declarations, `d2con_select_arity`, `t_mapgen`), `rec` (a tree of every constructor and record), `mapgen` (every expression, pattern, item, static expression and declaration under `d2eclist_mapgen_all`).
  **Result: stdout 38103 lines and stderr 3994 lines (the `prerr` of the printers), byte-identical in ATS1 and ATS2** (seeds 1, 2, 3 all identical; `d2dump.md5` keeps the md5 of the ATS1 output of seed 1: `make test` checks the ATS2
  build without ATS1). The first run found no bug of the port; the stale-object mistake of D2-11 produced one false alarm (a mutated `appenv.hats` object kept).
* **Coverage** (`make d2cover`): 152/152 constructors and 19/19 non-cell records are built by the cases; of the 351 functions declared in `pats_dynexp2.sats`, 343 are implemented by the ATS1 sources and testable
  (the others: D2-2 and 3 internal helpers), 343 are called. gcov by ATS line (`patsopt --gline`, `-O0 --coverage`, template instances merged): **2894 of 2903 executable lines of the 7 modules and the 2 `appenv.hats`
  (99.7%)**; the rest is the MatchError arms of `d2exp_get_seloverld_root`, an unreachable arm of `d2varmap_zip_ptr` and 3 punctuation lines.
* **Mutation test** (`python3 d2mutate.py`, 34 deliberate bugs in 8 files, e.g. `p2at_refas` without the insertion, the fake `npf` of `d2exp_app_sta_dyn`, the else-kind of `ifcasehd`, the at-type of a mutable argument,
  a stack of `d2varmaplst_vt` that keeps an empty key, `d2varmap_insert` that does not report the old key, the order of dcsts, the arity test of `d2cst_match_def`, the location of the root of a selection, a space in
  3 printers, the `D2Cextvar` arm and the subscripts of `D2Earrsub` in the traversal, the arguments of `S2Eapp`): **34/34 detected** (3 were first missed because of D2-11).
* **AddressSanitizer** (`make d2dump_asan`, leak detection on): the whole run, no error, no leak report; stdout and stderr identical.
* Stubs: the ATS2 and ATS1 drivers define the same stubs of `pats_staexp2_util2.dats` (`d2stub_hand.hats`, `d2stub1_hand.hats`, copies of the `s2stub*_hand.hats`; drop them with util2). The dynexp2 modules do not call
  these functions.

### Notes for hidynexp, trans2, dmacro2, codegen2, patcst2

* `d2exp_node_view` & co. are a malloc/free per match: use `d2exp_node_is_D2Exxx (e.d2exp_node ())` for a test and `d2exp_node_tag`; `case+ d2exp_node_view (..) of` needs `| v => (d2exp_node_view_free (v); ..)` for a wildcard.
* A user of `d2varmap(a)`, `d2cstmap(a)` writes `d2varmap_nil<a> ()`, `d2varmap_insert<a> (m, k, x)`, `staload _ = "./pats_dynexp2_dvar.dats"` and `#include "./mylibies.hats"`; the items must be boxed (`a:type`). `d2varmap_vt` / `d2varmaplst_vt`
  are linear values in a `var`, passed as `&m` / `!m`; they are persistent underneath (the old value of a map copied before a `d2varmap_vt_insert` is still valid, ATS1 would have freed it).
* `d2var`/`d2cst`/`d2mac`: build with `d2var_make (loc, id)`, never with `d2var_new`; mutable state through the ATS1 API (`d2var_set_type`, `d2cst_set_def` ..). `d2var_set_view (d2v, gopt_some (d2vw))` is how a mutable
  variable is made (`d2var_ptr_viewat_make`), and `i2nvarg_get_type` then needs `d2var_get_addr` to be `Some`.
* The metric of a `D2Elam_met` is a `d2varlstref`, `D2Cimpdec` carries an `i2mpdec` record, `D2Cfundecs`/`D2Cvaldecs`/`D2Cvardecs` lists of records: all immutable once built, except `p2at_type` (`set_p2at_type`) and the cells.
* `pats_dynexp2_dcst.dats` takes the packname with `$GLOB.the_PACKNAME_get ()` at `d2cst_make`; dynload order: `.. staexp2*, namespace, dynexp1(_print), dynexp2, dcst, dmac, dvar, mapgen, print, util` (`i2nvresstate_nil` is built at dynload).
* `hisexp`, `funlab`, `d3eclist`, `tmpcstimpmap`, `tmpvardecmap` are `abstype .. = ptr` placeholders: the hidynexp/trans3 ports `$UN.cast` to their own types; `hisexpopt`/`funlabopt` are `gopt`.

### Open problems (dynexp2)

* `d2cst_set_decarg` and `d2symset_vt_*` are declared and not implemented (as in ATS1); `d2cst_is_fun` waits for `pats_hidynexp_util`.
* The arguments of `d2exp_app_sta`/`app_dyn` are appended with `glist_append` (O(n) per application, as `list_extend` of ATS1) and the sets copy a path per insertion (S2-3): `d2eclist_mapgen_all` on a big file allocates ~ n log n.
* The cases of the test depend on Python's `random` (`D2SEED`, `D2SCALE`); `d2dump.md5` must be regenerated (`d2dump1.sh`, `d2cmp.sh`) after a change of `d2_cases.py`. `make -C test d2dump1` builds 29 chunks with ATS1 (`JOBS=16`: 10 s).
* `make -C test d2compare` needs the ATS1 environment of `d2dump1.sh` and the `src/*.o` objects including `pats_jsonize_sats.o` (the ATS1 `pats_dynexp2_mapgen_dats.o` calls its `staload` function).

### Note 2026-10-15: the d2 suite uses the real util2/util3/solve/stacst2

* `d2stub_hand.hats` and `d2stub1_hand.hats` are deleted. `D2MODS` (via `S2MODS`) links the real `pats_staexp2_util2/util3`, `pats_stacst2`, `pats_staexp2_solve`; the ATS1 side (`d2dump1.sh`) links the
  ATS1-built objects of the same modules (+ the `_sats.o` of trans2_env/trans3_env/dynexp3/patcst2/jsonize/dyncst2/symmap/symenv/trans1_env). The trans2_env/trans3_env test doubles are the
  ones of the static suite (`s2env2.hats` in `d2dump.dats`, `s2env1.hats` in `d2dump1.dats`; `t_penv_*`/`t_bind_*` are declared in `d2compat_hand3.hats`/`d2compat1_hand3.hats`).
* The dynexp2 modules themselves never call hnfize/syneq/solve; the new family `hnf` (`fam_hnf` in `d2_cases.py`, 2 scenarios at `D2SCALE=5`) puts static types with beta redexes, bound/linked variables,
  constants with definitions, alpha-equivalent twins into `d2var`, `d2cst` and `p2at` and dumps `s2expopt_hnfize`, `s2exp_hnfize`, `s2exp_mhnfize`, `s2exp_syneq`, `s2explst_syneq`, `s2exp_equal_solve`
  (with the recorded `T3` lines). `tyleq_solve` is left out (random constants have no `argsrtss`, S2B-5). Appended after the other families, so the earlier scenarios are unchanged.
* `d2dump.md5` is REGENERATED from the ATS1 output (`d2dump1`): stdout 39540 lines, stderr 3994. Seeds 1, 2, 3 byte-identical (stdout/stderr, exit 0); coverage 152/152, 19/19, 343/343;
  `d2mutate.py` 34/34 detected; `make d2dump_asan` clean (no error, no leak, same output); `make d2test` passes without ATS1. No discrepancy found.

## Tools (comarg, depgen, taggen, jsonize)

Done: `pats_comarg.{sats,dats}`, `pats_depgen.{sats,dats}`, `pats_taggen.{sats,dats}` (+ `pats_taggen.spec`, `pats_taggen_gen*.hats`: the `tagent` record) and
`pats_jsonize.{sats,dats}` (+ `pats_jsonize.spec`, `pats_jsonize_gen*.hats`: `jsonval`, `labjsonval`). Same file and external names as `src/`; every output format is
byte-identical to the ATS1 build (see Validation). Not ported (they need `dynexp2`/`trans3`): the list at the end of this section.
`src2/Makefile` appends the four modules to `SATS`/`DATS` (`make check` typechecks them) and the `gen` rules of the two specs.

### Rules (TL-1 .. TL-10; the rules above still apply)

TL-1. **`comarg` is a flat tuple.** `datatype comarg = COMARG of (int, string)` is `typedef comarg = @(int, string)` (rule 10: a one-constructor tuple datatype). A pattern
      `COMARG(1, key)` is `@(1, key)`, `COMARG(_, given)` is `@(_, given)`, a value `COMARG(i, s)` is `@(i, s)`; `comarglst(n)` is still `list_vt(comarg, n)`
      (a linear cell per argument, freed by the `~list_vt_cons` of the loop of `pats_main`). In `main` `argv` is taken out with `argv_takeout_strarr` and returned with
      `minus_addback(fpf, pf | argv)` (`test/comdump.dats`).
TL-2. **`comarglst_parse` keeps the length index** by building the list from the back (`loop(argv, i-1, list_vt_cons(parse(argv[i-1]), acc))`, accumulator of length `n-i`):
      the result is in the order of the arguments and has the type `list_vt(comarg, n)` with no `fold@`. `comarg_parse`/`comarglst_parse` are declared pure (`:<>`): the
      bodies are wrapped in `$effmask_all` (they read the characters of the argument through `$UN.ptr0_get<char>`).
TL-3. **`DATS_extract`/`IATS_extract`** (the substring after the first 5 characters) are `the_garena_strdup` of the tail (never freed) instead of `string_make_substring`;
      the length 5 is a literal in `ptr0_add_guint<char>(p, i2sz(5))` (`i2sz(k)` of a `g0int` variable does not typecheck as the offset). `is_DATS_flag`/`is_IATS_flag` use the
      libc `strncmp` of `libats/libc/SATS/string.sats` (`i2sz(5)`).
TL-4. **`process_DATS_def`** calls the template `$PAR.parse_from_string_parser<$SYN.datsdef>(def, $PAR.p_datsdef)`: the `.dats` has
      `staload _ = "./pats_syntax.dats"`, `"./pats_parsing_util.dats"`, `"./pats_parsing.dats"` and `"./pats_error.dats"` (`$ERR.abort<void>()`, rule 15; rule 16). `datsdef` is a record
      (`dd.datsdef_sym()`, `dd.datsdef_opt()`, a `gopt`), `e1xp_none`/`e0xp_tr` as before. The error messages are written with `prerr_string`/`prerr_newline`. The ATS1 text of the
      error is `patsopt: error(0): the command-line argument [DEF] cannot be properly parsed.`; the process then dies with `FatalErrorExn` (a driver that wants an exit status catches it, as `test/comdump.dats`).
      Only an identifier, a number, a string, a char or a float is accepted by `p_datsdef` (`-DATSFOO=1+2` is an error, in ATS1 too).
TL-5. **`process_PATSRELOCROOT`**: `getenv` is declared `"mac#getenv"` (`"ext#getenv"` makes a prototype that conflicts with `<stdlib.h>`); `sprintf("/tmp/.PATSRELOCROOT-%s", @(user))` is
      `string0_append` + `the_garena_strdup` + `strptr_free` (rule 3). The C function `patsopt_PATSRELOCROOT_get` is the one of `pats_utils.dats` (the `.dats` only declares it in a `%{^`).
TL-6. **`pats_depgen`**: `List_vt(string)` results are `List0_vt(string)` (rule 8), the accumulator argument is `&pathlst_vt >> pathlst_vt`, the list of the `-IATS` directories is a `glist(string)`
      (`the_IATS_dirlst_get`), a match on a `d0exp_node`/`d0ecl_node` with a default arm frees the view (`| v => d0exp_node_view_free(v)`, rules 3, P4), `castfn p2s` (`!strptr -> string`) is kept
      local. `fprint_target` scans the file name with `$UN.ptr0_get<char>` for the last `.` (`string_index_of_char_from_right` is gone). `depgen_eval` returns the reversed list;
      `fprint_entlst` consumes (frees) it. The walkers of the dynamic expressions (`depgen_d0exp`, `_d0explst`, `_d0expopt`, `_labd0explst`) are ported but, as in ATS1, nothing calls them
      (`depgen_d0ecl` only looks at `include`, `staload`, `staloadloc`, `local`, guarded declarations): they cannot be tested.
TL-7. **`pats_taggen`**: `tagent` is the record `tagent (tagent_sym: symbol, tagent_loc: location)` of `pats_taggen.spec` (`tagent_new`, `x.tagent_sym()`, `x.tagent_loc()`; `abstype tagent_type = ptr`
      from the generated file included in the `.sats`), `tagentlst_vt = List0_vt(tagent)`. The ATS1 oddities are kept: `D0Clocal` visits the *head* twice (and never the body), `GD0Ccons` visits only the
      tail of the chain, `D0Cstaload`/`D0Cinclude`/`D0Cdynload`/`D0Cfixity`... add nothing, every other declaration adds the entity `(symbol_empty, loc)`, `P0Tann` is followed but `P0Tlist`/`P0Ttup` are not.
TL-8. **`pats_jsonize`**: `jsonval` has 11 constructors with arguments, hence an arenagen spec (`--compact`: the `double` of `JSONfloat` is stored by value), the pair `labjsonval = @(string, jsonval)` is the record
      `labjsonval (labjsonval_lab: string, labjsonval_val: jsonval)` (a `glist` holds one word per element), `jsonvalist`/`labjsonvalist`/`jsonvalopt` are `glist`/`glist`/`gopt`. Constructors are `jsonval_JSONint(..)`,
      `jsonval_JSONlablist(..)`.., a match is `case+ jsonval_view(x) of ~JSONint(i) => ..`. The smart constructors (`jsonval_int`, `jsonval_labval1..8`, `jsonval_conarg0..4`, `jsonval_conarglst`...) keep their names.
      `jsonize_ignored{a:type}(x: a)` is the template `jsonize_ignored<a>(x)` (rule 15), `jsonize_list_fun<a>`/`jsonize_option_fun<a>` take `glist(a)`/`gopt(a)` (the mapping goes from the head,
      like `list_map_fun`; the templates are instantiated by the user: `staload _ = "./pats_jsonize.dats"`). `jsonize_funclo` of `FUNCLOclo(knd)` uses `funclo_get_clokind` (the ATS2 `funclo` has one constructor per kind).
      `fprintf(out, "\\u00%.2X", ..)` is two hexadecimal digits written by hand (upper case, a char >= 0x80 is printed as `\u00XX` like the C locale `isprint` says); `fprintf(out, "\"%s\"", l)` is three `fprint_*`.
TL-9. **Names kept for the callers** (`pats_main`, `pats_constraint3_jsonize`, `pats_jsonize_synent2`): `jsonize_s2cst`... will be written with `jsonval_labvalN`/`jsonval_conargN` exactly as in ATS1 (the glist arguments of a
      `jsonval_conarglst` are built with `glist_cons`/`glist_sing`/`glist_nil`).
TL-10. **Exceptions of a driver**: `$ERR.abort<void>()` raises `FatalErrorExn`; the pattern of an exception is `~$ERR.FatalErrorExn ()` in ATS2 (`try .. with | ~$ERR.FatalErrorExn () => ..`).

### Validation (ATS1 reference = the objects of `src/`; `make -C test comtable|toolfiles|tooltest|toolasan`, `python3 toolmutate.py`)

Drivers (shared C in `tooldump.cats`, `comdump.cats`; the ATS1 versions `comdump1.dats`/`tooldump1.dats` are built by `comdump1.sh` against `../../src/*.o`; `toolmods(1).hats` are the `staload`/`dynload` lists of ATS2/ATS1):
* **`comdump`** (`test/comdump.dats`): `exec -a patsopt ./comdump ARGS...` does what `patsopt_main` does before the processing of the files: sets `PATSHOME`, `the_prepathlst_push`, `the_trans1_env_initialize`,
  `the_fixity_load`, `process_PATSRELOCROOT`, `comarglst_parse`; prints every `comarg` (`print_comarg`) and then runs the loop `process_cmdline*` of `pats_main.dats`, which is *modelled in C* (`comdump.cats`: the
  options `-o -s -d -dd -cc -tc -dep -tag -h -v -DATS -IATS` and the long options, the waiting states, `-dd` taking the following non-options, `-` as stdin, the input files printed instead of processed) and calls
  `is_DATS_flag`, `DATS_extract`, `process_DATS_def`, `process_IATS_dir`, `comarg_warning` (and the `IATS` ones) of the ported module through one callback `cm_call`. After the loop: the state (`STATE`, `FLAGS`), the
  `-IATS` directories (`the_IATS_dirlst_get`) and the entries of the e1xpenv for every `-DATS` definition and for `PATSRELOCROOT`. stdout, stderr and the exit status are compared (an abort is caught: `EXN FatalErrorExn`, status 3).
* **Table** `comtable.txt` (782 command lines, `com_table.py`, run by `com_run.py`: valid and invalid; every short and long option alone, with a file, at the end; `-o/--output*` and `-s/-d/-dd` waiting for an argument;
  `-DATS`/`-IATS` in the forms `-DATSX=1`, `-DATS X=1`, `-DATS` at the end, with 20+20 definitions/directories, bad definitions (`A=(`, `=`, `A==1`, ...); prefixes (`-DAT`, `-IATA`); only dashes, empty strings, UTF-8, `-` stdin;
  whole programs; the environment (`USER` unset/empty/odd, `PATSRELOCROOT`/`ATSRELOCROOT`); 220 random combinations of 1..9 arguments): 68 exit with status 3 (aborted by a bad `-DATS`), 340 have warnings, 6850 lines
  of output: **identical** in stdout, stderr and status (`make comtable`).
* **`tooldump`** (`test/tooldump.dats`) takes lines `KIND<TAB>path`: `DEP` (`--depgen` as `do_depgen` of `pats_main`: `parse_from_givename_toplevel`, `depgen_eval`, `the_filenamelst_ppop`, `fprint_entlst`), `DEPI` (the same with
  `process_IATS_dir` on PATSHOME, PATSHOME/prelude, PATSHOME/src2), `TAG` (`taggen_proc`, `fprint_entlst`), `JSN` (the JSON of the whole level-0 tree) and `API`. The JSON-izer of the level-0 tree is *generated* from
  `pats_syntax.spec` by `jsondump_gen.py` in ATS1 (`jzdump1.hats`) and ATS2 (`jzdump.hats`) with the library of `pats_jsonize` (`jsonval_labvalN` for every record, `jsonval_conargN`/`conarglst` for every constructor of the spec,
  `jsonize_list_fun`/`jsonize_option_fun` for the lists, `jsonize_location/symbol/label/filename/funkind/valkind/ignored`); the API case (`tooldump_api.hats`, 80 cases) calls every function of `pats_jsonize.sats` (ints, intinfs of 30
  digits, bools, 9 doubles, strings with every char 1..255, `\n\t\b\f\"\\`, UTF-8, locations, filenames, `sing/pair/labval1..8/conarg0..4/conarglst/none/some`, lists, options, symbols, labels, stamps, funclo, caskind, funkind, valkind, dcstkind).
* **Whole files** (`make toolfiles`, `toolfiles.sh`): the 2809 `.sats/.dats/.hats` of the repository (links followed; prelude, libats, contrib, doc, src, src2, utils...) in 6 modes (`DEP` absolute path, `DEPR` relative path with the
  process in the repository directory, `DEPI`, `TAG`, `TAGR`, `JSN`) + a file without a dot in its name + the API = 16858 runs (14921 complete, 1937 end with a fatal parse error: ATS1 sources, `doc/BOOK`: identical), 274 MB of output:
  **identical** (stdout and stderr; d1chunk.sh restarts a process after a fatal error). Hand-written cases `test/toolcases/` (`dep1.dats`: includes/staloads of every form, in `local` heads and bodies, nested in `#if/#ifdef/#elif/#else`,
  `$PATSHOME`, `$PATSHOMELOCS`, missing, `..`; `tag1.dats`: every declaration; 12 files) are part of the repository run, and alone give `toolcases.md5` (`make tooltest`, no ATS1 needed; line 2 is the md5 of `comtable.txt`).
* **Coverage** (gcc `--coverage` on the C of the four modules, running `comtable` and `toolfiles`): every function written by hand is executed; lines executed: `pats_comarg` 99.4% (2 unreachable lines after `abort`), `pats_taggen`
  100%, `pats_depgen` 59% (the four unused walkers of expressions, 100% of the rest), `pats_jsonize` 87.7% (the generated `jsonval_encode/view_free/is_*/tag` that nothing calls and the unreachable `JSONnul` arm of `jsonize_label`).
* **Sensitivity** (`python3 toolmutate.py`): 27 deliberate bugs (7 in comarg, 6 in depgen, 5 in taggen, 9 in jsonize: the count of dashes, the length of `-DATS`, the order of the arguments, the `-IATS` list, the default `PATSRELOCROOT`,
  the text of a warning, the body of a `local`, the separators, the target name, the order of the entities, an off-by-one of `nline`/`nchar`, the escape of a tab, the case of the hex digits, `labval3`, the kind of a closure,
  the list order...) each detected (by `comtable` or `toolfiles`). One more (`$PATSHOMELOCS` searched in the `-IATS` dirs) is equivalent on this repository and was dropped; the `d0exp` walkers of depgen cannot be mutated (dead code).
* **AddressSanitizer** (`make tooldump_asan comdump_asan`, leak detection on): `comtable` (782 lines) and the whole `toolfiles` run (16858 runs): no error, no leak report (the arena is reachable from its globals).

### Notes for the `pats_main` driver port

* `pats_main.dats` must `dynload` `pats_jsonize.dats`, `pats_depgen.dats`, `pats_taggen.dats`, `pats_comarg.dats` after `pats_trans1_env` (the `dynload` order of `test/toolmods.hats` works) and `staload _ = "./pats_jsonize.dats"` /
  `"./pats_parsing.dats"` where it instantiates the templates; link `-lgmp` and `pats_error_sats.o`.
* The loop `process_cmdline*` of `pats_main.dats` was not ported here (only modelled for the tests); `test/comdump.cats` is a faithful C copy of the option dispatch (`cm_comarg1`, `cm_comarg2`, `cm_run`) to compare with. The patterns
  `COMARG(1, key)` become `@(1, key)` (TL-1); `comarglst(i)` loops that `fold@` a list cell become `~list_vt_cons` (the arguments are consumed, `free@{comarg}{0}(arglst)` is no longer needed: `@(i, s)` is flat).
  `patsopt_usage`/`patsopt_version` and `cmdstate` are in `pats_main.dats` (`comarg0= comarg` is a flat tuple: no problem in a `@{..}` record).
* `do_depgen`/`do_taggen` are: `ents = depgen_eval(d0cs)` / `taggen_proc(d0cs)`, `the_filenamelst_ppop()` (the file pushed by `parse_from_givename_toplevel`), then `fprint_entlst(filr, given, ents)` (`depgen` and `taggen` both declare
  `fprint_entlst`: staload them qualified, `$DEPGEN.`, `$TAGGEN.`).
* `process_DATS_def` aborts the process with `abort` (an exception in ATS2: nothing in `patsopt` catches it, as in ATS1); `process_PATSRELOCROOT()` is called after `the_trans1_env_initialize()` (the e1xpenv must exist).
* `jsonize_ignored<a>` is a template: callers of `jsonize_ignored(x)` in `pats_jsonize_synent2` and `pats_constraint3_jsonize` write `jsonize_ignored<T>(x)`.

### Not ported (needs dynexp2 / staexp2 + trans3)

* `pats_jsonize_synent2.{sats,dats}` (2086 + 138 lines): `jsonize_s2rt/s2cst/s2var/s2Var/d2con/s2exp/..` (needs `pats_staexp2`, ported in the other branch, and `pats_dynexp2`, not ported) and
  `jsonize_d2cst/d2var/d2itm/d2ecl/d2eclist`, `d2eclist_jsonize_out` (the `--jsonize-2` output of `pats_main`). It only needs the `pats_jsonize` API above (all of it is exercised by `tooldump_api.hats`).
* `pats_constraint3_jsonize.dats` (468 lines, needs `pats_constraint3`), the mapgen files (`pats_dynexp2_mapgen.dats`, `pats_constraint3_mapgen.dats`: they only mention `jsonize`).
* There is no jsonize of level-0 or level-1 trees in `src/`: `test/jsondump_gen.py` (generated from `pats_syntax.spec`) is the level-0 one used by the tests.

### Open problems (tools)

* The option loop of `pats_main` is tested through a C model, not through the real `process_cmdline*`; the real one will be validated when the driver is ported (`patsopt -s/-d` outputs vs ATS1).
* `fprint_jsonval` allocates a view per node (malloc/free per match, rule 3); fine for the sizes of the tests (274 MB of JSON in 25 s on 8 cores).
* `jsonval` trees are never freed (global arena); a large `--jsonize-2` run will keep them until exit.

## Constraint solver (lintprgm): pats_lintprgm*, rules LP-1 .. LP-10

Done (typecheck, link, differential test, see Validation): `pats_lintprgm.sats`, `pats_lintprgm.dats` (the operations on `myintvec`, the normalisation
by the gcd, the lists of constraints), `pats_lintprgm_print.dats`, `pats_lintprgm_solve.dats` (Fourier-Motzkin with the elimination of the equalities, the
disjunctions by backtracking), `pats_lintprgm_myint.{cats,dats}` (the selector of the kind of integers, `C3NSTRINTKND` as for `pats_intinf.dats`),
`pats_lintprgm_myint_int.dats` (`myint(intknd)` = `int`), `pats_lintprgm_myint_gmp.{cats,dats}` (`myint(gmpknd)` = a malloc-ed `mpz_t`). 3.9k lines of
ATS1, 3.6k of ATS2 (the loops over the elements of a vector are the bulk; the closures `array_ptr_foreach_vclo` are explicit loops). Same file and function
names. No spec/arenagen: the trees of this module are not shared (they are linear and freed by the solver), so they stay `datavtype`s.

### Rules

LP-1. **The kind is a template argument, as in ATS1**: every function is `fun{a:t@ype}` and `a` is `intknd` or `gmpknd` (`$extype`, typedefs in
      `pats_lintprgm_myint.cats`, included by the sats with `%{#`). The implementations of one kind are `#include`d by the user (`#include "./pats_lintprgm_myint.dats"`,
      or `..._myint_int.dats` / `..._myint_gmp.dats` directly), then `staload _ = "./pats_lintprgm.dats"`, `"./pats_lintprgm_print.dats"`, `"./pats_lintprgm_solve.dats"`
      (rules 15, 16). Link `pats_lintprgm.dats` compiled by itself (the non-template `myintvec0_free`) and `dynload` it (rule 17); `pats_lintprgm_solve.dats`
      has the non-template `indexset_*`: compile it too, or `#include` it as the test drivers do (they also test its internal functions). gmp needs `-lgmp`.
      `pats_lintprgm_myint_int.dats` is no longer included by `pats_lintprgm_solve.dats` (ATS1 did it in a `local`): include the one you need.
LP-2. **`myint(gmpknd)` is one pointer to a malloc-ed `mpz_t`** (`pats_lintprgm_myint_gmp.cats`: `patsopt_lpz_*`, static inline wrappers; the cell is freed by
      `myint_free`, so the solver does not leak; not the arena, which has no free). The ATS1 `lintinf` view tuples `(pfgc, pfat | p)` are gone; the casts
      `mi2p0` (consumes) / `mi2p1` (borrows) / `p2mi`. `myint_make_intinf<gmpknd>` copies the `mpz_t` of an `intinf` (a `ptr` to the arena cell, `pats_intinf.dats`).
      `mod01/mod11` are `mpz_mod` (non negative), `div01` is `mpz_tdiv_q`, `ediv01` is `mpz_divexact`, `compare_*` return the raw `mpz_cmp` (not a sign).
      For `intknd` the gcd is the one of the prelude of ATS1 (`patsopt_lintprgm_gcd_int_int`, the sign of the arguments is ignored, `INT_MIN` as it was).
LP-3. **Arrays**: `array_v (a, l, n)` (the ATS1 order was `(a, n, l)`), `mfree_gc_v (l)` (was `free_gc_v (a?, n, l)`), `array_ptr_free (pf, pfgc | p)` (the proofs are swapped),
      `p + sizeof<vt>` is `ptr_succ<vt> (p)`, `array_ptr_takeout<a> (pf | p, i2sz (i))`. The loops are the ATS1 loops with the proofs `array_v_uncons/cons`; a function declared `:<>`
      in the sats and implemented with writes needs `$effmask_wrt`: I removed the `:<>` of the mutating functions of the sats (`myintvec_*`, `myintveclst_free`; the
      `myint` arithmetic stays `:<>`). `myintvec0_make` is `$effmask_wrt (array_ptr_alloc ..)` and a `castfn` with proof arguments (`__cast (pfgc, pfarr | p)`) works as in ATS1.
LP-4. **Linear lists**: `list_vt_cons (!p_iv, !p_ivs)` is `@list_vt_cons (iv, ivs1)` + `fold@` (rule 8); no `fold@` after `list_vt_nil` (the nil arm just returns/does nothing). A
      `&` argument that is a list (`ivs: &myintveclst (a, n)`, `ics: &icnstrlst (a, n)`) is declared `&T >> T` (`List0_vt` is existential: without `>>` the opened length must be
      preserved: "unsolved constraint for var preservation"); a function that takes a list `&`-argument of the form `list_vt (x, s)` keeps its index. `list_vt_split_at` returns
      the pair `(prefix, rest)` (ATS1: modified its argument and returned the prefix); `list_vt_pair` is the same macro. `lemma_list_vt_param` for `list_vt_length_is_nonnegative`.
      A cell that is moved to another list is first `fold@`-ed, then assigned (`ivs1 := poss; fold@ (ivs); poss := ivs`).
LP-5. **No exception for the early exit of `myintvec_cffgcd`**: the loop stops as soon as the gcd is 1 (a `try/$raise Finished` and a closure in ATS1, which also did not
      need to) and takes `res: &vt`. `case+ knd of | ~2 => ..` (negative literals) are `if` chains. A local function that captured the `iset`/`pf` (`indexlst_make`'s `loop`) takes it as an argument.
LP-6. **The doubly linked stack `myiveqlst`**: a `datavtype` with a `ptr` to the previous (newer) cell, as in ATS1. The ATS1 `!p_prev` pattern gave the address of the field and
      `ptrset` wrote through it; here `myiveqlst_set_prev (cell, p)` assigns the field under an `@`-pattern, the address of a cell is `$UN.castvwtp1{ptr} (cell)`, and the traversal
      from the oldest cell (`myintvec_elimeqlst_rev`) re-types a `ptr` as the list with `$UN.castvwtp0` and consumes it back with `$UN.castvwtp0{ptr}` (never freed twice).
      PROTOCOL (kept from ATS1): after `myiveqlst_unmark` the `prev` field of the head points to a freed mark; it is repaired by the next `mark` or `cons`, and nothing may traverse the
      stack before (`auxmain_disj` re-marks before each branch). `test/lp/lpdrv_common.hats` obeys it (ASan finds the use-after-free otherwise).
LP-7. **`indexset (n)`** (ATS1: a `funset_listord` of the indices, built by `constraint3`): no persistent tree is needed for at most 63 indices: `indexset(n) = ptr` is a tagged word
      `(mask << 1) | 1` (bit `k` = `k` is in the set, `1 <= k <= 62`), no allocation; a bigger index makes a block of the global arena `[nwords, words..]` (copied at each `add`, never freed:
      a set with indices >= 63 is rare, and `n` is bounded by the number of variables of an obligation). `indexlst_make` is unchanged (members first, ascending; the others, ascending).
LP-8. **Names that moved or are new**: `myintvec_set_at` is implemented here (declared, not implemented in ATS1: the test drivers need it); `compare_myint_myint<intknd>` is implemented
      (ATS1 had none for `intknd`); `myintvec_assign`, `div11_myint_myint<gmpknd>` stay declared and unimplemented as in ATS1. `s3exp` of `ICerr` is `abstype s3exp_type = ptr`
      (`typedef s3exp = s3exp_type`): the `constraint3` port must keep it a `ptr` (the field is only stored/printed as `...`; `$UN.cast` it as ATS1 did).
LP-9. **Strings/printing** are unchanged (`fprint_*` of the sats). `print_myintveclst`, `print_icnstrlst` etc. print exactly as ATS1.
LP-10. **Compiler quirks**: `indexlst_choose{n} (ilst)`, `indexset_is_member{n} (xs, x)`, `indexset_add {n}` need the explicit static argument (`index (n)` is `intBtw (1, n)`: `n` is not inferred);
      `g1int_nmod (x, 64)` for the shift count of `ulint` (`x mod 64` is not `intGte(0)`); the same linear variable cannot be passed twice to one call even as `!` arguments
      (`comb_loop (iv2, iv2, ..)` of the driver); `val+ @Con (..) = res` is "nonexhaustive": use `case+ res of | @Con .. | other => ()`.

### Validation (ATS1 reference: the sources of `src/` compiled by `lpdrv1.sh` with `atscc -O2 -fwrapv`; `make -C test/lp compare|asan|cover|mutate|bench`)

* **Drivers** `test/lp/lpdrv1.dats` (ATS1) and `lpdrv2.dats` (ATS2) `#include` ONE common program, `lpdrv_common.hats` (the common subset of ATS1/ATS2; the C declarations and
  the problem reader are shared: `lpdrv.c`), for both kinds (`-DATS LPKNDGMP`, else `intknd`). They read the problems of `lpgen.py` and print: the
  hint set (membership of every index, and the order of the indices of `indexlst_make`, which are internal), every
  vector (`inspect` of the 4 kinds + `inspect_gte/lt/eq/neq` (eq normalises), `cffgcd`, `normalize_gte`, `copy`, `copy_cff`, `scale`, `negate`, `add_int`, `addby/subby/addby_cff`,
  `get_at`/`compare_at`, and the INTERNAL `combine_at`, `get_index_of_absmincff`, `elimeq_at` of `pats_lintprgm_solve.dats`, which the driver `#include`s); the lists (`inspect_gte`,
  `normalize_gte`, `split_at` for every index, `elimeq_at` of a list, `myintveclst_solve`); the stacks `myiveqlst`/`myivlst` with marks (`cons`, `mark`, `unmark`, `elimeqlst`,
  `myivlst_elimeqlst`); the constraint trees (`print_icnstrlst`, `icnstrlst_copy`, `icnstrlst_negate`, `icnstr_copy/negate/free`) and `icnstrlst_solve` three times (with the hint, without,
  on the negated list) with the answer AND the list left by the solver; records `I a b` test every `myint` operation (`neg/neg1/add/sub/mul01/10/11/div/ediv/mod/gcd/compare/lt..`).
* **`lpgen.py`** (seeded) makes: planted-solution systems (label `sat`: the solver must not answer -1), infeasible ones built by 7 constructions (label `unsat`: -1 expected): two
  contradictory inequalities, a sum of inequalities with a negative constant, an equality combination with a wrong constant, gcd contradictions of an equality / of two inequalities,
  an equality and a strict inequality, `v != 0` with `m*v = 0`; random systems (`?`); nested conjunctions/disjunctions with `ICerr`; difference constraints over up to 26 variables
  and a negative cycle (`chain`); 58-80 variables (`wide`, exercises the heap `indexset`); coefficients that exceed 64 bits (`gmp`: scale factors up to 10^50, 3^50, 2^64+1) or fit an `int`; equalities with big
  coefficients. `lpcheck.py` verifies the labels on the output (never contradicts a `sat`, refutes every `unsat` with and without the hint).
* **Result**: 5 files of 8000 records (gmp seeds 11 12 13, int seeds 21 22; `make compare`): **33256 problems P** (19981 gmp, 13275 int; per gmp file ~2000 `sat`, ~2650 `unsat`, ~670 `wide`) and 6744 integer
  records I, **1.75 GB of output (17.2M lines): ATS1 and ATS2 byte-identical** for both kinds; label check (gmp): 0 violations (3406 of 6612 answers are `-1`). The same drivers under AddressSanitizer
  (leaks on) on `lp_small_*.txt` (264 problems): no error, no leak. `make test` (ATS2 only) checks the md5 of the output of the ATS1 driver on those two files (`lp_small.md5`).
* **Coverage** (`make cover`, gcov by ATS line, `patsopt --gline`, 250 + 40 wide problems): 1157 of 1165 executable lines of the 4 modules (gmp; 1149 of 1157 for int), 100% of `myint_gmp.dats`/`myint_int.dats`; the rest is
  dead code (`assertloc (false)` of an impossible `knd`, `fprint_int` of an unknown `knd`, the `nil` arms of `set_prev`).
* **Mutation test** (`lpmutate.py`, 39 deliberate bugs in 7 files (36 apply to gmp, 35 to int), e.g. `inspect` at 0, the gcd stop, `ediv`, the tightening of a negative constant, a negated copy, the combination of the
  coefficients, the split of the signs, the `absmincff` order, `elimeq_at`, the limit of the immediate `indexset` (62 -> 61), a big `indexset` member, `auxneq`'s second branch, the order of the disjuncts,
  the stamp of `elimeqlst`, `mark` without the link, the `mpz_mod`, the gcd of negative ints...), each run on 1050 problems of the kind (ATS1 output as reference): **gmp 36/36 and int 35/35 detected**
  (the first run missed 4: one equivalent mutant, one `add_int` of 0, and the two `indexset` ones, which made the driver print the hint set and the order of `indexlst_make`).
* **Speed** (`make bench`: 30000 systems of 4 variables, `bench`: only the solver, `-O2`): ATS1 24.5-28.3 s / ATS2 22.6-27.1 s (gmp), 0.77 / 0.74 s (int); 240 systems of 5 variables (one blow-up of Fourier-Motzkin each):
  ATS1 70-83 s / ATS2 67-85 s: **the same speed** (both are gmp-bound: a malloc-ed `mpz_t` per element and one more per product, as in ATS1; an `mpz_addmul`-based `addby_cff` would save the temporary).

### Open problems (lintprgm)

* `indexset` blocks (>= 63 variables) and everything in the arena are never freed (nothing is freed by the solver itself: vectors, lists and the `mpz_t` cells are linear and freed).
* The solver is exponential (Fourier-Motzkin): a system of 7+ dense variables with 10+ constraints can take minutes (in ATS1 as well); the drivers limit the sizes.
* `myintvec_normalize` and the other `extern` functions of `pats_lintprgm.dats` / `pats_lintprgm_solve.dats` are not in the sats (as in ATS1); only the solve internals are reachable from the tests via `#include`.
* `constraint3` (next): `staload _` the three `.dats` after `#include "./pats_lintprgm_myint.dats"`; build the vectors with `myintvec_make<a>` and `myintvec_set_at` (or `myintvec_takeout`); `ICerr` carries a `location`
  and an opaque `s3exp` (a `ptr`); the hint set is built with `indexset_nil/indexset_add` (needs `n` explicit: `indexset_add{n} (xs, i)`).

## Typerase trees (histaexp): pats_histaexp{,_print,_funlab} (rules HS-1 .. HS-7)

Done (typecheck, link, differential test, see Validation): `pats_histaexp.{sats,dats}` (the high-level types of the typerase output, `hisexp` and its constructors, the
queries and `hisexp_subst`), `pats_histaexp_print.dats`, `pats_histaexp_funlab.dats`, `pats_histaexp.spec` (+ `pats_histaexp_gen.hats`, `pats_histaexp_gen_dats.hats`, committed: 150 and 390
lines, `make gen`). 1.4k lines of ATS1, 1.5k of ATS2 + 0.5k generated. Same names, same external names; the first of the typerase output trees (`hidynexp`, `typerase` follow).
NOT checked by `make check` of `src2/`: the three `.dats` staload `pats_stacst2.sats` (the other port, in the other branch): `make check` covers `pats_histaexp.sats`; `test/hs` typechecks, links and
tests the `.dats` in a staging directory where `test/hstub/pats_stacst2.sats` (a stub with the names and types of the real one: `s2cstref`, `the_atsvoid_t0ype`, `the_atstype_int/bool/size`) takes its place.

### Rules

HS-1. **Spec** (`pats_histaexp.spec`, `--global --compact`): `hisexp_node` (16 constructors, `type`), the records `hisexp (hisexp_name, hisexp_node)`, `hitnam (hitnam_ptr, hitnam_fin, hitnam_name)` (ATS1: the one-constructor
      datatype `HITNAM (int, int, string)`; `HITNAM (knd, fin, name)` is `hitnam_new (..)`, a match `val+HITNAM (knd, _, _) = x` is `x.hitnam_ptr ()`, no view), and `labhisexp (labhisexp_lab, labhisexp_opt, labhisexp_elt)`
      (ATS1: `HSLABELED of (label, Option (string), hisexp)`; `stringopt = gopt (string)` of the staexp2 spec). `hisexplst hisexpopt hisexplstlst labhisexplst` are `glist/gopt`. Names as in "Arena AST":
      `hisexp_node_HSEcst (s2c)`, `case+ hisexp_node_view (nd) of ~HSEcst (s2c) => ..`, `hisexp_node_is_HSEtyarr (nd)`, `hisexp_new (name, node)`, `x.hisexp_node ()`.
      `a.f().g()` does not parse as a chain of calls on a record field: bind the intermediate (`val hit = x.hisexp_name () in hit.hitnam_ptr ()`).
HS-2. **`funclo` is an enum**: `hisexp_fun` matches `FUNCLOfun () | FUNCLOclo0 () | FUNCLOcloptr () | FUNCLOcloref ()` (ATS1 `FUNCLOclo (knd)` with `knd = 0` -> `HITNAM_CLOTYP`, else `HITNAM_CLOPTR`).
HS-3. **The constants of the sats** (`hisexp_tybox`, `hisexp_typtr`, `hisexp_funptr`, .. `hisexp_undefined`) are `val x : hisexp = "ext#patsopt_hisexp_x"` (rule 18) built when the module is dynloaded, after the
      arena, `pats_symbol` (the symbols `atstyclo_top`, `atstype_undefined`) and `pats_staexp2` (the dynload order of "Level 2" + `pats_histaexp`, `pats_histaexp_print`, `pats_histaexp_funlab`). The `HITNAM_*` values
      of the dats are plain `val`s. `hisexp_int_t0ype ()` etc. look the constant up with `$S2C.s2cstref_get_cst ($S2C.the_atstype_int)` (needs the prelude of the checked program).
HS-4. **Tests do not allocate**: `hisexp_is_boxed` reads `hitnam_ptr`, `hisexp_is_tyarr/tyrecsin` use `hisexp_node_is_*`; a payload match with other cases ends with `| v => (hisexp_node_view_free (v); default)` (rule 3).
      `hisexp_subst` is the ATS1 `aux/auxlab/auxlst/auxlablst/auxlstlst` with the shared structure preserved: the list functions walk with `glist_is_cons/head/tail` (no view) and return the old list if the
      flag did not change; the `local` is gone (nothing is private any more: S2-4).
HS-5. **`fprint_funlab`**: ATS1 calls `$CCOMP.funlab_get_name`; `pats_ccomp.sats` is not ported, so `pats_histaexp_funlab.dats` calls `patsopt_funlab_get_name` (a C function that `pats_ccomp.dats` will define, with a prototype
      `extern atstype_ptr patsopt_funlab_get_name (atstype_ptr)` in a `%{^`, otherwise C99 takes the result for an `int`). `funlab` is `abstype hisexp_funlab_type = ptr`; `pats_ccomp` will make its funlab record a `ptr`
      handle and `$UN.cast` it as ATS1 did.
HS-6. **Declared in ATS1 and never implemented** (not here either): `print_hitnam`, `prerr_hitnam`, `fprint_hitnam`.
HS-7. **Pitfall of the test harness, found here**: a C function called through `mac#`/`ext#` without a prototype returns `int` in the generated C (C99): a `void *` result is truncated to 32 bits (the table of the stub of
      `pats_stacst2` returned a cst pointer that crashed only the second time it was found). Declare the prototype in a `%{^ .. %}` of the file that calls it.

### Validation (ATS1 reference: the sources of `src/` compiled by `hsdrv1.sh` with `atscc`; `make -C test/hs test|compare|cover|mutate|asan`)

* **Drivers** `test/hs/hsdrv1.dats` / `hsdrv2.dats` include the common program (`hs_leaf.hats`, `hs_common.hats`) with the language layers (`hs_hand1/2.hats`) and the layers generated from the spec by `hs_gen.py`
  (`hs_compat1/2.hats`: the constructors `K_x` of the three records and the 16 constructors, the list constructors, and a COMPLETE dumper of the types: every field), and the cases `hs_cases.hats` (seeded):
  random trees (depth 3) built with every smart constructor of the sats (and every constant), with the raw constructors and names that no smart constructor makes, on top of `s2exp`/`s2var`/`s2cst`/`d2con` of the real
  level-2 modules (the constants of `pats_stacst2` come from the stub, see above). For each tree `hs_all` prints the complete dump, `fprint_hisexp`, the name, the 9 queries (`get_boxknd/extknd`, `is_boxed`, `is_void`,
  `fun_is_void`, `is_noret`, `fun_is_noret`, `is_tyarr`, `is_tyrecsin`), and the results of `hisexp_subst` for 3 substitutions (two with several variables, one empty; whether the result is the same tree),
  and a few constants/printers (`print_hisexp`, `print_funlab`, `prerr_*`). The ATS1 driver prints the funlab itself (`pats_histaexp_funlab.dats` of ATS1 needs `pats_ccomp.sats`).
* **Result**: 3000 cases (seed 2: all 16 constructors, every smart constructor, 33k lines of output, stdout and stderr): **ATS1 and ATS2 outputs identical**; under AddressSanitizer: no error, no leak (400 cases).
* **Coverage** (`make cover`, gcov by ATS line, `patsopt --gline`): 464 of 469 executable lines of the three modules (the 5 others are blank lines of gcov and the `prerr_` bodies before they were called).
* **Mutation test** (`hsmutate.py`, 25 deliberate bugs: the box kinds, `is_void`/`is_noret` of constants/variables/singleton records, the kinds of closures, `tyrec2`, the names of constants, `refarg`, `extype`, the
  substitution of variables / arrays / sums / lists of lists / labelled elements, the printer): 24/25 on the first run (the survivor, the order of two pure calls, is equivalent and was replaced): **25/25 detected**.
* **Stubs to delete after the merge of the util2/stacst2 port**: `test/hstub/pats_stacst2.sats`, `test/hs/hs_stub1.hats`, `hs_stub2.hats` (the table of constants), `hs_stub_util2_1.hats`, `hs_stub_util2_2.hats` (copies of
  `s2stub1_hand.hats`, `s2stub_hand.hats`, which the other branch deletes), and the `staload` of the stub in `hsdrv2.sh`.

### Notes for hidynexp / typerase

* A hisexp is built by the smart constructors only; the typerase code of ATS1 matches `hisexp_node` in many places: use `hisexp_node_view` + `| v => (hisexp_node_view_free (v); ..)` or the `_is_` tests.
* `pats_typerase_staexp.dats` makes labelled elements with `HSLABELED (l, None, hse)`: `labhisexp_new (l, gopt_none (), hse)`; the third field of a `hitnam` is a `string` literal or a copy
  (`the_garena_strdup`) if it is made at run time (`hisexp_extype` stores the string it is given).
* The `funlab` of `HSEtyclo` is only stored/printed here; `pats_ccomp` owns the type.

### Open problems (histaexp)

* `pats_histaexp*.dats` are not in the `DATS` list of `make check` until `pats_stacst2` is merged: add them then (and remove `test/hstub`).
* The `hitnam`/`hisexp`/`labhisexp` cells are never freed (arena); `hisexp_subst` shares the unchanged subtrees as ATS1 did.

Note 2026-10-15 (after the merge of util2/stacst2): the stubs are gone (`test/hstub/`, `hs_stub1/2.hats`, `hs_stub_util2_1/2.hats`). The drivers use the real `pats_stacst2`, `pats_staexp2_util2/util3/solve`
(`hsdrv1.sh` compiles them from `src/` with the others; `hsdrv2.sh` adds them to the modules); `hs_env2.hats` / `hs_env1.hats` are the doubles of `pats_trans2_env`/`pats_trans3_env` (`the_s2expenv_pervasive_find` makes the
pervasive constant of the name on demand, the other functions abort: no case reaches them). `make check` now typechecks the three `.dats`. `hs_small.md5` regenerated from the ATS1 driver (unchanged). Re-validated: `make -C test/hs compare`
identical (3000 cases, 33019 lines), cover 469/469 lines, mutate 25/25, asan clean, `make hstest` without ATS1 passes.

## Macros (dmacro2): pats_dmacro2, _eval0, _eval1, _print, and the partial pats_trans3 (rules M2-1 .. M2-10)

Done (typecheck, link, differential test, see Validation): `pats_dmacro2.{sats,dats}`, `pats_dmacro2_eval0.dats` (macro expansion of the code level),
`pats_dmacro2_eval1.dats` (quote / unquote on the level-2 trees), `pats_dmacro2_print.dats` (+ `pats_dmacro2.spec`, generated `pats_dmacro2_gen*.hats`, not in git).
3.3k lines of ATS1, 3.4k of ATS2. Same file and external names as `src/` (`patsopt_m2val_true`, `patsopt_m2val_false`). The evaluator reports its errors through
`the_trans3errlst_add`, so a PARTIAL `pats_trans3.{sats,spec}` and the (complete) `pats_trans3_error.dats` came with it (M2-4).

### Rules

M2-1. **`m2val` and `m2valist`** are generated (`pats_dmacro2.spec`, `--global --compact`): `m2val_M2Vint (i)`, `m2val_M2Verr ()` (a nullary constructor is a function), `case+ m2val_view (x) of ~M2Vint i => ..`,
      `m2val_is_M2Vint (x)` for a test without the view; `m2valist = glist (m2val)`. `val m2val_true : m2val and m2val_false : m2val` have the C names `ext#patsopt_m2val_true/false`. As everywhere, a
      wildcard arm on a view frees it: `| v => (m2val_view_free (v); ..)`. The accessors that the code of ATS1 wrote as nested `case` on two values are `m2val_is_..` tests plus `m2val_int_get`
      (`pats_dmacro2_eval0.dats`), with the same order of evaluation and the same errors.
M2-2. **`alphenv` and `evalctx` stay linear lists** (`datavtype`, `absvtype .. = ptr` in the sats). `!p_env1` patterns became `@ALPHENVsadd (k, v, env1)` + `fold@ (env)`; a nullary arm
      (`ALPHENVnil ()`) is not unfolded, so there is no `fold@` there (rule 8). `ctx: !evalctx` and `env: &alphenv` are passed as in ATS1 (`ctx := evalctx_dadd (ctx, d2v, m2v)`).
M2-3. **No closure was needed.** `eval1_type (a)` is a plain function-pointer type `(location, !evalctx, &alphenv, a) -> a`; `eval1_listmap` is the template `eval1_listmap<a> (loc0, ctx, env, xs, f)`
      (rule 15: a user instantiates it with `staload _ = "./pats_dmacro2_eval1.dats"`; the test does it in `t_listmap`). The `extern fun eval1_X : eval1_type (X)` of ATS1 are written with their parameters.
M2-4. **`pats_trans3` is partial.** `src/pats_trans3.sats` staloads `pats_dmacro2.sats` (the errors carry `m2val`), and the evaluator needs `the_trans3errlst_add` and five constructors of `trans3err`, so
      `pats_trans3.sats` / `pats_trans3.spec` hold only `T3E_dmacro_eval0_cmp`, `_eval0_d2exp`, `_eval0_app_mac_arity`, `_evalctx_extend`, `_eval1_d2exp` (generated: `trans3err_T3E_dmacro_eval0_cmp (loc, m2v1, m2v2)`,
      `trans3err_view`), the list `the_trans3errlst_add/_finalize`; `pats_trans3_error.dats` is the complete port of the ATS1 file (it is the list of `pats_trans1_error.dats`). **The trans3 port must add the other
      constructors to the spec and the rest of `src/pats_trans3.sats` to the sats (the names are kept), not replace these files.** ATS1 only counts the errors (the list is never printed): the count is the
      only thing the tests can see (`patsopt(TRANS3): there are [n] errors in total.`).
M2-5. **`val-list_cons (x, xs) = xs` (MatchError)** is `assertloc (glist_is_cons (xs))` + `glist_head/_tail` (`evalctx_extend_arglst`, `eval1_v2aldeclst(_rec)`, `eval1_d2exp_applst`, `_macsyn`). A macro that is applied to
      fewer argument groups than it has (`n0 < narg`) prints its error and then aborts in ATS1 and here (the exit status is nonzero in both; the text of the abort differs).
M2-6. **`exitloc (1)`** (the default arm of `eval1_p2at`, the patterns that are not supported: `P2Trefas`, `P2Texist`, `P2Tvbox`, `P2Tlist`, `P2Terrpat`) is the same prelude macro in ATS2 (`exit_errmsg` with the location of the
      source line of the port: the text differs from ATS1's by construction); the `println!` before it prints the pattern with `print_p2at`, identically.
M2-7. **Evaluation order.** ATS2 evaluates the arguments of a call from left to right like ATS1, and the port keeps every `val` in its place (`d2exp_arrsub (loc0, d2s, eval1dexp (d2e), loc0, eval1dexplst (ind))`...):
      the family `order` of the tests makes every child of every node report an error at its own location, so a swapped order shows in stderr.
M2-8. **`case+ 0 of | _ when sym = X => ..`** is an `if .. else if` chain; a `when` guard on a linear view is not used (`D2Esym (d2s) when d2sym_is_nonqua d2s` tests inside the arm; the fallthrough goes to the same
      error message). `compare_int_int` returns an `int` here (-1/0/1) instead of a `Sgn`. `int_of_llint (..)` is `$UN.cast{int}`. The tokens of `D2Ei0nt/c0har/f0loat/s0tring` are read with the helpers of
      `pats_syntax_token.hats` (`token_int_rep`, ..). `list_split_at` / `list_append` / `list_length` are `d2exparglst_take/_drop` (two small recursive functions), `glist_append`, `glist_length`.
M2-9. **Dead code kept as in ATS1** (it is unreachable in both): `eval0_d2exparg_1`, `eval0_d2exparglst_1`, `eval0_app_lift`. In the tests they are the only functions of the five modules that never run.
M2-10. **Hygiene is not implemented in ATS1 and not here**: `d2var_rename (loc0, d2v) = d2v` ("HX: is this okay?"), so the `alphenv` that `eval1` builds (`P2Tvar` binds `d2v -> d2v`) never changes a result: the
       functions `alphenv_*` are tested directly, but a bug in the pushes/pops of `D2Elet` / `D2Ewhere` is invisible through `eval1_d2exp`.

### Validation (ATS1 reference = the objects of `src/`; `make -C test m2compare|m2test|m2cover|m2dump_asan`, `sh m2exit.sh`, `python3 m2mutate.py REF.out REF.err REF.exit`)

* **`test/m2_gen.py` + `m2_cases.py`** generate ONE neutral program (the common subset of ATS1/ATS2: the compat layers of `d2_gen.py` for the trees, `m2compat_hand.hats` / `m2compat1_hand.hats` for the macro values,
  `m2common.hats`) of 68 scenarios (`M2SCALE=1`, seed `M2SEED=1`), 11 chunks of 17.7k lines, compiled by the ATS2 driver `m2dump.dats` and the ATS1 driver `m2dump1.dats` (`m2dump1.sh`, linked with `src/*.o`: the
  real `pats_dmacro2*_dats.o` and `pats_trans3_error_dats.o`, with `pats_dynexp3_sats.o` and `pats_trans3_sats.o` for the staload functions). Every evaluation is `{ var ctx = .. var env = .. val r = eval0_d2exp (..) .. }`
  and dumps the result with a complete dumper (`dd_m2val`, `dd_d2exp`, ...) and, for a sample, with the printers of the module under test; after each one `t3chk ()` prints whether `the_trans3errlst_finalize` raised.
  Families: `lit` (literals, variables, the 8 token shapes of integers (overflow, hex), unsupported forms), `ops` (the 10 operators on all the pairs of 7 operand kinds, numbers and groups of arguments), `ifs` (ifhead,
  the 5 `macfun`s on lists, errors and nested lists), `syn` (encode/decode/xstage and `dmacro_eval_decode/xstage`), `lift`, `ctx` (evalctx, the printers, `stasub_make_evalctx`), `alph`, `mlong` (identity, sums, the
  recursion of a factorial and of a list sum, static groups, every arity and group-kind error), `mshort` (the short form through `eval0_app_mac_short`, `dmacro_eval_app_short`, `eval1_d2exp`, over-application),
  `eval1`/`eval1b` (every constructor of `d2exp` as input, random trees, binders, clauses, declarations), `order` (the order of the children), `sub` (the static substitution at every position).
  **Result: stdout 11230 lines and stderr 3726 lines (the `prerr` of the evaluator), byte-identical in ATS1 and ATS2** (seeds 1, 2, 3 all identical; `m2dump.md5` keeps the md5 of the ATS1 output of seed 1: `make test`
  checks the ATS2 build without ATS1). The first full run found no bug of the port.
* **The processes that end** (`sh m2exit.sh`; `M2EXIT=1..7`): the five unsupported patterns (`exitloc`) and the two insufficient applications (MatchError): the stdout and the `full: ...` messages of stderr are identical
  and both fail (`m2dump.md5` line 2).
* **Coverage** (`make m2cover`, `python3 m2cover.py --gcov`): 10/10 constructors of `m2val`, 30/30 functions of `pats_dmacro2.sats` called, the 75 arms of `eval1_d2exp/p2at/d2ecl` and all the 127 constructors of
  `d2exp/p2at/d2ecl` used as inputs of `eval1`; gcov by ATS line (`patscc -g --gline --coverage`, the main run and the 7 exit runs): **1448 of 1477 executable lines of the 5 modules (98.0%)**; the rest is the dead code of
  M2-9, impossible arms of `d2exparglst_take/_drop`, the unused arm of `m2val_int_get` and 4 punctuation lines.
* **Mutation test** (`python3 m2mutate.py`, 59 deliberate bugs in the 5 modules: arithmetic and comparison operators, the shadowing and the unwinding of `alphenv`, the context lookup, the lifted values, the order of the
  arguments and of the children, the merge of the argument groups, the arity rules, every kind of message, the substitution of the static variables at each position, the printers, the count of the errors):
  **59/59 detected** (the ones missed at the first attempt added the families `order` and `sub`, `macfun` on error values, and groups of 3 variables / none).
* **AddressSanitizer** (`make m2dump_asan`, leak detection on): the whole main run, no error, no leak; stdout and stderr identical to ATS1.
* Stubs: the ATS2 and ATS1 drivers define the same stubs of `pats_staexp2_util2.dats` (`m2stub_hand.hats`, `m2stub1_hand.hats`, copies of the `d2stub*_hand.hats`; `s2exp_subst` of `util1` calls them) and the generator only
  builds static expressions on which the real `s2exp_hnfize` is the identity (as in D2/S2). Drop the stubs with util2.

### Notes for trans3 and trans2

* Entry points are unchanged: `dmacro_eval_app_short (loc0, d2m, d2as)`, `dmacro_eval_decode (d2e)`, `dmacro_eval_xstage (d2e)`. They return a new `d2exp`; the errors go to stderr and to `the_trans3errlst_add`.
* A user of the macro evaluator needs `pats_trans3_error.dats` (or the real trans3) in the link, and dynloads in this order: `.. dynexp2_util, trans3_error, dmacro2, dmacro2_eval0, dmacro2_eval1, dmacro2_print`
  (`m2val_true/false` are built at dynload).
* trans2 builds the macros: `d2mac_make (loc, name, knd, args, def)` with `knd` 1 = long form (`macdef f (x) = ..` evaluated by `eval0`), 0 = short form (the body is quoted code evaluated by `eval1`; its `,( )` is
  `D2Emacsyn (MSKdecode, ..)`). The body of a recursive macro is set afterwards with `d2mac_set_def`. A short macro applied to fewer groups than it has aborts (M2-5).
* The fields of the error records are the handles of the arena (nothing is copied or freed).

### Open problems (macros)

* `pats_trans3.{sats,spec}` are partial (M2-4); the trans3 port must extend them. Nothing prints the errors of the list in ATS1 either (only the count).
* The tests stub `s2exp_hnfize`/`s2exp2hnf`/`s2explst_syneq` (util2) and so only exercise `s2exp_subst` on trees where the real functions are the identity; rerun `m2compare` after the util2 merge with the stubs dropped.
* `exitloc` and the abort of a MatchError print texts that differ from ATS1's (location of the port's source line / the runtime's message): `m2exit.sh` compares only stdout and the messages of the evaluator.
* The linear `alphenv` / `evalctx` are lists of `datavtype` nodes (one malloc per binding, freed by the evaluator); the m2val values and the d2exp trees built by `eval1` are arena data, never freed.
* `m2dump1.sh` needs `pats_dynexp3_sats.o` and `pats_trans3_sats.o` from the ATS1 build for their `staload` functions; `make -C test m2dump1` takes about 50 s sequentially (`JOBS=8`).

* **2026-10-15, real util2/util3/solve/stacst2 (stubs dropped).** `m2stub_hand.hats`/`m2stub1_hand.hats` are deleted. m2dump/m2dump1 link the real `pats_staexp2_util2/util3`, `pats_stacst2`, `pats_staexp2_solve`
  (ATS1: the objects of `src/`); `m2env2.hats`/`m2env1.hats` are minimal twin test doubles of trans2_env/trans3_env (empty pervasive table, no static-variable bindings, every other function exits with a message:
  the macro test never reaches the solver). `fam_sub` now also substitutes into beta redexes and prints the real `s2exp_hnfize`, `s2exp2hnf`, `s2exp_syneq`, `s2explst_syneq`. Output 11321/3697 lines,
  byte-identical in ATS1/ATS2 for seeds 1,2,3; `m2dump.md5` line 1 REGENERATED from the ATS1 output (m2exit summary unchanged); 59/59 mutations, ASan clean, gcov 1448/1477, no discrepancy.

## Codegen2: pats_codegen2, _util, _datype, _fprint, _absrec (rules CG-1 .. CG-7)

Done (typecheck, link, differential test, see Validation): `pats_codegen2.{sats,dats}` (`d2eclist_codegen_out`, `codegen2_process`) and the generators
`pats_codegen2_{util,datype,fprint,absrec}.dats` (`#codegen2(datcon|datcontag|fprint|absrec, ..)`: they print ATS source to a `FILEref`). 3.0k lines of ATS1,
2.6k of ATS2. Same file and external names as `src/`. `pats_codegen2_util.dats` needs `the_s2expenv_find` and `the_d2expenv_find` of trans2_env: see CG-6.

CG-1. **No data of its own**: everything is read from the level-2 trees (`e1xp_node_view`, `s2exp_node_view`, `s2rt_viewof`, `s2rtbas_view`, `s2itm_view`, `d2itm_view`,
      `glist_view`, `gopt_view`). `val-D2Ccodegen(knd, xs) = ..`, `val-Some(d2cs) = s2cst_get_dconlst(..)`, `val-S2Etyrec ..` are `assertloc(false)` on the other arm (the MatchError).
      Linear options of the lookups (`codegen2_get_*`: `Option_vt`) are rebuilt (`~Some_vt(c) => if test then Some_vt(c) else None_vt()`), not `fold@`-ed.
CG-2. **`fprint!`/`fprintln!`/`overload fprint`** are sequences of explicit calls (`fprint_string`, `fprint_int`, `$LAB.fprint_label`, `$LOC.fprint_location`,
      `fprint_s2cst`, `$S1E.fprint_e1xp`, `$SYM.fprint_symbol`); the text is unchanged (checked by the test). `sprintf("fprint_%s_", ..)` is `string0_append3` + `symbol_make_string` + `strptr_free`.
CG-3. **Local closures** (`:<cloref1>`) are plain nested `fun`s. Pitfall: a function nested in a function nested in a function whose free variable is used only by the innermost
      gets `ATSPMVenv(x)` undeclared in the C code: `absrec_emit_decl` (the `auxdecl` of `absrec_emit_tyrecfld`) was lambda-lifted by hand (explicit `out s2c0 tnm l0`).
CG-4. **`absrecfld`** (a nonlinear datatype with arguments) is the flat pair `@(absrecfldkind, s2exp)` (`absrecfldkind` is an enumeration). The local `s2cst_get_name` of
      `pats_codegen2_absrec.dats` is dropped (same definition as the one of `pats_staexp2.sats`). `case+ 0 of _ when is_get(name)` is an `if` chain, same order.
CG-5. **Kept ATS1 oddities** (the test covers them): `ABSRECFLDexch` prints the function name `exec` (not `exch`); `ftype` of `aux_datype_d2cf_con` is computed and unused; the
      `datcon`/`datcontag` error texts are the same but one ends with `*)\n` and the other `fprintln! "*)"`; `fprint_test_e1xp` etc. accept an identifier or a string.
CG-6. **TEMPORARY files** that the slices of trans2/stacst2 replace (take their versions at the merge, they declare the same names with the same types): `pats_trans2_env.sats`
      (only `the_s2expenv_pervasive_find`, `the_s2expenv_find`, `the_d2expenv_find`), `pats_stacst2.{sats,dats}` (only `s2cstref`, `s2cstref_make`, `s2cstref_get_cst`,
      `the_list_vt0ype_int_vtype`; the cell is the one of the full port: word 0 the symbol, word 1 the constant or null). The test drivers implement the three environment functions
      with a table (`cgenv_def.cats`, kinds 0, 1, 2).
CG-7. **Consumers** (`pats_main`): `d2eclist_codegen_out (out, d2cs)` is the `--codegen2` output; `codegen2_process` is also usable alone.

## Pattern coverage (patcst2): pats_patcst2 (rules PC-1 .. PC-8)

Done: `pats_patcst2.{sats,dats}` + `pats_patcst2.spec` (`p2atcst`: 11 constructors, record `labp2atcst`; the generated `pats_patcst2_gen*.hats` are small and kept in git; `make gen`).
Same names as `src/` (`p2at2cst`, `p2atcst_comp`, `p2atcstlst_comp`, `labp2atcstlst_comp`, `c2lau_pat_any`, `c2lau_pat_comp`, `*_inter_test`, `*_diff`, the printers).

PC-1. **Types.** `p2atcstlst = glist(p2atcst)` (immutable, shared), `p2atcstlst_vt = List0_vt(p2atcst)`, `p2atcstlstlst_vt = List0_vt(p2atcstlst_vt)`, same for `lab`. The
      elements are arena handles (never freed): `list_vt_free (xs)` frees only the cells. Constructors `p2atcst_P2TCcon (d2c, xs)`, match `case+ p2atcst_view (x) of ~P2TCint i => ..`,
      tests `p2atcst_is_P2TCany (x)`. `LABP2ATCST (l, x)` is `labp2atcst_new (l, x)`, `labp2atcst_lab/_elt`.
PC-2. **Borrowed views.** ATS1 passed a linear list where a list was expected with `$UN.castvwtp1{p2atcstlst}(xs)` (the trans3 users do). Here use `p2atcstlst_of_vt (xs)`,
      `labp2atcstlst_of_vt`, `p2atcstlstlst_of_vt` (new, copy the cells into the arena: never freed, avoid them in a hot loop; `p2atcstlstlst_vt_copy` and the `print_*_vt` do not use them).
PC-3. **No recursion on the length of a result.** The complements are products: a `case` on a few columns gives lists of 10^5 entries and the first version (`list_vt_cons (f x, aux xs)`)
      overflowed the 8 MB stack where ATS1 did not. All the builders are loops with an accumulator reversed at the end; `list_vt_append` is `list_vt_reverse_append (list_vt_reverse ..)`;
      the printers and `p2atcstlstlst_vt_copy` walk the outer list as a list of pointers (`p2atcstlstlst_ptrs`: a copy of the cells, the inner lists are borrowed with `castvwtp1`).
      The test runs `cgdump` with a 1 MB stack. `labp2atcst_sort` (the `list_vt_mergesort` of record fields) is a stable insertion sort.
PC-4. **Pairs of constructors** (`inter_test`, `diff`): the wildcard rows first (`P2TCany`), then a match on the first with a nested match on the second, `v => (p2atcst_view_free (v); default)`.
      The order of the ATS1 clauses is kept (which matters only for the last `(_, _)` arm).
PC-5. **Small substitutes**: `=` on `intinf` needs `overload = with $INTINF.eq_intinf_intinf`; `char` and `bool` equality are `eq_char`/`eq_bool`; the suffix of an integer token is cut with
      `my_make_substring` (arena copy, as `pats_filename_reloc.dats`); `P2Tf0loat` uses `token_float_rep`; `fprintf (out, "\"%s\"", ..)` is three calls.
PC-6. **Bug of an earlier slice found by this test: the order of the sets.** `charset` (`pats_utils.dats`) and `intinfset` (`pats_intinf_gmp.hats`, `_int.hats`) were *ascending* glists; the ATS1
      `funset_listord` keeps them *descending* (`listize` and `fprint_*set` give the largest element first, hence the order of `P2TCintc`/`P2TCcharc` complements and of the `[^7, 0]`
      printed in the counter-examples). The three files now keep the lists descending (comments updated); `test_utils`, `test_intinf` still pass.
PC-7. **Errors**: a pattern that `p2at2cst` does not know (`P2Terrpat`, `P2Tlist`..) prints `INTERROR(pats_p2atcst): p2at2cst: p2t0 = ..` on stderr and `assertloc(false)` (ATS1: the
      same message, then its own assertion text): `CG_ERRTEST=n ./cgdump` (cgcmp.sh) compares the exit status, stdout and the INTERROR line.
PC-8. **Needs** `pats_stacst2` (`s2cstref_get_cst (the_list_vt0ype_int_vtype)`, found once through `the_s2expenv_pervasive_find` and cached in the cell: the first list constant found
      is the one that every later `P2Tlst` uses; the test makes it once, `cg_init_universe`), see CG-6.

### Validation (ATS1 reference = the objects of `src/`; `make -C test cgcompare|cgtest|cgcover|cgdump_asan`, `python3 cgmutate.py REF.out REF.err`)

* `test/cg_gen.py` (+ `cg_cases.py`, `cg_pat.py`) generates ONE program of 430 scenarios in 17 chunks (41k lines, seed `CGSEED=1`, `CGSCALE=4`) in the common subset of ATS1 and ATS2,
  built with the wrappers of the level-2 test (`d2compat_gen.hats`) and `cgcompat_gen.hats` (the constructors of `p2atcst`); `cgdump.dats` (ATS2) and `cgdump1.dats` (ATS1, `cgdump1.sh`,
  linked with `src/*.o`) include it. The environment functions are tables (`cgenv_def.cats`); the util2 stubs are those of `d2stub_hand.hats` (not called by these modules).
  Families: `dat` (datcon/datcontag: 1-3 datatypes with 0-6 constructors of 0-4 arguments, proof arguments, qualifiers, tags 0.. / -1 / 100; abstract, empty, non-datatype, duplicate, variable and
  missing names; every form of the argument list), `fprint` (declarations of templates with 0-3 quantifiers of every sort, explicit and default function names, a variable instead of a function),
  `absrec` (records under 1-2 lambdas with get/set/getset/exch/getref/unknown fields, nested tuples/records of every kind, applications, `fprint_s2exp` fallbacks, non-records, undefined types),
  `emit` (sorts, expressions, template declarations), `misc` (name tests, lookups, `d2eclist_codegen_out` with list/local/skipped kinds); patterns: `patcase` (random typed patterns: literals with suffixes,
  lists, records with permuted/omitted/duplicate labels, as-patterns, existentials, annotations, vbox, guards, ill-typed ones) through the loop of `pats_trans3_caseof.dats` (`cg_sim_*`),
  `patcover` (covers of random types in random order, duplicates, a missing clause), `patcst` (constraints built directly: every constructor, sets, records), `patlst`, `patbig` (20000-element sets,
  300 constructors).
  **Result: stdout 181539 lines and stderr 39987 lines, byte-identical** in ATS1 and ATS2 (`cgcompare`; `cgdump.md5` keeps the md5 of the ATS1 output: `make cgtest` checks without ATS1).
* **Coverage** (`make cgcover`, gcov by ATS line, `--gline`): all 21 functions of `pats_codegen2.sats` and all of `pats_patcst2.sats`, 11/11 constructors; lines executed (1985 of 2005, 99.0%): codegen2 60/63,
  util 292/292, datype 157/159, fprint 365/366, absrec 252/255, patcst2 859/870 (the rest: the MatchError arms, the INTERROR path run by `CG_ERRTEST`, the `prerr_FILENAME` template).
* **Mutation test** (`python3 cgmutate.py REF.out REF.err`): 46 deliberate bugs in 8 files (dispatch, keyword tests, sorts, tuple/record text, tags, names, the loops of fprint, the
  fields of absrec, complements, differences, the stable sort of labels, the order of the sets...): **46/46 detected** (one, the stability of the sort of equal labels, first needed duplicate labels with different patterns).
* **AddressSanitizer** (`make cgdump_asan`, leak detection on): the whole run, no error, no leak report, output identical. `make cgtest` (in `make test`) needs no ATS1 (`cgdump.md5`; line 2: `cgerr.sh`).

### Open problems (codegen2, patcst2)

* `pats_trans2_env.sats`, `pats_stacst2.*` are temporary partial files (CG-6).
* `p2atcstlst_of_vt` and friends allocate in the never freed arena (PC-2): a trans3 loop over big complements should keep linear lists and use a borrowed `p2atcstlst` only per element.
* The stdout of the codegen text is compared, not compiled as ATS.

### Note 2026-10-15 (cg suite on the real modules)

The cg suite no longer uses stand-ins: `d2stub_hand.hats`/`d2stub1_hand.hats` are not included, `pats_staexp2_util2/util3/solve` and `pats_stacst2` are the real modules on both sides
(ATS2 `CGMODS` = `D2MODS` (which has `S2MODS`) + the cg modules; ATS1 `cgdump1.sh` links the ATS1-built `util2/util3/solve` objects). The only doubles left are the ones of the modules
not ported yet: `cgenv2.hats` / `cgenv1.hats` (recorders `trans3_env_*`, `s2exp_hnfize_flag_svar` with an empty binding table, `s2var_occurcheck_s2exp`, `s2exp_*_instantiate_all`,
`s2hnf_*_and_add`), and the `the_s2expenv_find`/`the_d2expenv_find`/`the_s2expenv_pervasive_find` tables of the drivers. `cgdump.md5` regenerated from the ATS1 output: unchanged.
Results: cgcompare byte-identical (stdout 181539, stderr 39987 lines; errtests 1-3 same), coverage 1985/2005, mutations 46/46, ASan clean, `make cgtest` passes; `test_utils`, `test_intinf` pass.

## Level 3 trees (dynexp3): pats_dynexp3, _print (rules D3-1 .. D3-7)

Done (typecheck, link, differential test, see "Validation" of the next section): `pats_dynexp3.{sats,dats}` (+ `pats_dynexp3.spec`, generated `pats_dynexp3_gen*.hats`, not in git) and
`pats_dynexp3_print.dats`: the level-3 trees `p3at`, `d3exp`, `d3ecl`, `d3lab`, `i3fcl`, `gm3at`, `c3lau`, `sc3lau`, `i3mpdec`, `f3undec`, `v3aldec`, `v3ardec`, `prv3ardec`, 114 constructors
and 13 records (19 of `p3at_node`, 21 of `d3ecl_node`, 72 of `d3exp_node`, 2 of `d3lab_node`; the 27 constructors of the constraints are in the next section). 3.5k lines of ATS1, 2.8k of ATS2 + 3.5k generated.
Same names as `src/`; the printers keep the ATS1 text.

D3-1. **Arena AST, as dynexp2** (D2-1): the node types are datatypes (`d3exp_node_D3Ecst (c)`, `case+ d3exp_node_view (e.d3exp_node ()) of ~D3Ecst c => ..`, `d3exp_node_is_D3Ecst`), the rest
      records (`d3exp_new (loc, type, node)`, `e.d3exp_loc ()`). The record/node split of ATS1 is kept (`d3exp_make_node`-style smart constructors `d3exp_xxx (loc, s2f, ..)` have the ATS1 names and argument
      orders; `p3at_make_node`, `d3ecl_make_node` too). The one-constructor datatypes are records: `labp3at (labp3at_lab, labp3at_elt)` (ATS1 `LABP3AT (l, p3t)`), `labd3exp (labd3exp_lab: l0ab, labd3exp_elt)`
      (ATS1 `dl0abeled (d3exp)`, like `labd2exp`).
D3-2. **Mutable fields** (ATS1: C functions `patsopt_p3at_set_type`, ..): `p3at_type`, `p3at_dvaropt`, `p3at_type_left`, `d3exp_type`, `d3lab_overld_app` are `mut` fields; the ATS1 API (`p3at_set_type`, `d3exp_set_type`,
      `d3lab_set_overld_app`, ..) is a thin layer over `set_p3at_type` etc. and keeps the C names (`ext#patsopt_p3at_set_type`).
D3-3. **The index of `c3lau (n)` / `c3laulst (n)` is dropped** (`c3lau_pat: p3atlst`; `c3lau_make (loc, p3ts: p3atlst, gua, seq, neg, body)`); `c3laulst_vt = List0_vt (c3lau)`. A user that matched `list (p3at, n)` with
      lengths in ATS1 compares `glist_length`s at run time. `d2cst`/`d2var` are the records of dynexp2 (the ATS1 `typedef d2cst = d2cst_type` lines are gone).
D3-4. **There is no `hisexp` in the ATS1 `pats_dynexp3.sats`**: nothing in this slice uses the placeholders of dynexp2 (`dynexp2_hisexp_type`, `dynexp2_funlab_type`, `d3eclist`, `tmpcstimpmap`); they stay placeholders until `pats_hidynexp` is
      ported (it must `$UN.cast` them). `pats_dynexp3.sats` defines the real `d3eclist = glist (d3ecl)` and `d3eclistopt` (the name `d3eclist` does not clash with the placeholder `dynexp2_d3eclist_type`).
D3-5. **Printers**: `fprintf` is a sequence of `fprint_*` (the text is unchanged: `D3Eeffmask` prints `D3Eraise(`, `P3Terrpat` prints `P3Terr()`, `D3Elet`/`D3Erec`/.. print `(...)`), `$UT.fprintlst<p3at>`; every
      `case+` is exhaustive (no wildcard arm); the wildcard arms of `pats_dynexp3.dats` free the view (`| v => (p3at_node_view_free (v); false)`).
D3-6. **`d3exp_con`** (`aux1`/`aux2`): a list of arguments with a `D3Etop` makes the type `s2exp_datcontyp (d2c, [topized types])`; `list_exists_fun`/`list_map_fun` are loops in the same order. `d3exp_app_unista` returns `d3e`
      unless the type of `d3e` is `S2Euni`/`S2Emetfun` (a wildcard arm on a view: freed).
D3-7. **Generated files and the build**: `make -C src2 check` makes `pats_dynexp3_gen*.hats` (`D3SPECS` in `src2/Makefile`, appended) and typechecks the 2 modules; only `pats_dynexp3.dats` includes `pats_dynexp3_gen_dats.hats`.
      `pats_trans3_error.dats` staloads `pats_dynexp3.sats` (the errors carry `p3at`/`d3exp`).

## Type-checking environment (trans3_env): pats_trans3_env{,_dvar,_effect,_lamlp,_lstate,_pfman,_print,_scst,_svar,_termet} (rules E3-1 .. E3-12)

Done (typecheck, link, differential test, see Validation): `pats_trans3_env.{sats,dats}` (the partial sats of the util2 slice is EXTENDED: every name and every signature of the old file is kept) and the nine modules of the
title, + `pats_trans3_env.hats` (helpers), `pats_trans3_env.spec` (the constraints) and four private specs/sats (`_effect`, `_pfman`, `_dvar`, `_lstate`). ATS1: 7.0k lines (with the sats), ATS2: 6.5k lines (with the private sats and the hats).
`pats_trans3.spec`/`pats_trans3.sats` (the partial files of the macro slice) are EXTENDED: ALL 102 constructors of `trans3err` (`trans3err_T3E_xxx (..)`, `trans3err_view`) and `d2var_get_type_some` (declared, implemented by
the trans3 port proper) are there. The `pats_trans3.sats` functions of the translation proper (`p2at_trup`, `d2exp_trup`, ..) are NOT: they belong to the trans3 port.

E3-1. **The proofs are gone** (T1-5): `trans3_env_push (): void`, `trans3_env_pop (): s3itmlst_vt`, `trans3_env_pop_and_add (loc, knd)`, `_pop_and_add_main (loc)`, `the_s2varbindmap_push/pop`, `the_s2cstbindlst_push/pop/pop_and_unbind`,
      `termetenv_push/push_dvarlst/pop`, `the_effenv_push/_lam/_set/_effmask/pop`, `the_d2varenv_push_lam/let/try/pop`, `the_lamlpenv_push_lam/loop0/loop1/pop`, `the_pfmanenv_push_let/lam/try/pop`. The `option_v` of
      `the_effenv_push_set_if (test, efs)` / `the_effenv_pop_if (test)` is the `bool` `test` itself (call `pop_if` with the same test). A pop on an empty stack does nothing, as in ATS1 (except `the_lamlpenv_pop`: `assertloc`, the
      MatchError). The tuples of the results are flat: `@(s2exp, s2explst_vt)`, `@(s2exp, t2mpmarglst)`, `@(bool, s2exp, wths2explst)`; `s2exp_metfun_load` is `Option_vt @(s2exp, s2rtlst)`.
E3-2. **The state is in cells of the global arena** (`gcell_make/get/set` of `pats_trans3_env.hats`); a stack is an immutable `glist` that the cell replaces (the ATS1 linear lists, `ref (list_vt)`). The items of the scope are kept
      newest first (`fprint_the_s3itmlst` prints them in that order, as ATS1 printed its list) and `trans3_env_pop` reverses them. The linear `s2varbindmap` and `d2varset_vt` are persistent (S2-3, D2-5) and are kept as a `ptr` in a cell
      (`$UN.castvwtp0` out, back in after the operation): a function of the environment that is re-entered through itself while it holds the map would lose the update (none does).
E3-3. **The constraints** are generated (`pats_trans3_env.spec`, `--global --compact`): `c3nstrkind`, `s3itm`, `c3nstr_node`, `h3ypo_node` (datatypes: `c3nstrkind_C3TKmain ()`, `case+ s3itm_view (x) of ~S3ITMsvar v => ..`), the records `c3nstr`,
      `h3ypo`, `lstbefitm`, `c3nstroptref` and `lamlp` (a datatype). `s3itmlst = glist (s3itm)`, `s3itmlstlst`, `lstbefitmlst`, `c3nstropt = gopt (c3nstr)`; `s3itmlst_vt = List0_vt (s3itm)` is only what `trans3_env_pop` returns. The ATS1
      `ref (c3nstropt)` of `c3nstroptref` is the `mut` field `c3nstroptref_val` (`ctr.c3nstroptref_val ()`, `set_c3nstroptref_val (ctr, opt)`, like `d2varlstref`); its location is `c3nstroptref_loc`. `C3TKcase_exhaustiveness (casknd, p2atcstlst)` holds a
      COPY of the linear list (`p2atcstlst_of_vt`, PC-2). The `p2atcst` that `hypadd_patcst` reads are matched through the views (`p2atcst_view`), the lists of constraints `glist_listize`d (the linear lists are consumed, as ATS1).
E3-4. **Private types**: the stacks of `_effect` (`effenvitm`: eff / effmask / mark, one item per cell of the ATS1 list incl. the marks), `_pfman` (`d2vmrk` record: variable or mark), `_dvar` (`ld2vsfrm`: a set or a lambda marker, a
      record with a `mut` list: `the_d2varenv_d2var_is_llamlocal` pushes the variable into the list of the lambda frames it crosses, in place, as ATS1 did) and `_lstate` (`lstaftitm`, `lstaftc3nstr_rec`, `mut` fields) have their own spec and a private
      `.sats` (`pats_trans3_env_X.sats`, `#include` of the generated hats), and only their own `.dats` includes the generated dats. `lstaftc3nstr` of the sats is `absvtype .. = ptr` (a handle of an arena record; `finalize` asserts, as the
      `val-list_vt_nil` of ATS1, that the constraints were processed).
E3-5. **What the environment needs from the other slices** (declared, implemented elsewhere; the test drivers have doubles): `trans3_env_d2con_instantiate (loc, d2c): @(s2qualst, s2exp)` (pats_trans2_p1at.dats: `implement trans3_env_d2con_instantiate (loc, d2c) =
      d2con_instantiate (loc, d2c)`), `filenv_get_d3eclistopt (fenv)` (declared in `pats_trans3_env.sats` as in ATS1, but the field `decl3` of the file environment belongs to `pats_trans2_env`: implement it there), `d2var_get_type_some (loc, d2v)`
      (pats_trans3_dynexp_up.dats). `s2exp_hnfize_flag_svar` (util sats) is implemented in `pats_trans3_env.dats` (S2B-6): it reads `the_s2varbindmap`.
E3-6. **Closures** of ATS1 are named functions with the free variables as arguments (`exiuni_loop (knd, locarg, sub, ..)`, `unisexp_loop`, `tmp_instantiate_auxsome`, `hypadd_patcst_*loop`, `check_set_auxcheck (loc0, efs00, ..)`..); `list_mergesort` of
      `hypadd_labpatcstlst` is a stable insertion sort (ATS1's sort is stable too: the test has records with a repeated label). The `prerrln!`/`println!` of the errors are explicit `prerr_*` calls with the same text.
E3-7. **ATS1 oddities kept** (the test covers them): `s2exp_unimet_instantiate_all` of a `S2Emetfun` without stamp returns the BODY of the metfun (the pattern variable `s2e` shadows the whole); `auxerr_none` of the merge of the linear state records `T3E_d2var_some`;
      the error of `the_effenv_check_set` is printed at EVERY `eff` frame that the failure crosses (and by the hard marks), with the outer set in the `trans3err`; `T3E_s2varlst_instantiate_napp` for an overdone template instantiation; the `exit (1)` of `the_d2varenv_check_llam`
      (`$extfcall (void, "exit", 1)`); `lstaftitmlst_reverse` (dead code, as ATS1).
E3-8. **Keyword**: `rec` is reserved in ATS2 (`val rec = ..` does not parse). `case+ (s2e1.node, s2e2.node) of (_, _) =>` with a single arm (`trans3_env_hypadd_eqeq`) is its body.
E3-9. **Linking**: the modules instantiate the arena templates (`staload _ = "libats/DATS/arena.dats"` in each `.dats`, rule 16), `pats_error.dats` (`abort_interr<d2var>` in `_dvar`), `pats_utils.dats` (`fprintlst`), `pats_errmsg.dats`.
      Dynload order: `.. util1, util2, util3, stacst2, solve, namespace, dynexp1(_print), dynexp2*, patcst2, trans3_error, dynexp3, dynexp3_print, trans3_env, _svar, _scst, _termet, _effect, _lamlp, _print, _pfman, _dvar, _lstate`
      (the cells are made when the module is dynloaded, after the arena and `pats_staexp2` (`s2Varset_nil ()`) and `pats_dynexp2_dvar` (`d2varset_vt_nil ()`)).
E3-10. **`the_trans3_env_initialize`** needs the pervasive constants of `pats_stacst2` (the 16 names of the 8 `s2cst_add_sup` pairs) in `the_s2expenv_pervasive_find`.
E3-11. **Not covered because they end the process** (as in ATS1): `funarg_d2vfin_check` without a funarg, `the_d2varenv_check_llam` of a linear variable, `d2var_search`.. none of the other branches.
E3-12. **Interface notes for the next slices**: `hidynexp`/`typerase` read `p3at`/`d3exp`/`d3ecl` through `*_node_view` and `*_is_*` (D3-1); the `d3exp_type` is mutable (`d3exp_set_type`). `constraint3` reads `c3nstr`/`s3itm`/`h3ypo` with
      `c3nstr_node_view (c.c3nstr_node ())`, `c.c3nstr_kind ()`, `c.c3nstr_loc ()`, and the `c3nstroptref` through `c3nstroptref_val`; `the_trans3_finget_constraint ()` returns the whole constraint. `trans3` calls `trans3_env_push ()` and
      `trans3_env_pop_and_add (loc, knd)` / `_main`, `the_effenv_push_set_if (test, efs)` / `the_effenv_pop_if (test)` with the same `test`, and must provide `d2var_get_type_some`.

### Validation (ATS1 reference = the objects of `src/`; `SRC=<main tree>/src make -C test t3compare`, `make -C test t3test|t3dump_asan`, `sh t3gcov.sh`, `python3 t3cover.py`, `python3 t3mutate.py REF.out REF.err`)

* **`test/t3_gen.py` + `t3_cases.py`** generate, from the specs of staexp2, dynexp2, dynexp3 and trans3_env (the machinery of `d2_gen.py`/`d2_cases.py`: wrappers `K_<CON>` and complete dumpers `dd_<T>` of EVERY type, incl. the 19 records), ONE neutral
  program of 106 scenarios (`T3SCALE=3`, seed `T3SEED=1`; 18 chunks, 31k lines) that is compiled by the ATS2 driver `t3dump.dats` and the ATS1 driver `t3dump1.dats` (`t3dump1.sh`, linked with `$SRC/*.o`: `SRC=<main tree>/src`, ATS1 environment as
  for `d2dump1.sh`). The 31 functions of ATS1 that have proofs (`trans3_env_push`, ..) are called through wrappers `t_xxx` (`t3hand.tmpl`: the proofs are axioms on the ATS1 side); the test doubles (`t3env.tmpl`) are the table of the pervasive
  environment, `d2con_instantiate` (the quantifiers of the type of the constructor are taken off) and `d2var_get_type_some`. Families: `setup` (the 118 pervasive constants, `stacst2_initialize`, `the_trans3_env_initialize` and the sup relations),
  `tree` (EVERY maker of `pats_dynexp3.sats`, parsed from the sats, with random arguments; every constructor of the four node types through `K_`; getters/setters/predicates; `d3exp_con` with tops; the three printers of `p3at`, `d3exp`, `d3ecl`), `cnstr`
  (the makers and printers of the constraints, hypotheses, items, `c3nstroptref`, `lstbefitm`, `lamlp`), `inst` (every `instantiate` function on quantified types, errors of sorts and arities, metrics), `scope` (random sequences of push/pop/add/hypadd/bind/
  solver/disjunction operations, the dump of the items after each step, `the_s2varbindmap_*`, the occurrence check, the final constraint), `pat` (`hypadd_patcst` for every kind of constraint against matching and non-matching types, constructors with a function
  type, records, sets of integers and characters, lists of the wrong arity, `add_patcstlstlst_false`), `termet` (the metric stack, `s2exp_metfun_load`, the bound static constants), `effect` (random sequences of the effect stack: pushes of every kind, checks of every kind,
  failures through hard/soft marks), `dvar` (the variable scopes, llam, save/restore of the linear state, the finalization checks of every `d2vfin`), `mut` (`d2var_mutablize`), `state` (`lstaftc3nstr` with several branches, merges of types with
  the variables of the invariant, `i2nvresstate_update`), `pf` (`lamlpenv`, the proof manager, `pfobj_search_atview` on at-views, tuples and nested views, `s2exp_wthtype_instantiate`, `funarg_d2vfin_check`), `open` (`s2hnf_absuni/opnexi/opn1exi_and_add`,
  `d3exp_open_and_add`, `un_s2exp_wthtype`, `s2fun_opninv_and_add`), `corner` (static arguments in sequence, every form of the occurrence check through the bindings, a constructor with quantifiers, every shape of `p3at` in the variable environments,
  the repeated label, links of existential variables, pops of the empty stacks).
  **Result: stdout 15038 lines and stderr 2131 lines, byte-identical in ATS1 and ATS2** (seeds 1, 2, 3 all identical; also under `T3SCALE=6`); `t3dump.md5` keeps the md5 of the ATS1 output of seed 1: `make t3test` checks the ATS2 build without ATS1.
  The first runs found one real bug of the port: `s2exp_unimet_instantiate_all` returned the whole type for a metfun without stamp (E3-7).
* **Coverage** (`python3 t3cover.py`, `sh t3gcov.sh`): 141/141 constructors and 19/19 records built (`K_`); of the functions declared in the two sats and implemented by the ATS1 sources, 150/150 of `pats_dynexp3.sats` and 159/160 of `pats_trans3_env.sats`
  are called (the other, `filenv_get_d3eclistopt`, belongs to trans2_env); gcov by ATS line (`patsopt --gline`, `-O0 --coverage`): dynexp3 563/563, dynexp3_print 518/518, trans3_env 1100/1101, _svar 73/73, _scst 56/56, _termet 134/136, _effect 194/194, _lamlp 42/42,
  _print 124/124, _pfman 247/247, _dvar 482/506, _lstate 350/359: **4483 of 4527 executable lines (99.0%)**; the rest: the paths that end the process (E3-11), the dead `lstaftitmlst_reverse`, the unreachable `nil` arm of the second of two parallel lists, and header lines.
* **Mutation test** (`python3 t3mutate.py`, 61 deliberate bugs in the 12 modules: the kinds of patterns, the labels, the topization, the order of the scope items, the kinds of the constraints, every sign and comparison of the checks of effects and of the linear state, the
  marks, the lambda frames, the merge kinds and substitutions, the proof manager's stops, the search of at-views, the sorts of the metrics, the sup relations, the printers): **61/61 detected** (the first run missed 5: the stability of the sort of labels, the sup relations, the
  merge kinds 1/2 and the substitution of the invariant variables; each made me add a family or a corner to the cases, and one mutation that is equivalent in an arena without frees was replaced).
* **AddressSanitizer** (`make t3dump_asan`, leak detection on): the whole run, no error, no leak report, same stdout/stderr.

### Open problems (dynexp3, trans3_env)

* `the_s2varbindmap` and `the_d2varenv` keep a persistent map/set that is taken out of its cell and put back around each operation (E3-2): not re-entrant (no ATS1 caller is).
* The generated hats of `pats_dynexp3.spec` are 3.5k lines (`D3SPECS`); `make -C test t3dump` takes ~1 min with `-j8`, `t3dump1.sh` ~1 min.
* `d3exp_node_view` & co. are a malloc/free per match (rule 3); `pats_trans3_env_print` and the traversals of the items allocate views per node (fine for the sizes of a constraint, not measured on a real program yet).
* The tests double `d2con_instantiate` (no trans2) and run with a stub `filenv`; `trans3_env_d2con_instantiate`/`filenv_get_d3eclistopt` must be implemented by trans2 (E3-5).
* The cases need ATS1 only for `t3dump1` (SRC= the ATS1-built `src/` of the main tree: `*.o` objects, ATS1 sources); `make test` of `src2/test` runs `t3test` (appended to `all:`).
* `make -C test m2test`, `cgtest`, `d2test` do not link on the `selfhost` branch (the stubs of `pats_staexp2_util2.dats` of `d2stub_hand.hats`/`m2stub_hand.hats` clash with the real util2 of `S2MODS`): this was so before this slice (found while checking that the
  extension of `pats_trans3.sats`/`pats_trans3_env.sats` did not break the other tests: `make check`, `s2test` pass).

## Level 2 translation (trans2): pats_trans2*, pats_dyncst2 (rules T2-1 .. T2-14)

Done (typecheck, link, whole-file differential test, see Validation): `pats_trans2.sats` (+ `pats_trans2.spec`, generated `pats_trans2_gen*.hats`, not in git: `trans2err`),
`pats_trans2.hats` (helpers), `pats_trans2_env.{sats,dats}` (the whole symbol environment; the partial sats of the earlier slices is extended, not replaced), `pats_trans2_error`, `_sort`,
`_staexp`, `_p1at`, `_dynexp`, `_impdec`, `_decl`, `pats_dyncst2.{sats,dats}`. About 12.3k lines of ATS1, 11.4k of ATS2. Same file and function names as `src/`.

T2-1. **Method.** `utils/arenagen/port_ats1.py` made the first drafts (specs: syntax, staexp1, dynexp1, staexp2, dynexp2, trans1, staexp2_error, trans2), then by hand; the usual rules of the earlier
      levels apply (`case+ x_view (..) of ~Con ..`, a wildcard arm frees the view: `| v => (X_view_free (v); ..)`, `list_map_fun` is `glist_map_fun<a,b>`, `list_length` is `glist_length`, `None ()`
      is `gopt_none ()`, `l2l` is `glist_make_list_vt`). A guard (`_ when ..`), a match of a pair of lists or `val-list_cons (x, _) = xs` is an `if` chain / nested `case` / `glist_head_exn`.
T2-2. **Environments** (`pats_trans2_env.dats`): `the_s2rtenv`, `the_s2expenv`, `the_d2expenv` are never freed `symenv`s kept as pointers (`$UN.ptr0_vtake{symenv(..)}`, as the e1xpenv of trans1);
      the counters (`the_maclev`, `the_macdeflev`, `the_tmplev`, `the_d2varlev`, `the_staload_level`, `the_trans2_env_flag`) are cells of the arena. **The proofs are gone** (T1-5):
      `the_trans2_env_push ()`, `_pop ()`, `_save ()`, `_restore (): @(s2temap, s2itmmap, d2itmmap)`, `_localjoin ()`, `the_d2varlev_inc/dec ()`, `the_staload_level_push/pop ()`,
      `the_s2expenv_push_nil ()`/`_pop (): s2itmmap` (same for s2rt and d2exp), `the_trans2_env_pervasive_joinwth1 (fil, d2cs)`. The queries `the_X_find`, `the_X_find_qua`, `the_X_pervasive_find`,
      `the_d2expenv_current_find` return `Option_vt`. `the_s2expenv_find_namespace` & co. call `the_namespace_search<a> (env, f)` with the symbol in `env` and a plain function.
T2-3. **`filenv`** is an 8-word block of the global arena (name, sort, sexp, dexp, decl2, decl3, tcimap, tvdmap), `assume filenv_type = ptr`. `filenv_make (fil, m0, m1, m2, d2cs)` stores the three linear
      maps as pointers (never freed). `filenv_get_s2temap/s2itmmap/d2itmmap` return the ADDRESS of the word that holds the map (borrow it with `$UN.ptr0_vtake{symmap(..)}`), the
      `filenv_getref_d3eclistopt/tmpcstimpmap/tmpvardecmap` the address of the word that holds the option (null = None: trans3/typerase store their own values there), `filenv_get_d2eclist`/`_name` read the words.
T2-4. **Closures are lambda-lifted** (the `:<cloref1>` of a local function that is called directly is dropped); `list_fold_left_fun`, `list_app_fun`, `list_filter_fun`, `list_map2_fun`, `list_concat`, `list_extend`
      are the templates/functions of `pats_trans2.hats` (`glist_app_fun`, `glist_filter_fun`, `glist_concat`, ..., all head first like the ATS1 ones: the order of the errors and of the stamps is kept) or small loops.
T2-5. **`List_vt` arguments** are `&List0_vt (T) >> List0_vt (T)` when the callee pushes; a `var xs` that is passed on in every arm is first moved (`val xs = xs`), and the `val+ ~list_vt_cons (x, xs) = xs` of a
      `List0_vt` is a helper with an `abort_interr` arm (`locs1explst_uncons`). The ATS1 boxed tuples are flat: `locs1explst = @(location, s1explst)`, the result of `s1vararg_bind_svarlst`
      and of `aux_imparg` are `@(..)`. `fcopt` stays the linear `Option_vt (funclo)` (`Some_vt`/`None_vt`).
T2-6. **`s1taload_tr` returns `@(filenv, loaded)`** instead of a `&int? >> int` argument (the merge of the uninitialised variable over the two arms of the lookup is refused).
T2-7. **A sort is stable**: `sc2laulst_coverck` sorts the clauses by the tag with the ATS1 `list_vt_mergesort` (stable merge sort, `cmp <= 0` first); `sc2laulst_insert` (stable insertion) gives the same list.
T2-8. **Kept ATS1 oddities** (the test covers them): `d1atdeclst_tr` translates the data declarations in the REVERSE order of the declaration (the accumulator `res := (x, res)` is consumed from the head),
      `D1Cfundecs` of a `fnx` template warns and is a `fun`, the check "nonlinear heap allocation" of `d1atdec_tr` (CLAUDE.md, no GC) is part of the ATS1 source and is ported.
T2-9. **`trans2err`** is generated (`pats_trans2.spec`: the second `T2E_sc2laulst_coverck_sort` of the ATS1 datatype is dropped; `S1Ed2ctype` is the pointer placeholder of staexp1): `trans2err_T2E_s1rt_tr (s1t)`, `the_trans2errlst_add`, `the_trans2errlst_finalize`
      (prints `patsopt(TRANS2): there are [n] errors in total.` and raises `PATSOPT_TRANS2_EXN`).
T2-10. **Dependences on trans3_env** (to be provided by its port, not by this slice): `s2exp_hnfize_flag_svar` (declared in `pats_staexp2_util.sats`; during the level 2 the `the_s2varbindmap` is empty, so it returns its argument),
      and `s2exp_tmp_instantiate_tmpmarglst (s2f, locarg, s2qs, t2mas, &err): @(s2exp, t2mpmarglst)` with the C name `ext#patsopt_s2exp_tmp_instantiate_tmpmarglst` (used by `S1Ed2ctype_tr`, i.e. `$d2ctype`; the
      return value is a FLAT tuple). `test/t2dump_tmp.hats` is a test double of the latter (a port of the ATS1 function without the trans3 error list), `s2exp_hnfize_flag_svar` is a one-line double in `t2dump.dats`.
T2-11. **Not in this slice**: `stacst2_initialize ()` is called by the driver after `prelude/macrodef.sats` (as `the_prelude_load` of `pats_main.dats`); `the_prelude_load`, `pervasive_load` are not ported (the driver `t2dump.dats`
      has them, line for line). `the_trans2_env_initialize ()` must be called once before them (it fills the predefined sorts).
T2-12. **`pats_dyncst2`**: `d2cstref` is a two-word arena cell (symbol, constant or null), as `s2cstref`; `the_sizeof_vt0ype_size` has the C name `ext#patsopt_the_sizeof_vt0ype_size`.
T2-13. **Template instances need the implementation in scope**: each `.dats` has `staload _ = "./pats_utils.dats"` (`lstord_*`) and `staload _ = "./pats_error.dats"` (`abort_interr<T>`, in `pats_trans2.hats`).
T2-14. **Dynload order**: `.. staexp2*, namespace, dynexp1(_print), dynexp2, dyncst2, dynexp2_{dcst,dmac,dvar,print,util}, trans2_env, trans2_error, trans2_sort, trans2_staexp, trans2_p1at, trans2_dynexp, trans2_impdec, trans2_decl`
      (`test/t2dump.dats`).

### Validation (ATS1 reference = the objects of `src/`, every one of them but `pats_main`; `make -C test t2files|t2compare|t2test|t2dump_asan`, `sh t2gcov.sh`, `python3 t2mutate.py LIST`)

* **Driver** `test/t2dump.dats` (ATS2) / `test/t2dump1.dats` (ATS1, built by `t2dump1.sh` against `../../src/*.o`) / `test/t2dump.cats` (shared C): it does what `pats_main.dats` does for `patsopt -s/-d file`
  up to level 2: `the_trans1_env_initialize`, `the_trans2_env_initialize`, `the_prelude_load` (the fixity file, the 39 files of the prelude with `pervasive_load`, `stacst2_initialize`; the REAL pervasive loading),
  then for each file `parse_from_givename_toplevel`, `d0eclist_tr_errck`, `trans1_finalize`, `d1eclist_tr_errck` (RAW: `d1eclist_tr`, the errors are counted after the dump) inside a push of the trans1 and trans2
  environments, and the COMPLETE dump of the `d2eclist`. Input lines `KIND<TAB>path` (`FILEsta/FILEdyn/RAWsta/RAWdyn`), restarted after a fatal exception by `d1chunk.sh` as for trans1.
* **The dumper** is generated (`test/t2_gen.py`, from `pats_staexp2.spec` and `pats_dynexp2.spec` through `d2_gen.py`) for ATS1 and ATS2: every constructor and field of every `s2*`/`d2*` type, and the CELLS
  (`s2cst s2var s2Var s2rtdat s2hole d2con d2cst d2var d2mac`: all the fields through the getters, the mutable ones at the time of the dump, stamps) in full the first time they are met and as `NAME#STAMP` afterwards
  (the structure is cyclic); the `filenv` of a staload is dumped (with its `d2eclist`) the first time its file is met. So the dump checks the trees, the mutable state of the cells and the ORDER of the stamps.
* **Whole files**: `make t2files`: the 2934 `.sats/.dats/.hats` of the repository (links followed; 2678 of them under prelude, libats, src, src2, doc/EXAMPLE, contrib) in the modes FILE and RAW = 5868 translations, chunks of 40 per process:
  8.9 GB of dump (4410 complete trees, 1718 runs end in an exception: ATS1 sources, files with errors, missing files) and 82801 lines of errors on stderr: **identical** (stdout and stderr, chunk by chunk). The first run
  found 97 differing chunks: all of them were the missing `$d2ctype` instantiation (T2-10); the rest of the port was right at the first run.
* **Hand-written cases** `test/t2cases/` (22 files, modes FILE and RAW, `t2cases.md5`, `make t2test` needs no ATS1; `make t2compare` compares with ATS1): sorts (`sortdef`, `stadef`, `stacst`, `datasort`, errors), abstract types and `assume/reassume`, every data
  declaration and exceptions, `staload` with namespaces/opens/qualifiers/missing files, `overload/symintr/symelim` (priorities, errors), templates and `implement` (every arity error), `extern`, `local`, macros (both forms, level errors),
  all the dynamic expressions, patterns, function declarations, `scase/sif/ifcase/for/while/try`, `$d2ctype`, and the error paths of each. Identical in both builds.
* **Coverage** (`sh t2gcov.sh LIST`, gcov by ATS line): the 44 hand-written translations plus every third file of the repository (1970 translations): `pats_trans2_env` 85.2%, `_error` 100%, `_sort` 75.6%, `_staexp` 80.7%, `_p1at` 82.6%, `_dynexp` 86.3%, `_impdec` 79.5%, `_decl` 87.2% of the executable lines (`pats_dyncst2` 17%: the translation does not use `d2cstref`, trans3 does). The rest is mostly the abort arms, `$d2ctype` variants and rare error messages.
* **Mutation test** (`python3 t2mutate.py LIST`, 24 deliberate bugs: initial levels, the filter of `D2ITMvar` in a namespace, `S2ITMcst` accumulation, a message, the proof flag of arrows, the sign of a count, the arity of
  `datconptr`, the selection of constructors, the function level, the stability of the sort of clauses, the kind of a selection, the clause arity test, the order of overloads, the tags of constructors, list-like datatypes, the
  `loaded` flag, recursion of function groups, the definition of an implemented constant, the linearity check, `macdef` kinds, the sort of `datdef`, the namespace pop, the order of a sort comparison, the result sort of `stacst`;
  1030 translations): **24/24 detected** (3 to 35 of the 35 chunks of 30 files differ; the first run used a copy of src2 rebuilt from scratch, the C names contain the path of the source).
* **AddressSanitizer** (`make t2dump_asan`, leaks on): 1970 translations of every third file: no error; the leak reports (about 40 processes, all ending in an exception) are the linear accumulators of `glist_map_loop` on
  the path of the exception (118 reports in trans1, 3 in trans2), as in the level 1.
* **Speed** (`make t2dump_o2`, files without errors in one process, mode `time`): 703 files without errors of prelude, libats, src2 and doc/EXAMPLE in one process (parse + trans1 + trans2, prelude load included, no dump): ATS2 `-O2` 1.87 s (max RSS 742 MB), ATS1 (`-O2` objects of `src/`) 2.03 s (944 MB); ATS2 without `-O` 11.6 s.

### Notes for trans3, typerase and the driver

* The result of the translation is a `d2eclist`; `d1eclist_tr_errck` raises `PATSOPT_TRANS2_EXN` after printing the errors. A driver must `the_trans2_env_initialize ()` once, load the prelude (`the_prelude_load`: fixity, `pervasive_load` of the files, with `the_trans1_env_push/pop`, `the_trans2_env_push`,
  `the_trans2_env_pervasive_joinwth1 (filename, d2cs)`, `$GLOB.the_PACKNAME_set_name "ATSLIB.prelude"`, `the_EXTERN_PREFIX_set "atspre_"` around each file; `stacst2_initialize ()` after `macrodef.sats`) and call `d1eclist_tr_errck` for the main file after `trans1_finalize ()`.
* The environment functions have no proofs (T2-2); `filenv_get_s2temap` & co. return addresses (T2-3); `the_d2varlev_inc/dec` are unpaired calls.
* trans3/typerase must provide the two functions of T2-10 and, for `$d2ctype`, a trans3 error list that `S1Ed2ctype_tr` does not use.

### Open problems (level 2 translation)

* The accumulator of `glist_map_loop` (and the linear lists of `s1qualst_tr`, ..) is not freed when an exception leaves the translation (as in trans1).
* The match on a `d2itm`/`s2itm`/`d1exp_node` is a malloc/free (rule 3); the translation of a whole prelude is as fast as ATS1 at `-O2`.
* `s2cst_get_arylst`/`_iscpy` (S2-13) are not dumped (ATS1 does not implement them).
* The `filenv` maps are not dumped (their content is checked through the translations that use them).

## Erased trees (hidynexp): pats_hidynexp, _print, _util (rules HD-1 .. HD-8)

Done (typecheck, link, differential test, see "Validation (hidynexp, typerase)"): `pats_hidynexp.{sats,dats}` (+ `pats_hidynexp.spec`, generated `pats_hidynexp_gen*.hats`, not in git),
`pats_hidynexp_print.dats`, `pats_hidynexp_util.dats`: the trees of the erased program `hipat`, `hidexp`, `hidecl`, `hilab`, `higmat`, `hiclau`, `hifundec`, `hivaldec`, `hivardec`, `hiimpdec`
(97 constructors in 4 node types, 12 records) and their constructors, printers and utilities. 4.2k lines of ATS1, 3.5k of ATS2 + 2.2k generated. Same names as `src/`.

HD-1. **Arena AST, as dynexp3** (D3-1): node types are datatypes (`hidexp_node_HDEvar (d2v)`, `case+ hidexp_node_view (e.hidexp_node ()) of ~HDEvar d2v => ..`, `hidexp_node_is_HDEvar`),
      the rest records (`hidexp_new (loc, type, node)`, `e.hidexp_type ()`). `LABHIPAT`/`LABHIDEXP` are the records `labhipat`/`labhidexp` (`labhipat_lab/_elt`); lists and options are `glist`/`gopt`.
      Matches with a wildcard free the view; the predicates (`hidexp_is_value`, `hipat_subtest`, ..) use the `_is_` tests and one-arm `val-~CON .. = view (..)` reads (no allocation for a test).
HD-2. **Mutable fields** (ATS1: C functions): `hipat_asvar`, `hifundec_hidecl`, `hifundec_funlab`, `hiimpdec_funlab`, `hiimpdec_instrlst` are `mut` fields; `hipat_set_asvar` keeps its C name,
      the four `*_getref_*` functions return `cell + 8*index` (the layout of a record is a word per field in spec order: 32, 40 for `hifundec`, 48, 56 for `hiimpdec`) and keep their C names (`ext#patsopt_hifundec_getref_hideclopt`..).
      `hifundec_hidecl` is a `hideclopt` (ATS1 hid it behind `hidynexp_hidecl_type`); `funlab` is the placeholder of `pats_histaexp.sats` and `instrlst` (`hidynexp_instrlst_type = ptr`) the one that `pats_ccomp` replaces
      (stored as words: `$UN.cast` to the real types). `hifundeclst_set_hideclopt` uses the setter.
HD-3. **The declaration holds its functions and each function holds the declaration** (`d3ecl_tyer_fundecs` sets `hifundec_hidecl`): a dumper must not follow that field (the test dumps it shallowly, `fprint_hidecl`).
HD-4. **Maps of the instances of templates**: `tmpcstimpmap = d2cstmap (hiimpdeclst)`, `tmpvardecmap = d2varmap (hifundec)` are the avl maps of dynexp2 (templates `d2cstmap_search<hiimpdeclst>`: the module has
      `staload _ = "./pats_dynexp2_dcst.dats"`/`_dvar.dats`); `tmpcstimpmapopt`/`tmpvardecmapopt` are `gopt`s that live in the words returned by `filenv_getref_tmpcstimpmap/tmpvardecmap` (trans2_env, T2-3;
      null = None), read with `$UN.ptr0_get`, written by typerase with `$UN.ptr0_set<..opt> (p, gopt_some (m))`.
HD-5. **`val-Some (..)`** of `d2cst_get2_type_arg/res`, `$D2E.d2cst_is_fun` (implemented in `pats_hidynexp_util.dats`) and `hipat_lst` (the constructors of `list_vt0ype_int_vtype`, from `s2cst_get_islst`) is `assertloc (gopt_is_some ..)`
      (the MatchError; the process ends).
HD-6. **Local closures** are lambda-lifted (`hipat_lst_aux`); `list_filter_fun` of `hidexp_seq_simplify` is a recursive function that keeps the order; `hdevaremp`/`hianybind` stay linear `datavtype`s (consumed by the match);
      `list_last`/`dropz` are `hideclist_last`/`dropz` on `glist`.
HD-7. **Printers**: `fprintf` is `fprint_*` calls with the same text; the wildcard arm of `fprint_hidecl` lists `HIDextype HIDextvar HIDdynload HIDlocal` (they print `HID...(...)`); kept ATS1 oddities: `HDEloop` prints `HDEloop(...)`,
      `HDEtrywith` prints `...`, `HDEcase` prints the clauses with `fprint_hiclau`, `fprint_hideclist` ends every declaration with a newline, `fprint_higmat` is dead code.
HD-8. **Names**: `hipat_make_node`, `hidexp_make_node`, `hidecl_make_node` and the smart constructors have the ATS1 names and argument orders (`hidecl_staload (loc, idopt, fname, flag, fenv, loaded)` keeps the ATS1
      parameter names, which are swapped w.r.t. the node: the order of the arguments is `(idopt, fname, flag, filenv, loaded)`). Dynload order: `.. dynexp3, dynexp3_print, histaexp, histaexp_print, histaexp_funlab, hidynexp, hidynexp_print, hidynexp_util, typerase_error, ..`.

## Type erasure (typerase): pats_typerase_{error,staexp,dynexp,decl} (rules TY-1 .. TY-8)

Done (see the validation below): `pats_typerase.{sats,hats}` (+ `pats_typerase.spec`: `trans4err`, generated `pats_typerase_gen*.hats`, not in git), `pats_typerase_error.dats`, `_staexp.dats` (s2exp -> hisexp),
`_dynexp.dats` (p3at/d3exp -> hipat/hidexp), `_decl.dats` (d3ecl -> hidecl, the maps of the instances of templates). 3.3k lines of ATS1, 3.2k of ATS2. Same names as `src/`.

TY-1. **`trans4err`** is generated (`trans4err_T4E_p3at_tyer_isprf (p3t)`, `trans4err_T4E_d3exp_tyer_isprf (d3e)`); the list is a `glist` in an arena cell, newest first; `the_trans4errlst_finalize` prints
      `patsopt(TYPERASE): there are [n] errors in total.` and raises `PATSOPT_TRANS4_EXN` (the list is emptied first).
TY-2. **s2exp -> hisexp** (`s2hnf_tyer` is one match on `s2exp_node_view` of the head normal form with a wildcard arm `hisexp_s2exp (s2e0)`): `s2cst_tyer` follows `s2cst_get_isabs` (`gopt (gopt (s2exp))`: none = the constant,
      `Some None` = the constant, `Some (Some def)` = the erasure of the definition); `S2Eapp` with a constant head: no `isabs` -> `hisexp_make_srt`, a definition -> `s2exp_tyer_app2` (substitution of a lambda), else `hisexp_app` of the erased head and of the
      arguments whose sort is a program sort or a tkind; `S2Efun`: flag 0 -> `funptr`/`clotyp`/`cloptr` (the kind `funclo_get_clokind (fc) = 0` is `clotyp`), flag > 0 -> `hisexp_fun` without the `npf` proofs;
      `S2Etyrec`: boxes are `tybox` (flag 0) or a record, flat external records are always records, flat ones with one field that is not a proof are `tyrecsin`; proof fields and arguments are dropped everywhere (`s2exp_is_prf`);
      `S2EVar` -> `s2zexp_tyer` of its size. `FUNCLOclo (knd)` of ATS1 is `FUNCLOclo0/cloptr/cloref` (HS-2).
TY-3. **`val-list_cons`** of the `npf` loops and of `p3atlst_tyer2` / `c3laulst_tyer2` is `glist_head_exn`/`glist_tail_exn` (`pats_typerase.hats`: `abort_interr`, the MatchError). `val-S2Efun (..) = ..`, `val-S2Etyrec ..` are
      `val-~CON .. = view (..)`; `D3Earrinit` needs `un_s2exp_g1size_index_t0ype` to be `Some` (else `abort_interr`).
TY-4. **Unsupported trees** end the process as in ATS1: `p3at_tyer` of `P3Tfloat`, `P3Tvbox`, `P3Terrpat` (prints the location and the pattern on stdout, `exitloc (1)`); `d3exp_tyer` of `D3Eliteral`, `D3Eitem`, `D3Escase`, `D3Eviewat`
      (`INTERROR(pats_typerase_dynexp)` on stderr, `exitloc (1)`).
TY-5. **Evaluation order** is that of ATS1 (every `val` in its place): `d2var_tyer`/`d2cst_tyer` record the erased type once, `d2var_inc_utimes` is counted at every `D3Evar`, `D3Eptrofvar`, `D3Esel_var`, `D3Eassgn_var`, `D3Exchng_var`,
      `D3Evcopyenv`, `D3Etempenver`; the `list_map_fun` of ATS1 is head first (`d3explst_tyer_map`, ..); the warning of a non-value `D3Elam_sta` is `prerr_warning4_loc` + text.
TY-6. **Closures**: the `auxlst` of `D3Eifcase` is the function `d3exp_tyer_ifcase_aux (knd, loc0, hse0, x0, xs)`; the `lam` of `f3undeclst_tyer` and the `aux`/`auxlst` of the two `make_hideclist` are plain functions.
TY-7. **Files**: `D3Cstaload` reads `$TRENV3.filenv_get_d3eclistopt (fenv)` (must be `Some`: `assertloc`), erases the declarations of the file when `loaded = 0` and stores `Some (map)` in the cells of
      `filenv_getref_tmpcstimpmap/tmpvardecmap`. A driver must implement `filenv_get_d3eclistopt` (E3-5) and the two `getref`s (trans2_env).
TY-8. **Needs** (besides hidynexp): `pats_stacst2` (`un_s2exp_g1size_index_t0ype`, `un_s2exp_intconst`, the pervasive constants through the double or the real `the_s2expenv_pervasive_find`), `s2hnf2exp`/`s2exp2hnf` of util2,
      `pats_errmsg` (`prerr_error4_loc`, `prerr_warning4_loc`, `prerr_interror_loc`).

### Validation (hidynexp, typerase) (ATS1 reference = the objects of `src/` of the main tree: `SRC=<main tree>/src make -C test/hd compare`; `make -C test/hd test|cover|mutate|asan`)

* **`test/hd/hd_gen.py` + `hd_cases.py` + `hd_ty.py`** generate, from the specs of staexp2, dynexp2, dynexp3, histaexp and hidynexp (the machinery of `d2_gen.py`/`d2_cases.py`: wrappers `K_<CON>` and complete dumpers `dd_<T>` of EVERY type,
  the real `hisexp`, `hifundec_hidecl` dumped shallowly) ONE neutral program of 76 scenarios (24 chunks, 37k lines; `HDSEED=1 HDSCALE=3`) compiled by the ATS2 driver `hddump.dats` and the ATS1 driver `hddump1.dats` (`hd1.sh`, linked
  with the objects of the main tree; the cells of the file environments are doubles in `hd_stub.c`, the pervasive table is `s2env1/2.hats`). Families: `setup` (pervasive constants, the list constructors), `make` (every smart constructor of
  `pats_hidynexp.sats` parsed from the sats, every node and record through `K_`, every printer), `pat` (is_wild, `hipat_subtest` on all the pairs of 40 small-domain patterns and on structural twins, lists, labels, `hipat_lst`, `hipat_rec2`, `set_asvar`),
  `exp`..`exp4` (is_empty/is_value/is_lvalue on shapes that decide each arm, `hidexp_seq_simplify`, `hidexp_let_simplify` on every (last pattern, body, number of other declarations), `hidexp_app2`, `hidecl_is_empty`), `dec` (the cells
  of `hifundec`/`hiimpdec`, `hifundeclst_set_hideclopt`, the two maps, the file environments), `d2` (`d2cst_get2_*`, `d2var_*2_*`, `d2cst_is_fun`), and for the typerase `tys` (`s2exp_tyer` flags 0/1/2 of about 130 type exemplars: every case of
  `s2hnf_tyer` with abstract constants with/without/chained definitions, lambdas and non-lambdas applied, sorts that are dropped, records of every kind with proofs, `npf` and singletons, functions of every kind, data types, arrays, ..),
  `tyz` (every `s2zexp`, the sizes of `S2EVar`, `t2mpmarg` and its `mhnfize`), `tyv` (`d2var_tyer`, `d2cst_tyer`, `decarg2imparg`, the state of the cells), `typ` (`p3at_tyer` of every pattern kind forced, `p3atlst_tyer(2)`, the error list and the exception),
  `tye` (`d3exp_tyer` of every constructor forced, deep random trees, `d3lab_tyer`, `d3expopt_tyer`), `tyd` (`d3ecl_tyer` of every declaration, `d3eclist_tyer(_errck)`, proof functions/values (the errors), `D3Cstaload` with loaded 0/1 and
  the maps stored in the file environments). 19 cases that end the process (`HDEXIT=k`, `hd_exit.hats`): the unsupported trees, every MatchError, the internal errors.
  **Result: stdout 24.6k lines and stderr 3.8k lines byte-identical in ATS1 and ATS2; the 19 exit cases fail in both with the same stdout and INTERROR lines** (`hdcmp.sh`); `hd.md5` keeps the md5 of the ATS1 output (`make -C test/hd test` needs no ATS1; line 2 is the md5 of `hdexit.sh`).
* **Coverage** (`make -C test/hd cover`): gcov by ATS line (`patsopt --gline`, `-O0 --coverage`, the run and the 19 exit runs): hidynexp 511/511, hidynexp_print 661/667, hidynexp_util 447/458, typerase_error 22/22, typerase_staexp 343/343,
  typerase_dynexp 761/764, typerase_decl 280/280: **3025 of 3045 executable lines (99.3%)**; the rest is dead code (`fprint_higmat`, the unused `hidexplst_is_value`, the aborts after `assertloc (false)`) and punctuation lines. Every function of the
  two sats that ATS1 implements is called (`hdcover.py`).
* **Mutation test** (`python3 hdmutate.py`): 108 deliberate bugs in the 7 modules (the kinds of constructors of lists, offsets of the cells, the instances map, printers, every predicate, the simplifiers, every case of the erasure of
  types (functions, records, sizes, abstract definitions, proofs, npf), the counts of uses, erasures of patterns, declarations, files and the error list): **108/108 detected** after the first run missed 4 (`is_wild` of an as-pattern, `subtest` of integers,
  `is_value` of a let, the index after a proof in a data type), which made me add the deterministic patterns/shapes/types.
* **AddressSanitizer** (`make -C test/hd asan`, leak detection on): no error, no leak report.

### Interface notes for ccomp (consumes `hidexp` trees)

* Read with `*_node_view` (one malloc per match) or the `_is_` tests; `hidexp_get_type`, `hipat_get_type` are the erased types. The cells `hifundec`, `hiimpdec` are mutable only through `hifundec_getref_hideclopt/funlabopt`, `hiimpdec_getref_funlabopt/instrlstopt`
  (addresses of words; read/write with `$UN.ptr0_get/ptr0_set<hideclopt|hifunlabopt|hiinstrlstopt>`); null is None. ccomp must replace `funlab`/`instrlst` placeholders (cast them) and provide `patsopt_funlab_get_name`.
* `filenv_get_tmpcstimpmapopt/tmpvardecmapopt` give the maps built by typerase for a staloaded file. The typerase output of a declaration list is `d3eclist_tyer_errck` (raises `PATSOPT_TRANS4_EXN` after printing the errors).

### Open problems (hidynexp, typerase)

* `pats_typerase.hats`'s `glist_head_exn` aborts with `abort_interr` where ATS1 raises `MatchError` (the exit status and the message differ; the test compares only that both fail).
* The `hifundec`/`hiimpdec` getrefs depend on the field order of the spec (documented in `pats_hidynexp.spec`); a field added before them must update the offsets.
* A real `patsopt` (trans3 not ported yet) cannot produce `d3exp` trees: the validation uses generated trees; the whole-program behaviour will be checked when trans3 and ccomp are ported.
* `make -C test/hd compare` needs the ATS1 objects of a built main tree (`SRC=`); building the 24 ATS1 chunks takes about 2 minutes.

## Level 3 translation, group 1 (dynexp_up/util/syncst): pats_trans3_{dynexp_up,util,syncst}, pats_trans3_error (rules T3G1-1 .. T3G1-14)

Done (typecheck, link, differential test, see Validation): `pats_trans3_dynexp_up.dats` (`d2exp_trup` and its 40-odd arms: variables, constants, constructors, applications,
lists/tuples/records/sequences, binders, delays, macros, solver pragmas, `d2var_get_type_some`), `pats_trans3_util.dats` (`d2exp_syn_type`, `d3exp_trdn`, `d3explst_trdn_arg`,
`d3exp_linheap_check` of CLAUDE.md "No GC", `d23exp` helpers, `fshowtype_d3exp_up/dn`), `pats_trans3_syncst.dats` (the types and trees of integer/float/char/string/`$myfile` literals).
`pats_trans3_error.dats` was already complete (M2-4). 3.5k lines of ATS1, 3.6k of ATS2 (the ATS1 line count of the four files is 3.9k with the error module). Same file and function names as `src/`.
The declarations are in a delimited block of `pats_trans3.sats` ("BEGIN group 1" .. "END group 1"); the other three groups add theirs in the same way (a merge is a concatenation).

T3G1-1. **No closure was needed**: every local `fn`/`fun` of ATS1 either was lambda-lifted (the `aux` of `d23explst_trdn`, `d2exp_trup_rec`, `d2exp_trup_seq`, `funarg_patck_exhaust`) or is a plain function
        that the `glist` combinators of `pats_trans2.hats` (`glist_map_fun`, `glist_map_loop`; `#include`d, so the `$ERR` aborts come with it) take as a function pointer. `list_map_fun` maps head first, as ATS1.
T3G1-2. **`d23exp` is still a linear `datavtype`** (`D23Ed2exp of d2exp | D23Ed3exp of d3exp`, `d23explst = List0_vt (d23exp)`), declared in the group-1 block of `pats_trans3.sats` because
        `pats_trans3_appsym.dats` (group 3?) calls `d23exp_trup_applst` and `d23exp_free`. The borrowed traversal `d23explst_open_and_add` is `@list_vt_cons (d23e, d23es1)` + `@D23Ed3exp (d3e)` + `fold@`.
T3G1-3. **The `val-D2Exxx (..) = d2e0.d2exp_node` of ATS1 is a one-arm view match** whose other arm is `$ERR.abort_interr<d3exp> ()` (the MatchError, as M2-5); the same for the specialised
        `d2exp_trup_xxx (d2e0)` entry points, which are `implement`ed here although `extern` in ATS1 (they are not in the sats: `d2exp_trup_sym/extval/extfcall/extmcall/con/tmpid/lst/tup/rec/seq/effmask/vararg/vcopyenv/
        tempenver/arg_body/letwhere/lam_dyn/laminit_dyn/lam_sta/lam_met/fix/delay/ldelay/for/while/trywith/mac/macsyn/solassert/solverify`; `labd3explst_get_type` too).
T3G1-4. **The `D2Eapplst` arm** keeps the order of the tests of ATS1: `D2Esym` / `D2Etmpid` whose head is a symbol / `D2Emac` / the rest. The guard `when d2exp_is_sym (d2e)` cannot be written on a linear view:
        the arm tests inside and falls to the same code as the last arm (`d2exp_trup_applst_rest`: `d2exp_get_seloverld` then `d2exp_trup_applst` or `d2exp_trup_applst_seloverld`).
T3G1-5. **Results by reference become flat tuples**: `d2exp_trup_arg_body: @(s2exp, p3atlst, d3exp)`; the `var s2i_asz` of `D2Earrinit` is the pair `@(d3exp, s2exp)` of `d2exp_trup_arrinit_asz`; the
        `s2e_res: &(s2exp?) >> s2exp` of the `aux` of `d2exp_trup_seq` is the second component of its result. The two functions of `pats_trans3.sats` that keep the `&` form are `d2exp_funclo_of_d2exp (d2e0, fc0: &funclo)` and
        `d2exp_s2eff_of_d2exp (d2e0, s2fe0: &s2eff? >> s2eff)` (callers write `var fc: funclo`, `var s2fe: s2eff` and pass the variable, no `&`). Do NOT initialise the `var s2fe` (`var s2fe: s2eff = s2eff_nil`
        gave "needed ptr_type"): the ATS1 initial value is always overwritten.
T3G1-6. **Proofs are gone (T1-5, E3-1)**: `the_effenv_push_lam (s2fe)`, `the_d2varenv_push_lam (lin)`, `the_pfmanenv_push_lam (lin)`, `the_lamlpenv_push_lam (p3ts)`, `trans3_env_push ()` / `trans3_env_pop_and_add_main (loc)`, the pops
        `the_effenv_pop ()` etc. are called in the order of ATS1 (the pops in the order effenv, d2varenv, pfmanenv, lamlpenv in `d2exp_trup_arg_body`). `lstaftc3nstr` is a linear value (`val lsaft`, borrowed by update/process, consumed by finalize).
T3G1-7. **`funarg_patck_exhaust` builds a `glist`** of the `p2atcst`, not the linear list that ATS1 borrowed with `$UN.castvwtp1{p2atcstlst}` (PC-2): same calls in the same order (`p2at2cst`, the linearity check, then
        `p2atcstlst_comp`), no copy into the arena. Its results (`p2atcstlstlst_vt`) are copied and freed as in ATS1.
T3G1-8. **Messages**: `prerrf (".. %i ..", @(n))` and `prerrln! (a, x, b)` are `prerr` / `prerr_int` / `prerr_d2var`.. calls and `prerr_newline ()`: the text is unchanged. `d2exp_trup_literal` keeps the `println!` of ATS1
        that prints `d2exp_trup_literal: d2e0 = ...` on STDOUT (a debug leftover).
T3G1-9. **Syntactic constants** (`pats_trans3_syncst.dats`): the local enumerations `intknd`/`fltknd` are datatypes with prefixed names (`IK_UINT`.., `FK_FLOAT`..) and are chosen by `intknd_of_sfx`
        (same order of the `strcasecmp` tests). The pointer arithmetic on the string (`$UN.cast2ptr (rep) + ln`) is `rep_get_sfx` (`ptr0_add_guint<char>`), the substring `string_make_substring`/`ats_free_gc` is a copy in the
        global arena (`my_make_substring`, as `pats_patcst2.dats`: a few bytes per integer literal with a suffix, never freed); `intinf_make_base_string_ofs` needs `n >= 1`/`n >= 2` for the octal/hexadecimal offsets, given by `$UN.prop_assert` (the `praxi` of ATS1).
        `val-T_INT (base, rep, sfx) = x.token_node` is `token_int_get` (view match; the MatchError is `assertloc`). A rep that is not a number in its base ends the process in the intinf module (both builds).
T3G1-10. **`d2var_get_type_some`** (declared in the partial sats of the macro slice, E3-5) is implemented in `pats_trans3_dynexp_up.dats`; the double of `t3env.tmpl` is not used by this test (`t3g1env.tmpl`).
T3G1-11. **Linear heap check** (`d3exp_linheap_check`): the four rejected constructs are tested by view matches on `d3exp_node`; `s2exp_is_cloref` is `funclo_get_clokind (fc) < 0` (`FUNCLOfun` gives 0, as the ATS1 `FUNCLOfun () => false`).
T3G1-12. **ATS1 oddities kept**: the unsupported `d2exp_node`s of `d2exp_trup` (`D2Eexist`, `D2Emacfun`, `D2Etop`) print `INTERROR` and `exitloc (1)`; `d23exp_trup_applst_dyn` has a trivial `case+ .. of _ =>`; `D2Eann_funclo`
        and `D2Eann_seff` are only handled by `d2exp_trup_arg_body` / `d2exp_syn_type` (as a bare expression, `D2Eann_funclo` is unsupported in `d2exp_trup`); the effect of `D2Eann_seff` is ignored when it is not the body of a lambda.
T3G1-13. **Needs**: `pats_trans2.hats` (`glist_map_fun`, `$ERR`), `pats_syntax_token.hats` (`token_char_get`, `token_string_get`, `token_float_rep`), the arena, `pats_patcst2`, `pats_dmacro2` (the three evaluators), `pats_trans3_env*`,
        `pats_staexp2_solve`, `pats_stacst2` (the pervasive constants must be there: `stacst2_initialize`). Dynload order: after `pats_trans3_env_lstate`, `dmacro2*`: `syncst, util, dynexp_up` (they have no initialiser; ATS1 has `util` first).
T3G1-14. **Functions of the other groups that these modules call** (the signatures that I assumed are in `test/pats_trans3_others.sats`, a TEST file; list indices dropped): `p2atlst_syn_type`, `p2atlst_trup_arg (npf, p2ts): p3atlst`, `d2exp_trdn`,
        `d2explst_trdn_elt`, `d2exp_trdn_ifhead/sifhead/ifcasehd/casehead/scasehead`, `c2laulst_trdn (loc0, casknd, invres, c2ls, d3es, s2es_pat, s2e_res): c3laulst`, `d3exp_fun_restore`, `d3explst_arg_restore`, `d2eclist_tr`, `s2addr_deref`,
        `d2exp_trup_applst_sym/tmpsym/seloverld/selab/foldat/freeat/ptrof/viewat/deref/assgn/xchng/loop/loopexn`. Compare these signatures with the group blocks of `pats_trans3.sats` at the merge.

### Validation (ATS1 reference = the objects of the main tree `src/`; `make -C src2/test t3g1 | t3g1cmp SRC=<src/> | t3g1mut | t3g1cov | t3g1asan`)

* **How it is built.** The modules cannot be typechecked in `src2/` until the four groups are merged (the other groups' functions are not declared): `src2/test/t3g1_mk.sh DIR` makes a build directory of symbolic links (`src2/t3g1.build`, not in
  git) with a copy of `pats_trans3.sats` that also has `test/pats_trans3_others.sats`; `make check` (`checkt3g1`) typechecks the three modules there, `make -C test t3g1` builds the ATS2 driver `t3g1dump.dats` (all the ported modules + the three
  of this group + `t3g1stub.hats`) and compares its stdout/stderr with the md5 sums of the ATS1 build (`t3g1dump.md5`). After the merge: add the modules to `D3DATS`, delete `checkt3g1`, `pats_trans3_others.sats`, the stubs.
* **Method of the earlier levels** (`t3g1_gen.py`, on top of `t3_gen.py`/`d2_gen.py`): ONE neutral program of 35 scenarios (`T3G1SCALE=3`, `T3G1SEED=1`; 7.7k lines) in the common subset of ATS1 and ATS2, built from the generated wrappers `K_<CON>`
  and complete dumpers `dd_<T>` of the trees, compiled by the ATS2 driver and by the ATS1 driver (`t3g1dump1.dats`, `t3g1dump1.sh`, linked with the ATS1 objects of `src/`: the real `pats_trans3_*` of the other groups too; the
  trans2 functions that they need are the table doubles of `t3g1env.tmpl`). Families: `setup` (pervasive constants), `ints`/`floats`/`atoms` (every suffix of `intrep_syn_type(_ind)`, `i0nt_syn_type(_ind)`, `float_syn_type`, `f0loat_syn_type`,
  tokens, `d2exp_trup_{int,intrep,bool,char,string,float,i0nt,f0loat,cstsp,tyrep,literal}`), `syn` (`d2exp_syn_type`, `d2explst_syn_type`, `labd2explst_syn_type`, `d2exp_funclo_of_d2exp`, `d2exp_s2eff_of_d2exp` on random expressions),
  `d3` (`d3exp_linheap_check` on lambdas/tuples/records/delays/lists of every closure kind, boxity, sort and linearity, `d3lablst_is_overld`, `fshowtype`, `d23exp_free`), `trdn` (`d3exp_trdn`, `d3explst_trdn_arg`, `d3explst_get_ind`),
  `upatoms`/`upvars`/`upapps`/`upmisc`/`upeff`/`upmore` (`d2exp_trup` on random expressions and on hand-shaped ones: variables (linear, template, untyped), constants and templates, static/dynamic/nested/curried applications, constructors, lists, tuples,
  records, sequences, lambdas, static/metric lambdas, fixpoints, effects of lambdas and calls, raise/effmask, extfcall/extmcall with linear arguments, arrays with a size, solverify/solassert, macros, vcopyenv).
  Every scenario ends with the dump of the final constraint (`the_trans3_finget_constraint`) and the error count (`t3chk`).
* **The other groups are doubles in ATS2** (`t3g1stub.hats`) and real in ATS1: the scenarios only reach them on inputs where the doubles are exact: the empty lists (`p2atlst_syn_type`, `p2atlst_trup_arg`, `d2eclist_tr`), `d3exp_fun_restore` of a
  `FUNCLOfun`, and `d2exp_trdn` for the "rest" case (= `d2exp_trup` then `d3exp_trdn`, no `wthtype`) plus `D2Esing/D2Elist/D2Eshowtype`; any other input stops the process (the generator keeps "dn" positions to these kinds, see `ExpGen.up/dn`).
  NOT reached, hence NOT tested against ATS1: lambdas with arguments (the patterns), `let/where` with declarations, `D2Eifhead/sifhead/ifcasehd/casehead/scasehead/trywith/for/while/loopexn`, `D2Esym` applications and `D2Earrsub`/`D2Ederef`/`D2Eselab`/
  `D2Eassgn`/`D2Exchng`/`D2Eptrof`/`D2Eviewat`/`D2Efoldat`/`D2Efreeat`, mutable variables, `wthtype` results of applications. They are reviewed line by line only (below).
* **Result: stdout 3327 lines and stderr 2276 lines, byte-identical in ATS1 and ATS2** (`t3g1cmp`; seeds 1..4, also at `T3G1SCALE=6`: 6.6k + 4.3k lines, identical; exits 0). `t3g1dump.md5` keeps the md5 of the ATS1 output of seed 1.
  The first complete run found no bug of the port; the review (below) had already found one (a duplicated `d23explst_open_and_add` in `d23exp_trup_applst_dyn`, harmless in the output but a real deviation).
* **Line-by-line review.** For each function of the three modules I read the ATS1 text and the ATS2 text side by side, checked the order of the calls with side effects (stamps, errors, environment pushes/pops), the argument order of every call, the error
  messages (character by character) and the arms of every match. The functions that the tests cannot reach (previous item) were reviewed twice.
* **Coverage** (`t3g1cov`, gcov by ATS line): syncst 231/238 (97.1%), util 263/266 (98.9%), dynexp_up 940/1138 (82.6%). The rest of dynexp_up: the arms that call the other groups (the doubles abort), the MatchError arms, `D2Esym`-like unsupported kinds, mutable variables,
  `funarg_patck_exhaust` for non-empty argument lists (the linearity message), the `wthtype` restore, `trywith`.
* **Mutation test** (`t3g1mut`, `python3 t3g1mutate.py REF.out REF.err`; the mutated file replaces the link in the build directory, `src2/` is untouched): 96 deliberate bugs in the three modules (suffix tables, error messages, kinds of closures/records, the order
  of the opening of the arguments, locations, environment pushes/pops, the update of linear variables, instantiations, metrics, fixpoints, effects...), **88 detected**. The 8 that are not: the location of the instantiation of an explicit template (not observable: it only
  numbers fresh variables), the `wthtype` restore of an application (needs the group that implements `d3explst_arg_restore`), the scope check and the unbinding of a `let` (need declarations, i.e. `d2eclist_tr` of group 4), the linearity message for a function
  argument pattern (needs patterns), the `llam` check with `lin > 0` (ends the process for a linear variable, not reachable otherwise), the `pfmanenv` stopping kind of a lambda (observable only through `pfobj_search_atview`, group 3), the `npf` of `D2Earrsub` (goes to the
  `d2exp_trup_applst_sym` of group 3). Those mutations are the ones to run again with the integrated pipeline.
* **AddressSanitizer** (`make t3g1asan`, leak detection on): the whole run, no error, no leak, the same stdout.

### Notes for the integration agent, and doubts

* `pats_trans3.sats` has only my block; `test/pats_trans3_others.sats` is the list of the declarations of the other groups that I assumed (a flat tuple for every result by reference, `p3atlst` instead of `list (p3at, n)`, `c3laulst`). If a group's real signature differs,
  fix the call in `pats_trans3_dynexp_up.dats` (calls: `p2atlst_trup_arg (npf, p2ts)`, `c2laulst_trdn (loc0, CK_case_neg, r2es, c2ls, d3es, s2es_pat, s2e_res)`, `d3exp_fun_restore (fc, d3e)`, `d3explst_arg_restore (d3es, s2es, wths2es)`).
* `d2exp_trup` allocates one view per `d2exp_node_view` match (rule 3 of "Arena AST"); the type checker of a whole file does a few per node: fine for correctness, not measured for speed.
* Unsure: (1) `d2exp_trup_arrinit_asz` evaluates `s2exp_int (nxs)` / `s2exp_int_index_t0ype` / `d3exp_int` in the order of the ATS1 `where` block, by reading; the test covers it (arrays with and without size). (2) `funarg_patck_exhaust` passes a `glist` where ATS1 passed a
  borrowed `p2atcstlst_vt`: `p2atcstlst_comp` takes a `p2atcstlst` in the ATS2 patcst2, same contents; the linearity message path is not tested (needs patterns). (3) The `D2Eapplst`/`D2Etmpid` arm falls to `d2exp_trup_applst_rest` when the
  head is not a symbol; in ATS1 that is the `_` arm of the same `case`: reviewed, not testable (needs `d2exp_trup_applst_tmpsym`). (4) `d3exp_linheap_check` is also called by `pats_trans3_dynexp_dn.dats` (group 2): declared in the sats block of this group.
  (5) The `exitloc (1)` of the unsupported arm prints the location of the source line of the port (M2-6).
* Stack depth: `d2exp_trup` recurses on the tree like ATS1 (`d2explst_trup_arg`, `d23explst_trdn_aux`, `d2exp_trup_rec_aux` are not tail recursive, as in ATS1).

## Level 3 translation, group 2 (dynexp_dn/appsym/caseof/patcon): pats_trans3_dynexp_dn, _appsym, _caseof, _patcon (rules G2-1 .. G2-12)

Done (typecheck, link, differential test, see Validation): `pats_trans3_dynexp_dn.dats` (`d2exp_trdn` and the downward translation of every form: let/where, application of a macro, if/sif/ifcase,
tuples/records/sequences, raise/effmask/exist, `lam_dyn`/`lam_sta`, `delay`/`ldelay`, `try`), `pats_trans3_appsym.dats` (overloaded symbols: `d2exp_trup_applst_sym/_tmpsym/_seloverld`),
`pats_trans3_caseof.dats` (`c2laulst_trdn`, `d2exp_trdn_casehead/_scasehead`: coverage, redundancy and exhaustiveness of the clauses through patcst2) and `pats_trans3_patcon.dats`
(`p2at_trdn_con`: constructor patterns, their decorations `~`/`@`, `p3at_{lincon,free,unfold}_update`). 3.6k lines of ATS1, 3.5k of ATS2 (+ a private spec/sats for appsym). Same file and function names as `src/`.
The declarations that the four modules export are in a delimited block "group 2" of `pats_trans3.sats` (the merge of the groups is a concatenation); the functions of the other groups that they call are in
`test/t3g2/pats_trans3_others.sats` (TEMPORARY, see G2-2).

G2-1. **Method.** `utils/arenagen/port_ats1.py` made the first draft (specs: syntax, staexp2, dynexp2, dynexp3, trans3_env, patcst2), then by hand with the rules of the earlier levels (a wildcard arm of a view match frees the
      view, `val-C (..) = x.node` is `val-~C (..) = X_node_view (x.node ())`, `Some/None/list_cons/list_nil` of the tree are `gopt`/`glist`, `list_map_fun` loops head first, `D2Eapplst` etc. keep their order of evaluation).
      A guard `D2Elam_sta (s2vs, _, _) when list_is_nil (s2vs)` is an `if` inside the arm whose else branch is the last arm (`d2exp_trdn_rest`).
G2-2. **Interface.** The index of `list (x, n)` is dropped (D3-3): `c2laulst_trdn (loc0, casknd, invres, c2ls, d3es: d3explst, s2es_pat: s2explst, s2e_res): c3laulst`, `d2explst_trdn_elt: d3explst`, ...
      The functions of the other groups that these modules call (`d2exp_trup`, `d2explst_trup`, `d3exp_trdn`, `d3explst_trdn_arg`, `p2at_trdn`, `p2atlst_trdn`, `p2atlst_trdn_arg`, `guard_trdn`, `funarg_patck_exhaust`,
      `fshowtype_d3exp_dn`, `d3exp_linheap_check`, `d2eclist_tr`, `d2exp_trup_cst/var/tmpcst/tmpvar`, `d23exp_trup_applst`, `d3exp_fun_restore`, `d3explst_arg_restore`, `d3lvalist_set_pat_type_left`) are
      ASSUMED to have the ATS1 signatures with `list (x, n)` -> `glist (x)` (`serr: &int` of `p2atlst_trdn*` as in ATS1, results `p3atlst`/`d3explst`): `test/t3g2/pats_trans3_others.sats` lists them. A mismatch with what the
      other groups declare is a type error in these modules at the merge. `make check` typechecks the four modules in a staging directory (`test/t3g2/stage.sh`: links to src2, `pats_trans3.sats` followed by that file,
      Makefile variable `T3G2_OTHERS`); **after the merge: empty `T3G2_OTHERS` (src2/Makefile), `G2OTHERS=none` (test/g2build.sh), delete `test/t3g2/pats_trans3_others.sats`, and move the four `.dats` to `DATS`.**
G2-3. **Options of propositions** (`s2expopt_vt = Option_vt (s2exp)` of `d2exp_trdn_ifhead` and `auxlst1_check`, borrowed with `$UN.castvwtp1`, merged by `f_conjtest_conj/_test`) are the shared `s2expopt` (`gopt`):
      `gopt_make_option_vt (un_s2exp_bool_index_t0ype (..))`, same constructors (`s2exp_bneg`, `s2exp_bmul`) in the same order, nothing to free. The `&` options `fcopt_vt`/`s2effopt_vt` of the lambda
      (`d2exp_funclopt_of_d2exp`, `d2exp_s2effopt_of_d2exp`) are results `@(d2exp, Option_vt ..)`; `s2exp_exi_instantiate_sexparg` returns a flat pair so `var s2ps0` of `d2exp_trdn_exist` is the second component.
G2-4. **`pats_trans3_appsym`**: the datatypes `d3pitm` (`D3PITM (pval, d3e)`) and `d3exparg` are generated (`pats_trans3_appsym.spec`, private `pats_trans3_appsym.sats`; only the `.dats` includes the `_gen_dats.hats`);
      `XY = (d3pitm, s2kexp)` is a flat pair in a `List0_vt`. Replaced: `list_length_compare` (`glist_length` equality), `max_int_int`, `list_filter_cloptr` (loops, head first), `list_map_fun` with a closure (loops),
      `val-Some (s2e) = d2var_get_type` (`gopt_view`), `free@` (the cells are consumed by `~list_vt_cons`). In `auxsel_arglst` the case "one candidate left" returns the list of the REMAINING argument groups unevaluated, as ATS1
      (the caller passes it to `d23exp_trup_applst`). `auxeq_d3pitm_remdup` removes only the duplicates of the FIRST item of the list (ATS1: no recursion), kept. `val-list_cons (d2e, d2es) = d2es` of `auxins`
      is `assertloc (glist_is_cons ..)` (the MatchError when `npf` exceeds the length).
G2-5. **`pats_trans3_caseof`**: the closures `auxred`, `auxmain`, `aux` of `c2laulst2_trdn_rest` are lambda-lifted (`c2laulst2_auxred/_auxmain/_inter_loop/_diff_loop`, `loc0` etc. are arguments). The two recursions over the matrix `cp2tcss`
      (`List0_vt (p2atcstlst_vt)`, up to 10^5 rows, PC-3) are loops with an accumulator reversed at the end: same result (head first), but `p2atcstlst_inter_test` is now called from the first row to the last (ATS1:
      last to first); it is pure. A row is borrowed with `$UN.castvwtp1{p2atcstlst_vt} (ptr)` (the pointers of the outer list: `cp2tcss_ptrs`, as `pats_patcst2.dats`) and given to patcst2 as `p2atcstlst_of_vt (xs)`
      (PC-2: a copy of the cells in the never freed arena: ~rows x clauses x columns cells per `case`; if a trans3 of a big program turns out to be memory hungry, this is the place). `cp2tcss := aux (cp2tcss)` moves the
      list out (`val cp2tcss0 = cp2tcss`) and assigns the result.
G2-6. **`pats_trans3_patcon`**: `dataviewtype patcontrup` is the flat triple `@(p2atlst, s2explst, s2exp)`; `prerrf ("..%i..", @(npf_con))` is `prerr_string/prerr_int/prerr_string`; `list_app_fun<p3at>` and
      `list_map_fun<p3at>` are loops (head first: the order of the stamps of `s2var_make_srt` and of the `d2var_mutablize_none` calls is that of ATS1); `case+ 0 of _ when flag = 0 => .. | _ when flag > 0 => .. | _ => ..` is an
      `if` chain. The pckind is matched as an enumeration (`PCKfree ()`), `pck = PCKcon` uses `eq_pckind_pckind`.
G2-7. **Text of the messages**: `prerrln! (..)` is `prerr_string ..; prerr_newline ()` with the same text, `filprerr_ifdebug` is unchanged, `prerr_error3_loc` uses `prerr_FILENAME<> () = prerr "pats_trans3_<module>"` of the module
      (compared byte for byte with ATS1 in the test: the prefix of the file name is the same).
G2-8. **MatchErrors** (`val-D3Eitem (d2i, t2mas) = d3e0.d3exp_node`, `val-S2Efun (..)` after `d3exp_app_unista`, `val-list_cons`) abort in ATS1 (the message is the runtime's) and here (`val-~C = ..` over a view: the view of another
      constructor is not freed, `assertloc`, `abort_interr`); the process ends in both, the texts differ by construction (the test compares everything but the last line of an abort).
G2-9. **The main dispatch of `d2exp_trdn`** is ONE view match over the 152 constructors of `d2exp_node` (a malloc/free per call, ~11 ns): the cost is that of the earlier levels (rule 3 of "Arena AST"); a tag switch
      (`d2exp_node_tag`) would avoid it if profiling asks for it.
G2-10. **`d2exp_trdn_ldelay`** (no-GC version of the ATS1 source: `$ldelay` of a type `lazy_vt (a)` is translated through `d2exp_trup` with an annotation) and `d2exp_trdn_delay` (`$delay` is rejected by
       `d3exp_linheap_check` of group 4) are ported as they are in `src/`.
G2-11. **Declared and never implemented / kept oddities of ATS1**: `d2exp_trdn_sifhead` uses the location of the THEN clause for the constraint of the else branch (`loc_else = d2e_then.d2exp_loc`); `d2exp_trdn_ifcasehd` of an
       ifcase without clauses ends the process in the environment (`saityplst_check`: `val-list_cons`), also in ATS1; the `D2Eapplst` of a macro expands the macro and translates again with `s2e0` (not `s2f0`).
G2-12. **Dynload**: the four modules have no initialiser; the driver `dynload`s them after `pats_trans3_env_lstate` and the macro modules (`test/g2dump.dats`).

### Validation (ATS1 reference = the objects of `src/`, the real ATS1 versions of the four modules included; `make -C test g2compare|g2test|g2cover|g2mutate`, `sh g2gcov.sh`)

* **Test doubles.** The functions of the other groups that the modules call are test doubles (`test/g2env.tmpl`, expanded for ATS1 and ATS2: `g2env.hats`/`g2env1.hats`): each prints a line `T3 name args` (so the ORDER of the calls and their
  arguments are compared) and returns a result that depends only on its arguments: `d2exp_trup` gives a typed leaf (`D2Eann_type (e, s2e)`) its type and consumes a linear variable as `d2exp_trup_var_nonmut` does (`llamlocal` check, error
  otherwise), `d3exp_trdn` wraps in `d3exp_ann_type`, `p2at_trdn` maps variables, wildcards, as-patterns and (as the real one) constructor patterns to `p3at_var/any/refas` and `p2at_trdn_con`, `p2atlst_trdn*` match the pattern list
  against the type list (`serr`: +1 per excess pattern, -1 per missing one), `d2exp_trup_cst/var/tmpcst/tmpvar` build the node with the type of the constant/variable. Everything else is REAL on both sides: trans3_env (all of it),
  patcst2, dmacro2 (macro expansion in `D2Eapplst`), the solver, stacst2, dynexp2/3.
* **Cases** (`test/g2_gen.py` + `g2_cases.py`, reusing the machinery of `t3_cases.py` and the pattern generators of `cg_pat.py`; the compat layers/dumpers are those of the level-3 and codegen2 tests): ONE program in the common subset of
  ATS1/ATS2 of 89 scenarios (`G2SEED=1 G2SCALE=3`; 20 chunks, 25.4k lines), compiled by the ATS2 driver `g2dump.dats` and the ATS1 driver `g2dump1.dats` (`g2dump1.sh`, linked with the ATS1 objects of `src/`). Each scenario runs in an
  environment (`trans3_env` push, an effect frame of a random set, a `let` frame of the variable environment with two linear variables, the proof manager, the arguments of an enclosing function with views and addresses) and dumps the
  `d3exp`/`p3at` result completely (`dd_d3exp`..), the items of the environment after each call (`fprint_the_s3itmlst`) and completely when popped (locations of the constraints included), and the state of the variables (`chk_d2var`).
  Families: `dn_misc` (top, sing, list, showtype, let/where, application of a non-macro and of an identity macro `macdef f (x) = ,(x)`, the rest with and without a `wthtype` result), `dn_lists`
  (`d2explst_trdn_elt`, `d2expopt_trdn_elt`), `dn_tup` (tuples/records/sequences/`D2Elist`: matching and mismatching arity, boxity, npf), `dn_other` (raise under effect sets that allow/forbid exn, effmask, exist on
  existentials/wthtypes, delay, ldelay on lazy types, try), `dn_lam` (arity/npf/linearity/funclo/effect mismatches, annotations `D2Eann_funclo/seff`, quantified types, refarg, raise and linear variables in the body, static lambdas),
  `dn_if` (if/sif/ifcase: the propositions of the tests, conjunction of the negations of the previous tests, invariants of the linear variables, linear variables consumed in branches, ifcase without else), `dn_case` (pattern matrices of
  `cg_pat.py` over datatypes, lists, tuples, records, literals, as-patterns, guards with and without a pattern, `seq`/`neg` clauses, arity errors, `case`/`case+`/`case-` under effect frames that allow/forbid exn; static case),
  `patcon` (datatypes of 1-3 constructors, every decoration x every expected type: the datatype, a constructor type of the right/wrong constructor, an existential, a wthtype, something else; nested constructor patterns, variables
  that are linear or not, as-patterns, quantifiers, ill-typed constructor types, wrong arities), `appsym` (symbols of 1-4 candidates: constants, variables, nested overload lists, duplicates, non-function items, quantified/metric/existential function
  types, curried, `invar` arguments, wthtype results; 0-2 argument groups with an optional static group; the three entry points, `seloverld` with the root inserted at `npf`), and one scenario that ends the process (below).
  **Result: stdout 14896 lines and stderr 2542 lines, byte-identical in ATS1 and ATS2** (exit codes 0), `make g2compare`; `g2dump.md5` keeps the md5 of the ATS1 output (`make g2test` checks the ATS2 build without ATS1).
  The process that ends (`CG_ERRTEST=1`: the last scenario, a linear function that uses a linear variable that no frame owns, so that `the_d2varenv_check_llam` ends the process): stdout, exit status 1 and stderr identical but for the final
  assertion line. The first full run found no bug of the port (the first typecheck of the four modules passed at once; the failures of the first runs were the generator's: `wthtype` with `invar` entries and arguments that are not
  refargs, an ifcase/scase without clauses, a npf larger than the number of arguments, constants without `argsrtss` in a type that the solver compares: they abort in ATS1 and ATS2 at the same place).
* **Coverage** (`sh g2gcov.sh`, gcov by ATS line, `-O0 --coverage --gline`): dynexp_dn 611/612 executable lines (the missing one is the empty ifcase), appsym 456/464 (the arm of `d3exp_trup_item` for an item that is not a constant or a variable,
  the `D2ITMvar`/mixed-kind arm of `auxeq_d2itm`, two arms of `auxeq_d3pitm` that need a `d3pitm` that is not a `D3Eitem`), caseof 297/297, patcon 253/255 (two `else` arms of the type_left tests that need a pattern whose type_left was set and
  that is then redirected): **1617 of 1628 (99.3%)**.
* **Mutation test** (`python3 g2mutate.py`, 63 deliberate bugs in the four modules: guards and comparisons, the order of the arguments, the conjunction of the negated tests, the else location, the effect/linearity/proof arity solves,
  the order and the content of the lists, the matrix loops (`inter`/`diff`), the redundancy and exhaustiveness tests, the flags of the decorations, the instantiation of the datatype pointer, the restore of the linear state ..):
  **62 of the 63 are detected** (stdout/stderr/exit status of the normal run and of the exit run differ from the ATS1 reference). The survivor is `the_pfmanenv_push_lam (lin1)` -> `(lin)`:
  the kind of the proof-manager frame only matters to `pfobj_search_atview`, which these modules do not call (see the notes below). Equivalent mutants were not kept; the first runs missed 7 bugs and made me add: the double that consumes
  linear variables (restore of the linear state, `check_llam`: the process-ending scenario), the complete dump of the popped items (the location of a constraint), `invar` argument types (`s2fun_opninv_and_add`), scrutinees with existential types
  (`d3explst_open_and_add`), `case` under effect frames that forbid exn, a raise in the body of a lambda (the effect frame), and candidates that match the call exactly (`seloverld`).
* **AddressSanitizer** (`G2CF="-g -fsanitize=address"`, leak detection on): the whole run, no error, no leak report, same stdout/stderr.

### Notes for the integration agent (open doubts)

* The doubles are simpler than the real functions (a typed leaf instead of `d2exp_trup`, errors patterns instead of `p2at_trdn`, identity for `d3exp_linheap_check`, `d3explst_trdn_arg`, `d3exp_fun_restore`, ..): the real ones must be linked
  and the whole `d2exp_trdn` <-> `d2exp_trup` <-> `p2at_trdn` loop validated against ATS1 at integration (e.g. with the whole-file driver of the level 2 + `d2eclist_tr_errck`). The calls that they make of the four modules are the ones of `src/`
  (`p2at_trdn` -> `p2at_trdn_con`, `d2exp_trdn_rest` -> `d2exp_trup`/`d3exp_trdn`, `d2exp_trup_applst_sym` from `d2exp_trup_applst`).
* The signatures assumed for the other groups (G2-2); if they use `List_vt` results or another `serr` convention, the four modules need the matching edit (the call sites are few: `p2atlst_trdn`, `p2atlst_trdn_arg`, `d3explst_trdn_arg`).
* `the_pfmanenv_push_lam (lin1)` of `d2exp_trdn_lam_dyn` and the pfman state are only observable through `pfobj_search_atview`, which none of these modules calls: a bug there would not be seen by the g2 test.
* Memory: `p2atcstlst_of_vt` copies (G2-5); `d2exp_trdn` allocates one view per call (G2-9).

## Level 3 translation, group 3 (p2at/selab/fldfrat/lvalres): pats_trans3_p2at, _selab, _fldfrat, _lvalres (rules G3-1 .. G3-12)

Done (typecheck, link with test doubles, differential test, see Validation): `pats_trans3_p2at.dats` (patterns: `p2at_syn_type`, `p2at_trup_arg`, `p2at_trdn`, `p2at_trdn_arg`, the
list versions, `guard_trdn`), `pats_trans3_selab.dats` (labels and field selection: `d2lab_trup`, `s2exp_get_dlablst_*`, `d2exp_trup_selab`), `pats_trans3_fldfrat.dats`
(`d2exp_trup_foldat`, `d2exp_trup_freeat`), `pats_trans3_lvalres.dats` (left-value type restoration after a call: `s2addr_exch_type`, `d3lval_set_type_err`, `d3explst_arg_restore`..).
3.9k lines of ATS1, 3.75k of ATS2. Same file and function names as `src/`. The declarations are in `pats_trans3.sats` between the marks "BEGIN/END of the declarations of GROUP 3"
(the signatures of `src/pats_trans3.sats` with the length indexes dropped); the second half of the block repeats the declarations of the functions of the OTHER groups that these modules call
(`d2exp_trup`, `d2explst_trup`, `d2exp_trup_var_nonmut`, `d2exp_trup_deref`, `s2addr_deref`, `s2addr_set_viewat`, `p2at_trdn_con`, `intrep_syn_type(_ind)`, `i0nt_syn_type(_ind)`,
`f0loat_syn_type`): a repeated declaration of a `fun` is accepted, so the integration can drop that half or keep it.

G3-1. **Lists are `glist`, no length index** (D3-3): `list (T, n)` of `p2atlst_trdn_arg` / `p2atlst_trdn` / `c3laulst` style signatures is `glist (T)`; the `serr` argument still reports a
      length mismatch (`+1` for an extra pattern, `-1` for an extra type). Tests on a list are `glist_is_cons`/`glist_head`/`glist_tail` (no allocation) or a `glist_view` match.
G3-2. **Matches of a view** are `case+ x_node_view (e.x_node ()) of ~CON (..) => ..` and a catch-all arm frees the view (`| v => (x_node_view_free (v); ..)`, rule 3);
      `val-CON (..) = e.x_node` is `val-~CON (..) = x_node_view (..)` (a mismatch is a MatchError in ATS1 and a "unmatched value" abort here: same exit status, other text).
G3-3. **Guards `S2Eapp (f, args) when s2cstref_equ_exp (the_X, f) => .. | _ => default`** (int/bool/char/string patterns, the list pattern, `guard_trdn`) are one view match whose
      `S2Eapp` arm is `if equ then .. else default` and whose catch-all arm frees the view and does the same default; the default is a local `fun auxdflt` (arguments: what it needs)
      when it is more than one line. `case+ 0 of _ when .. =>` chains are `if .. else if`.
G3-4. **Closures are lifted** (`aux` of `p2atlst_trdn_arg` takes `loc0`; the `:<cloref1>` functions of `labp2atlst_trdn` take `loc0` and `isomit`). `list_map_fun` is `glist_map_fun<a,b>`
      of `pats_trans1.hats` (head first: the order of the side effects is that of ATS1; `#include "./pats_trans1.hats"` in `p2at` and `selab`), `list_take_exn` is the small `d3lablst_take`,
      `list_foreach_fun` of `p2at_proofize` a loop. `p2atlst_trup_arg` filled a hole in place: here an accumulator that is reversed at the end (same calls in the same order).
G3-5. **`&Option_vt (T)` arguments** (the `context` of `selab`: `Option_vt @(s2exp, s2hole)`, `Option_vt @(labs2explst, s2hole)`) are `&ctxtopt_vt >> ctxtopt_vt` (the index of an `Option_vt` is
      universally quantified in the argument and existential in the result: plain `&T` is "preserved but with an incompatible type"); a `Some_vt (!p)` whose field is updated in place
      is `~Some_vt (@(a, b)) => context := Some_vt @(a', b)` (and `~None_vt () => context := None_vt ()`); `val-None_vt () = context` is `val-~None_vt () = context`.
      The `labs2explst` that `labfind_context` rebuilds is an immutable `glist`: the cells are consed again, nothing is shared that ATS1 mutated.
G3-6. **`var ctxtopt: s2expopt`** of `d2var_trup_selab_lin` (ATS1 passes it as `&s2ctxtopt`, the two being the same abstract type there) is `s2ctxtopt` here (`gopt (s2ctxt)`);
      `d3lval_set_type_err` and `s2addr_exch_type` use `s2ctxtopt` as in ATS1.
G3-7. **`funclo` patterns**: `FUNCLOclo (knd)` is no pattern (rule 10): `FUNCLOfun ()` is matched, any other kind is `funclo_get_clokind (fc)` (1 cloptr, 0 clo, ~1 cloref); the macros
      `CLO/CLOPTR/CLOREF` of `pats_trans3_lvalres.dats` became the literals `0/1/~1` (they clash with `pats_basics.sats` in ATS2).
G3-8. **`d2exp_trup_selab` etc. call the other groups** through the repeated declarations (above); `s2addr_deref` (`&s2exp? >> s2exp` result), `d2exp_trup_deref`, `d2exp_trup_var_nonmut`,
      `s2addr_set_viewat` are not implemented here (`pats_trans3_deref`, `_dynexp_up`, `_viewat`); `p2at_trdn_con` is `pats_trans3_patcon`.
G3-9. **ATS1 oddities and bugs that are kept** (the test covers all but the last three): (a) `auxbind` of `p2at_trdn_exist` loops FOREVER (a tail call with the same arguments) when the
      pattern `[a, b: s]` binds FEWER variables than the existential quantifier of the type has (`s2vs1` exhausted, `s2vs2` not): the ATS1 and the ATS2 programs hang alike; the cases never
      generate it. (b) `labp2atlst_trdn`: `auxfind` of an `LABP2ATomit` item replaces the rest of the list by the omit item (the later patterns are dropped and not reported by `auxrest`).
      (c) `p2at_trdn_int/bool/char/string` with a type `g1int (k)` (an application of the right constant to too few arguments) are a MatchError (`val-list_cons`), `intrep`/`i0nt` handle it
      (`nerr + 1`). (d) `d3lval_set_type_err` of a `D3Esel_var` of a linear variable whose selection has no context (`None`: the label is not found, an index, an existential record) ends the
      process by `assertloc (false)` after `prerr_interror_loc`. (e) `auxres` of `d3exp_fun_restore` is a MatchError if the type of a closure expression is not a function type.
      (f) the `Some` branch of `auxfinize` (`d3lab_overld_app`) cannot be reached (nothing sets the field: the code that did is commented out in ATS1), as the `FUNCLOfun` arm of `auxres` and the
      `knd = 0` case of `s2exp_fun_is_freeptr` (a `clo` is already a reference, `refval > 0`). (g) `P2Tlist` in `p2at_trdn` prints the pattern and `exitloc (1)` (rule M2-6).
G3-10. **`d2var_get_type_some`** is declared in `pats_trans3.sats` (partial file, E3-5) and used by `selab` and `lvalres`; the trans3 port proper implements it; the test double is `t3env.tmpl`.
G3-11. **`prerrln!`/`println!`** are the explicit `prerr`/`prerr_newline` sequences with the same text (`prerr! (..., lab0, ...)` printed through `$LAB.prerr_label`, `d2s` through `prerr_d2sym`).
G3-12. **Dynload**: nothing to initialize (no toplevel `val` with a side effect): the four modules may be `dynload`ed anywhere after `pats_trans3_env_lstate`; link `pats_trans1.hats` is only a header
      (templates `glist_map_fun`, `glist_map_loop`: the module that instantiates them includes it).

### Validation (ATS1 reference = the objects of `src/`; `SRC=<main tree>/src make -C test t3g3compare`, `make -C test t3g3test|t3g3dump_asan`, `sh t3g3gcov.sh`, `python3 t3g3mutate.py REF.out REF.err`)

* `make check` of `src2` typechecks the four modules and the new `pats_trans3.sats` (target `checkg3`); they also compile (`patscc`) and link into `test/t3g3dump`.
* **Method.** The functions of the four modules depend on trans3_env, the solver and (for the trees) on functions that belong to the other groups, so they are tested as a part of the
  level-3 test (`t3_gen.py`: the compat layer `K_<CON>`, the dumpers `dd_<T>`, the pervasive constants of `fam_setup`): `test/t3g3_gen.py` + `t3g3_cases.py` generate ONE neutral program
  (ATS1/ATS2 common subset, 43 scenarios in 26 chunks, 42.8k lines at `G3SCALE=2`, seed `G3SEED=1`) from the scenario families `p2at`, `selab`, `lvalres`, `fldfrat`, run by the ATS2 driver `t3g3dump.dats` and the ATS1
  driver `t3g3dump1.dats` (`t3g3dump1.sh`, linked with the ATS1 `pats_trans3_{p2at,selab,fldfrat,lvalres}_dats.o`). The functions of the other groups are TEST DOUBLES written twice
  (`t3g3env.tmpl`: `d2exp_trup` makes a `d3exp_int`/`d3exp_var`/error expression of the node, the others record "G3 .." on stdout and return a fixed result, `intrep_syn_type_ind` is `g1int (int, len rep)`);
  the wrappers `g3_xxx` (`t3g3hand.tmpl`) call a function, dump its result completely, then the d2vars that it updated (`chk_d2var`, the view variables of by-reference arguments, the variables
  of the translated pattern), the static errors (`prerr_the_staerrlst`) and the number of the errors of the translation (`t3chk`); the scope of the environment (the hypotheses and the
  constraints that the functions add) is dumped after each call (`trans3_env_pop`).
* The pairs (pattern, type) are generated well-formed (every constructor of `p2at_node`, records with labels in any order and omissions, lists, `exist` with 0..3 variables, references,
  `refas`, `vbox`, annotations) and mutated (wrong types, wrong constants, too few arguments, other boxity, other sorts); the selections are on records, arrays (1-2 indexes, nested), existential
  types, linear components, with linear/mutable/plain variables; the proof manager holds at-views of records and arrays for `s2addr_exch_type`, `foldat` and `freeat`; the effect environment
  is pushed with sets that forbid `ref`/`wrt`.
* **Result**: stdout 25607 lines, stderr 14082 lines **identical** in ATS1 and ATS2 (`t3g3compare`; exit 0; `t3g3dump.md5` is the md5 of the ATS1 output, `make t3g3test` checks the ATS2 build without ATS1); seeds 2 and 3 and `G3SCALE=5 G3SEED=4`
  (106 scenarios, 106k lines, stdout 63904 lines, stderr 34313) are identical too; `make t3g3dump_asan` (AddressSanitizer, leak detection on): no error, no leak report, same stdout/stderr (the linear
  temporaries are all consumed; the trees are in the arena). The existing level-3 test (`t3test`, `t3compare`) still passes with the extended `pats_trans3.sats`.
* **Coverage** (`sh t3g3gcov.sh`, gcov by ATS line): p2at 864/869 (99.4%), selab 495/516 (95.9%), fldfrat 111/111, lvalres 263/274 (96.0%); the rest: the dead code of G3-9 (f), the `assertloc` of G3-9 (d),
  the `exitloc` of G3-9 (g), the unused `prerr_FILENAME`.
* **Mutation test** (`python3 t3g3mutate.py REF.out REF.err`, 165 deliberate bugs in the four modules: every sign/comparison/branch/order of the pattern checks, the proof arguments, the by-reference variables,
  the arity errors, records (omissions, rest, boxity, proof arity), lists, `exist` (sorts, binding), `vbox`, annotations, the index checks and the constraints of the array selections, the context of a
  selection, the linear selection (type, linear value, topization), `fold@`/`free@`, the restoration of a left value (mutable, linear, pointer, view), closures, the restoration of arguments, the texts of the
  messages): **159/165 detected**. The six that are not are equivalent or unreachable: `s2exp_tyleq_solve_err (s2e_knd, s2e1_arg)` of `p2at_trdn_int` with the arguments swapped (the kinds
  are constants: the relation is symmetric), `lin >= 0` -> `lin > 0` in `p2at_trdn_lst` (`test_linkind (0)` is false anyway), `s2exp_errexp (s2rt_t0ype)` of `auxfind` of `fldfrat`
  (the sort of an error expression is never printed), the location `locarg` of the instantiation in `auxmain` (not recorded), `knd > 0` of `s2exp_fun_is_freeptr` (the `clo` case is a reference
  argument: `refval > 0` is tested first), the end of the list of `auxlst1` of `d3explst_arg_restore` (a MatchError in ATS1). The first run detected 137: the others (28) made me add the dumps of the d2vars
  that a call updates, of the scope after each call, and the targeted shapes (arrays of arrays, nested linear records, redex components, `without` views, extra labels, existential types with linear
  bodies).
* **Line-by-line review**: every function was compared with its ATS1 text twice, once while writing and once from a token diff of the two sources (comments removed:
  `difflib` over the tokens, every replaced/inserted/deleted run was read; the runs are the view matches, `glist` operations, the `trans3err_` prefix, the lifted closures and the guard rewrites).

### Notes for the integration of the trans3 port

* The four modules `staload "./pats_trans3.sats"` and implement the declarations of the group 3 block; link with the implementations of the functions of the repeated declarations (above).
* A test driver for the whole level 3 can reuse `test/t3g3_gen.py` as a template: the doubles of `t3g3env.tmpl` are the list of what the group 3 needs from the others, and their call order is in
  the "G3 .." lines of the stdout of `t3g3dump` (a real `d2exp_trup` etc. produces other trees but the same calls).
* `d2var_get_type_some` must be implemented by `pats_trans3_dynexp_up.dats` (it prints `T3E_d2var_typeless` for a variable without type).
* The hang of G3-9 (a) and the abort paths of G3-9 (c)-(e) are ATS1 behaviours: a whole-file test of the type checker only meets (a) if a source has an existential pattern with fewer binders than the
  quantifier of the type it is matched against (ATS1 hangs on it too: do not let such a file into a corpus without a timeout).

### Open problems / doubts (group 3)

* The hang of G3-9 (a) was met by the ATS2 build (the first run of the test generated it and had to be killed); that ATS1 hangs too is reasoned from its source (a tail call with the same arguments), not run. The tests avoid it (`nq <= nv`).
* `val-` MatchError messages differ from ATS1 (exit status equal); `exitloc (1)` of `P2Tlist` prints the location of this port's source line.
* `d3lablst_take` and the `Some` branch of `auxfinize` are not exercised (dead code in ATS1 as well).
* The match of `p2at_node_view` etc. allocates a view per match; `p2at_trdn` of a large pattern does one per node (fine for patterns, not measured on a real program).
* The test doubles of `d2exp_trup` etc. are written twice (`t3g3env.tmpl`, one text for both builds with `1|`/`2|` lines); the generator depends on Python's `random` (`G3SEED`, `G3SCALE`):
  `t3g3dump.md5` must be regenerated after a change of `t3g3_cases.py` (`make -C test t3g3dump1`, then the md5 of `/tmp/t3g3dump1.out`/`.err` as `t3g3cmp.sh` writes them).

## Level 3 translation, group 4 (decl/looping/assgn/deref/ptrof/viewat/xchng): pats_trans3_{decl,looping,assgn,deref,ptrof,viewat,xchng} (rules G4-1 .. G4-14)

Done (typecheck, link, differential test, see Validation): `pats_trans3_decl.dats` (`d2ecl_tr`, `d2eclist_tr`, `d2eclist_tr_errck`, the declarations: `val`, `var`, `prvar`, `fun`, `implement`, `staload`, `local`..),
`pats_trans3_looping.dats` (`d2exp_trup_loop`, `d2exp_trup_loopexn`: the dry-run, the invariants, break/continue), `pats_trans3_assgn.dats` (`:=`), `_deref.dats` (`!p`), `_ptrof.dats` (`addr@`),
`_viewat.dats` (`view@` and its restoration), `_xchng.dats` (`:=:`). 4.6k lines of ATS1 (without the sats), 4.65k of ATS2. Same file and function names as `src/`. The exports are in the block
"BEGIN group 4 .. END group 4" at the end of `src2/pats_trans3.sats` (the names, the argument orders and the results of `src/pats_trans3.sats`: 20 functions; the internal ones (`d2var_assgn_lin*`,
`s2addr_ptrof`, `d2exp_trup_ptrof_varsel/_ptrsel`, `f2undec_tr`, `v2ardec_tr`..) stay `extern` in their `.dats`, as in ATS1). The only test double that the port needs from the other groups is
the list of declarations of `test/t3g4/pats_trans3_others.sats` (see G4-13).

G4-1. **Method.** By hand from the ATS1 text, function by function (no script: the files are small and the rules of the earlier levels apply): `case+ x.d2exp_node of` is `case+ d2exp_node_view (x.d2exp_node ()) of ~D2Evar d2v => ..`
      with `| v => (d2exp_node_view_free (v); ..)` for a wildcard (rule 3 of "Arena AST", S2-10); the fields are `x.d2exp_loc ()`; `list_cons/list_nil` are `glist_view` (a match with a nested pair of lists is a pair of `glist_is_cons/_head/_tail`
      tests, no allocation); `Some/None` are `gopt_view`/`gopt_some`/`gopt_none`.
G4-2. **`val-D2Eassgn (d2e_l, d2e_r) = d2e0.d2exp_node` (MatchError)** is a `case+` on the view with `| v => (d2exp_node_view_free (v); assertloc (false); d3exp_errexp ..)` (M2-5, CG-1); the body of the ATS1 function became
      `d2exp_trup_assgn_main (d2e0, d2e_l, d2e_r)` (same for `viewat`, `viewat_assgn` (two matches, the inner one before `d2exp_lvalize` as in ATS1), `xchng`, `ptrof`, `d2ecl_tr_staload/_staloadloc/_dynload`). `val-Some (s2l) = d2var_get_addr (d2v)`
      is `assertloc (gopt_is_some (..))` + `gopt_unsome`. The `_` arm of a match on a `d2lval` frees the view first (`d2lval_view_free`), then does what the ATS1 arm does.
G4-3. **The proofs are gone** (T1-5, E3-1): `trans3_env_push ()`, `trans3_env_pop_and_add_main (loc)`, `the_lamlpenv_push_loop0 ()/_loop1 (i2nv, lsbis, post)`, `the_lamlpenv_pop ()`, `the_s2cstbindlst_push/pop/pop_and_unbind ()`,
      `the_effenv_push_set_if (isprf, efs)` / `the_effenv_pop_if (isprf)` (the `bool` is the `option_v`).
G4-4. **Lists.** `l2l (list_map_fun (xs, f))` is `glist_map_fun<a,b> (xs, f)` of `pats_trans1.hats` (head first, like ATS1: the order of the errors and of the stamps is kept); `list_map2_fun` (`f2undeclst_tr` aux_fini, `v2aldeclst_rec_tr`) and
      `list_map_cloptr` (`v2aldeclst_tr`, the closure captured `knd`) are small recursive loops with an accumulator reversed at the end, head first; `list_app_fun` of `v2ardeclst_tr` is a loop (`loop1`, all the
      `trans3_env_add_svar` come before any `v2ardec_tr`, as in ATS1); `list_extend (ind, d2e_r)` of the array subscript assignment is `glist_append (ind, glist_sing (d2e_r))`; `list_pair` is `glist_pair` (`pats_staexp2.hats`);
      `list_vt_free (s2ps)` stays (`s2explst_vt`).
G4-5. **Tuples and options.** `s2exp_get_dlablst_linrest_sharing` returns the flat `@(s2exp, s2explst_vt)` (`val @(s2e_sel, s2ps) = ..`), `s2exp_metfun_load` the `Option_vt @(s2exp, s2rtlst)`. `d2expopt`, `d3expopt`, `s2expopt`,
      `s2ctxtopt` are `gopt`s (`var ctxtopt: s2ctxtopt = gopt_none((*void*))`: a comment glued to the call is P9). The `s2expopt_vt` that ATS1 got by `$UN.castvwtp1{s2expopt}{s2expopt_vt} (os2p_test)` (the result of
      `un_s2exp_bool_index_t0ype`, used by both `hypadd_propopt_neg` and `hypadd_propopt`) is `gopt_make_option_vt (..)` made once: one never freed arena cell per loop, the `option_vt_free` is gone.
G4-6. **Messages.** `prerrln! (..)` (every argument one `prerr_*` call, then `prerr_newline ()`), `println! (loc0)` / `println! ("d2ecl_tr: d2c0 = ", d2c0)` of the default arm of `d2ecl_tr` are `$LOC.print_location` / `print_d2ecl` + `print_newline ()`: the
      texts are those of ATS1 (compared on stderr by the test). The default arm (`D2Cerrdec`, a constructor that `d2ecl_tr` does not know) prints, then `assertloc (false)` (an exception in ATS2 as in ATS1) and `$extfcall (void, "exit", 1)`
      (T1-7; `exit` is `void` in C, a value of another type does not compile); the arm returns `d3ecl_none (loc0)` after it (never reached).
G4-7. **`s2cst_set_isabs`** is commented out in `pats_staexp2.sats` (internal); `pats_trans3_decl.dats` declares it again with the C name `ext#patsopts2cst_set_isabs`, exactly as ATS1 did (`pats_staexp2_scst.dats` implements it).
G4-8. **`filenv_get_d3eclistopt`** is declared in `pats_trans3_env.sats` and was implemented by ATS1's `pats_trans3_env.dats`; the port of that file does not link `pats_trans2_env.dats` (E3-5 says trans2 should have implemented it:
      it did not), so it is implemented in `pats_trans3_decl.dats`: `$UN.ptr0_get<d3eclistopt> ($TRENV2.filenv_getref_d3eclistopt (fenv))` (a null word is `None`, T2-3). `d2ecl_tr_staload/_staloadloc` store the translated list with
      `$UN.ptr0_set<d3eclistopt> (p, gopt_some (d3cs))`. A driver must not implement `filenv_get_d3eclistopt` again.
G4-9. **Termination metrics.** `d2exp_metfun_load` (ATS1: a `:<cloref1>` `aux`, `!ref := d2vs_fun`) is a plain recursion with `set_d2varlstref_val (ref, d2vs_fun)` (D2-3); `termet_sortcheck` keeps the ATS1 rules (`sgn < 0`: the longer
      list of sorts becomes the reference, the shorter one is a prefix), `os2ts0` is the `&s2rtlstopt` argument; the list of the variables of a recursive group (`d2vs_fun`) is shared by all the metrics (one `glist`).
G4-10. **Local functions** (`auxerr_*`, `aux1..aux3`, `auxEnter/auxBreak/auxContinue` with their nested `auxitm*`) are the same functions, `fun` in a `local` (no free variable, so nothing was lambda-lifted); `d2exp_trup_loop_dryrun`'s
       `aux` is a top-level `d2exp_trup_loop_dryrun_aux` (`glist_map_fun` needs a function value); the untyped parameters of `auxck_addreq` (`s2e1, d3ls, s2e2`) are typed.
G4-11. **Kept as in ATS1** (the test covers them): `auxerr_none` of `looping` reports `T3E_d2var_some` (not `_none`) and its message has no space before "but it should be consumed"; `auxlabs` of `viewat` stops at the first non-label (dead
       code); `s2addr_set_viewat_check` computes `s2e_old` only for its error message; `d2exp_trup_viewat` prints `"[view@] operation cannot be applied: "` with a trailing space and nothing after it; the unused `auxerr1` of `viewat` and the
       commented checks stay; `d2var_assgn_lin01` increments the linear value before looking at the labels; `d2exp_trup_deref` ignores the labels when the dereferenced value is a `lazy`/user-defined dereference (the ATS1 comment "[d3ls] is
       ignored!!!"; the no-GC rule "nonlinear [lazy] is no longer supported" is in the ATS1 source of `aux3`).
G4-12. **Dependences on the other groups** (functions of `src/pats_trans3.sats` that these modules call; the port must declare them with these names and these conventions): `d2exp_trup (d2e): d3exp`, `d2exp_trdn (d2e, s2e): d3exp`,
       `d3exp_trdn (d3e, s2e): d3exp`, `d2lablst_trup (d2ls): d3lablst`, `p2at_trdn (p2t, s2e): p3at`, `p2at_syn_type (p2t): s2exp`, `d2exp_syn_type (d2e): s2exp`, `d3lval_set_pat_type_left (d3e, p3t): void`,
       `d2var_get_type_some (loc, d2v): s2exp` (already in the sats), `d2exp_trup_applst_sym (d2e0, d2s, d2as): d3exp`,
       `s2exp_get_dlablst_linrest_sharing (loc0, s2e, d3ls, linrest: &int, sharing: &int): @(s2exp, s2explst_vt)`, `s2exp_get_dlablst_context (loc0, s2e, d3ls, context: &s2ctxtopt): s2exp`,
       `s2addr_exch_type (loc0, s2l, d3ls, s2e_new): s2exp`. They must also call my entry points where `d2exp_trup` of ATS1 does: `D2Eptrof` -> `d2exp_trup_ptrof`, `D2Eviewat` -> `d2exp_trup_viewat`, `D2Ederef (d2s, d2e)` ->
       `d2exp_trup_deref (loc0, d2s, d2e, glist_nil ())`, `D2Eassgn` -> `d2exp_trup_assgn`, `D2Exchng` -> `d2exp_trup_xchng`, `D2Eloopexn knd` -> `d2exp_trup_loopexn (loc0, knd)`, `D2Efor/D2Ewhile` -> `d2exp_trup_loop`,
       `D2Eselab` of a left value in `lvalres` -> `s2addr_exch_type`/`s2addr_set_viewat`, `selab` -> `s2addr_deref`.
G4-13. **Typechecking before the merge.** The modules cannot see the declarations of G4-12 in the `pats_trans3.sats` of this branch. `test/t3g4/stage.sh DIR` makes DIR a directory of links to `src2/` where `pats_trans3.sats` is the real one followed by
       `test/t3g4/pats_trans3_others.sats` (the declarations of G4-12, written with the conventions above). `make -C src2 check` runs it (`checkt3g4`, `T3G4DATS`, directory `t3g4stage/`, not in git); everything the test links is read through that directory
       (the C names of the functions of a `.sats` contain the path of the `.sats`: all the units of one program must read `pats_trans3.sats` at the same path, also after the merge). **After the merge** of the four groups: add `T3G4DATS` to `DATS`, delete
       `checkt3g4`, `t3g4stage`, `test/t3g4/pats_trans3_others.sats`, `stage.sh`, and compile the group-4 objects of `test/Makefile` from `$(M)` (`g4stage` rule); the real implementations then replace the doubles of `test/t3g4/g4env.tmpl`.
G4-14. **Unsure / for the integration agent**: (1) the conventions of G4-12 are my guess (they follow the earlier ports); a different result type in another group (e.g. `s2exp_get_dlablst_context` returning a tuple) needs a one-line change here.
       (2) the lists of the trees that I only traverse (`d2lablst`, `d3lablst`, `i2nvarglst`, `lstbefitmlst`) are read with `glist_is_cons/_head/_tail` or `glist_view`; nothing is copied. (3) `v2aldec_tr` reads `p2atcstlst_comp (glist_sing (p2at2cst (p2t_val)))`: it
       aborts (`INTERROR`, PC-7) on a pattern that `p2at2cst` does not know, exactly as ATS1 (the test avoids them). (4) `d2eclist_tr` is not tail recursive on the number of declarations (`glist_map_loop` is, but `d2ecl_tr` of `D2Clist`/`D2Clocal`/`D2Cinclude`
       recurses on the nesting depth only). (5) the staload cache: `d2ecl_tr_staload` translates the declarations of a file only when `filenv_get_d3eclistopt` is `None` (checked by the test through a second `D2Cstaload` of the same `filenv`).

### Validation (ATS1 reference = the objects of the main tree `src/`; `make -C test g4dump|g4dump1|g4compare|g4test`, `sh g4gcov.sh`, `python3 g4mutate.py`)

* **Method**: the machinery of `t3_gen.py` (K_<CON> wrappers, complete dumpers `dd_<T>` of every tree, the doubles of trans2_env/trans3_env, `d2var_get_type_some`), a new generator `test/g4_gen.py` of ONE program of scenarios in the common
  subset of ATS1 and ATS2, compiled by `g4dump.dats` (ATS2, every file read through `t3g4stage`) and by `g4dump1.dats` (ATS1, linked with `$SRC/*.o` of the main tree, including the ATS1 objects of the 7 modules: `g4dump1.sh`, ATS1 environment
  as for `t3dump1.sh`, `SRC=<main tree>/src`). The functions of the other groups are test doubles written once for both languages (`test/t3g4/g4env.tmpl`: `d2exp_trup` that dispatches to the group-4 functions exactly as the real one
  (variables, `top2` literals, sequences, ints, `ptrof`, `viewat`, `deref`, `assgn`, `xchng`, `loopexn`), `d2exp_trdn`, `d3exp_trdn`, `d2lablst_trup`, `p2at_trdn`.., and the selections `s2exp_get_dlablst_linrest_sharing/_context`, `s2addr_exch_type`,
  `d2exp_trup_applst_sym`, driven by "knobs" that the scenarios set: the value of `linrest`/`sharing`, a context or none (a real `s2ctxt` with a hole), the propositions, the selected type); every double prints its arguments, so the order of the
  calls and the arguments are compared too. The state of the doubles is in `g4state.c` (one copy for the two languages), the wrappers of the functions with an `&s2exp? >> s2exp` argument in `t3g4/g4pre.tmpl`.
* **Scenarios** (346 at `G4SCALE=3`, 70 chunks, 91k lines): a scope (`trans3_env_push`, `the_d2varenv_push_let`, `the_pfmanenv_push_let`, an effect set), 1-3 mutable variables (`d2var_mutablize_none`, so the real at-views are in the proof manager), pointer, reference,
  lazy and linear variables (some without a type), random "safe" types (base types, tuples of every kind, at-views, `top`, `without`, linear/proof variables: no application of a random constant, the solver aborts on those, S2B-5). Families:
  `lval` (`:=`, `:=:`, `addr@`, `view@`, `view@ :=`, `!p`, `!p := ..`, `!p :=: ..` on left values of every shape that `d2exp_lvalize` knows (variables mutable/linear, selections, dereferences of a pointer/reference/lazy/non-pointer, array
  subscripts, overloaded selections, `view@`, non-left values)), `addr` (the `s2addr_*` functions and `d2exp_trdn_xchng(_deref)` called directly with known and unknown addresses, all the knob settings), `ctx` (forced contexts and linear selected
  types: the new type of the view), `loop` (loops with random invariants/metrics/tests/bodies with assignments, exchanges and break/continue, `d2exp_trup_loopexn` under every kind of loop marker), `decl` (`d2ecl_tr`, `d2eclist_tr`, `d2eclist_tr_errck` on
  every declaration: abstract-type assumptions with the three states of `isabs`, `reassume`, `val`/`val rec` with refutable patterns, `var`, `prvar`, function groups with metrics (compatible and incompatible), `implement`, `staload` twice, `staloadloc`,
  `dynload`, `local`, `include`).
* **Result: stdout 32457 lines and stderr 9951 lines (the `prerr` of the errors and of the doubles' traces), byte-identical in ATS1 and ATS2** (`g4compare`; also at `G4SCALE=1` and `4`; `g4dump.md5` keeps the md5 of the ATS1 output: `make g4test` checks the ATS2 build without ATS1, and is in `all`).
* **Coverage** (`sh g4gcov.sh`, gcov by ATS line, `-O0 --coverage`): **1941 of 1973 executable lines (98.4%)**: decl 500/511, looping 411/413, assgn 263/265, deref 123/123, ptrof 141/143, viewat 261/274, xchng 242/244. The rest: the MatchError arms
  (`val-D2Cstaload` etc.), the `exit` arm of `d2ecl_tr`, the unused `auxerr1` of `viewat`, the arm (variable had a type before the dry run and none after: a consumed linear variable, which the double of `d2exp_trup` does not do).
* **Mutation test** (`python3 g4mutate.py REF.out REF.err`, 40 deliberate bugs in the 7 modules: the effect set of a `prval`, the loop kinds of the constraints, the hypotheses of the test, the dry-run reset, the linear values, the order of the arguments
  of `array subscript :=`, `topize` kinds, `d3exp_sel_ptr` locations, the error arguments, the checks of the effects, the order of the pops of `local`, the comparison of the labels of an address, the arguments of `auxck_addreq`..): **38/40 detected**; the two
  that survive are equivalent mutants (`d2var_set_mastype (d2v2, d2var_get_type (d2v))` vs `_get_mastype`: both are the pointer type just after `d2var_mutablize`; the constructor of the error `T3E_s2addr_assgn_deref_proof`: the errors are only counted).
  (The first run detected 28 of 39: the others made me dump all the cells at the end of a scenario (`C.finish`), the views after every operation, give the double of the context a real hole, add the `ctx` family and the decl groups.)
* **AddressSanitizer** (the 7 modules compiled with `-fsanitize=address`, the others as is, leak detection on): the whole run: no error, no leak, same stdout and stderr.

## Level 3 integration: the four groups of the type checker in one unit (rules I3-1 .. I3-10)

Done (typecheck, link, whole-file differential test, see Validation): the 20 modules of the type checker (`pats_trans3_{error,syncst,util,dynexp_up,dynexp_dn,appsym,caseof,patcon,p2at,selab,fldfrat,lvalres,decl,looping,assgn,deref,ptrof,viewat,xchng}.dats`
and the environment) are one unit: `pats_trans3.sats` is the single interface, `make -C src2 check` typechecks all of them for real (the notes of each group above are kept; where they speak of
staging directories, `pats_trans3_others.sats`, `T3G*OTHERS` or "after the merge", that is done).

I3-1. **What was removed**: `checkt3g1`/`checkt3g2`/`checkt3g4`/`checkg3` and the staging directories (`t3g1.build`, `t3g4stage`, `$(G2STAGE)`), the copies of `pats_trans3.sats` that were followed by the declarations of the other groups,
      `test/pats_trans3_others.sats`, `test/t3g2/pats_trans3_others.sats`, `test/t3g4/pats_trans3_others.sats`, `stage.sh`, `t3g1_mk.sh`, the knobs `T3G2_OTHERS`/`G2OTHERS`, the `g4stage` rule. The group tests (`t3g1`, `g2test`,
      `t3g3test`, `g4test`) keep their doubles of the other groups (they are drivers, not staging) and now compile the modules from `src2/` against the real `pats_trans3.sats`; their mutation/coverage scripts work on a link farm
      (`test/linkfarm.sh DIR`: symbolic links to src2, a mutant replaces one link). The md5 files of the four group tests did not change.
I3-2. **`pats_trans3.sats`**: the blocks of the groups in the order of the integration, ONE declaration per function (13 repeated declarations of the group blocks were dropped: `d2exp_trup`, `d2explst_trup`, `d2exp_trup_var_nonmut`,
      `d2exp_trup_deref`, `s2addr_deref`, `s2addr_set_viewat`, `p2at_trdn_con`, `intrep_syn_type(_ind)`, `float_syn_type`, `i0nt_syn_type(_ind)`, `f0loat_syn_type`). The signatures that the groups assumed of each other agreed (the
      conventions of PORTING.md were the same in the four ports: `glist` without length index, flat tuples, `serr: &int`), no call site had to change. `p3at_mutablize` (declared in ATS1, implemented but never called) is not declared.
I3-3. **What the earlier slices needed from the type checker**: `s2exp_hnfize_flag_svar` (`pats_trans3_env.dats`), `s2exp_tmp_instantiate_tmpmarglst` with the C name `patsopt_s2exp_tmp_instantiate_tmpmarglst` (the declaration of
      `pats_trans3_env.sats` now has the `ext#` name, the one of `pats_trans2_dynexp.dats` is the same function; flat `@(s2exp, t2mpmarglst)`), `trans3_env_d2con_instantiate` (implemented in `pats_trans2_p1at.dats`: one line, `d2con_instantiate`),
      `d2var_get_type_some` (`pats_trans3_dynexp_up.dats`), `filenv_get_d3eclistopt` (once, `pats_trans3_decl.dats`; a driver must not implement it). The driver entry points are those of `src/pats_main.dats`: `$TRENV3.the_trans3_env_initialize ()` once
      (after the prelude load), `d2eclist_tr_errck (d2cs)` (RAW: `d2eclist_tr` and `the_trans3errlst_finalize ()` after the dump), `$TRENV3.the_trans3_finget_constraint ()`.
I3-4. **The whole-file driver** (`test/f3dump.dats` ATS2, `f3dump1.dats` ATS1 linked with `$SRC/*.o`, `f3dump.cats`, shared with the level 2 test): what `pats_main.dats` does up to the type checker:
      `the_trans1_env_initialize`, `the_trans2_env_initialize`, `the_prelude_load` (as `t2dump.dats`), `the_trans3_env_initialize` once, then per file parse, `d0eclist_tr_errck`, `trans1_finalize`, `d1eclist_tr_errck`,
      `d2eclist_tr_errck` (RAW: `d1eclist_tr`/`d2eclist_tr`, the error lists are finalized after the dump), `the_trans3_finget_constraint`; the `d3eclist` and the `c3nstr` are dumped COMPLETELY (`f3dd.hats`, generated by
      `f3_gen.py` from the specs of staexp2/dynexp2/dynexp3/trans3_env through `t3_gen.py`/`t2_gen.py`: every constructor and field, the cells with stamps and mutable fields in full at first sight, the `filenv` of a staload
      through its `d3eclistopt`). A file on which the process is still busy after 60 s (alarm) is skipped identically by both sides (`TIMEOUT idx` in the output, `f3chunk.sh`; this is the ATS1 hang of `p2at_trdn_exist`);
      an exception or exit ends the process, `f3chunk.sh` restarts after it (as `d1chunk.sh`). `f3norm.sh` drops the text of an aborted assertion (ATS1: `exit(ATS): [assert] failed: LOC`, ATS2: LOC of the port), which
      differs by construction. The working directory is part of the search path of includes: reference and port must run in the same directory.
I3-5. **Commands**: `make -C src2/test f3dump f3dump1` (ATS1 environment as for `t2dump1.sh`, `SRC=<main tree>/src`), `FILTER='/(prelude|libats|src|src2|doc/EXAMPLE|contrib)/' sh f3files.sh` (`make f3files`),
      `make t3filestest` (hand-written cases `t3cases/`, md5 in `t3cases.md5`, no ATS1) / `make t3filescompare`, `sh f3gcov.sh LIST` (line coverage), `python3 f3mutate.py LIST` (mutation), `make f3dump_asan f3dump_o2`.
      /tmp is a tmpfs: the full dumps are 15 GB; `f3files.sh` removes identical outputs chunk by chunk, `f3runmd5.sh` keeps only md5 sums, `f3gcov.sh` runs in `EXTRA=time` mode.
I3-6. **Bugs found by the integration**: none in the 20 modules. The only real changes: the C name of `s2exp_tmp_instantiate_tmpmarglst` in `pats_trans3_env.sats` (link error of the whole program), `trans3_env_d2con_instantiate`
      (never implemented outside the test doubles), the removal of repeated declarations. The groups' notes (G3-9 hang etc.) were met as documented; no file of the corpus hit the 60 s alarm.

### Validation (ATS1 reference = the objects of the main tree `src/`; `make -C test f3files|t3filestest|t3filescompare|f3dump_asan|f3dump_o2`, `sh f3gcov.sh`, `python3 f3mutate.py`)

* **Whole files** (`f3files.sh`, FILTER prelude|libats|src|src2|doc/EXAMPLE|contrib, modes FILE and RAW, chunks of 30, 26 jobs, 1m50): 2528 files = 5056 translations, **identical** stdout (15.7 GB of dumps, 3644 complete
  trees with their constraints) and stderr (124815 lines) in every chunk; 1719 runs end in an exception (592 FatalErrorExn, 10 interr, 28 fixity, 434+270+222 trans1/trans2, 21 trans3 in FILE mode and 142 in RAW mode),
  0 files killed by the alarm. About 1700 FILE translations reach the type checker without error before the dump (the speed list).
* **Hand cases** `t3cases/` (14 files: lambdas, let/where, control, dependent types, linear data, templates/overloads, views and pointers, references, patterns, untyped lambdas/literals, applications/effects/constructors,
  downward typing, call-by-reference, linear closures/loops/metrics; 600+ deliberate type errors): identical in both builds; `t3cases.md5` is the md5 of the ATS1 output, `make t3filestest` needs no ATS1.
* **Coverage** (gcov by ATS line, corpus + cases): trans3 modules 44-95% of the executable lines (dynexp_up 83, dynexp_dn 89, appsym 91, caseof 95, decl 93, looping 88, p2at 71, viewat 69, xchng 71, assgn 71, ptrof 85);
  the rest is the MatchError arms, error paths of rare constructs and `pats_trans3_env_print` (never called).
* **Mutation** (`f3mutate.py`, 30 deliberate bugs in 17 modules; the corpus + cases, 170 chunks of 30 lines; the unmutated copy is checked against ATS1 first: 0 chunks differ): **19 of 30 detected**. The 11 not detected
  are conditions of the form `lin > 0` -> `lin > 1`, `err > 0` -> `err > 1` on values that are 0 or 1, error counters whose only effect is a message sign, and rarely reached branches (llam capturing, selab linrest, assgn sharing):
  the suite has no case that reaches them; they are candidates for more cases. (The first run of the script reported 24/24: the copy ran in another working directory, which is part of the include search path.)
* **AddressSanitizer** (`make f3dump_asan`, leaks on, every 8th line of the corpus + the cases, 662 translations): no memory error; the only leak reports are the linear accumulators of `glist_map_loop` in `pats_trans1_decl`
  on the path of an exception (as in levels 1 and 2); stdout identical to the plain build.
* **Speed** (`make f3dump_o2`, the 1700 FILE translations that reach the dump, in one process, time mode, prelude load included): ATS2 -O2 17.5 s, ATS1 (objects of `src/`) 14.9 s.
* **Earlier suites after the integration**: `make -C src2 check` (233 typechecks), `t3test`, `t3g3test`, `g4test`, `g2test`, `t3g1` all give their md5.

### Notes for constraint3, ccomp and the driver

* `the_trans3_finget_constraint ()` returns the whole `c3nstr` (kind `C3TKmain`, `C3NSTRitmlst`), read with `c3nstr_node_view`, `c3nstr_kind ()`, `c3nstroptref_val`; call it once per main file after `d2eclist_tr_errck`.
* typerase reads the `d3eclist` and the `filenv_get_d3eclistopt` of each staload (a null word is `None`); both are filled by `d2ecl_tr_staload`.
* A driver of several files calls `the_trans3_env_initialize ()` once per process; the error list is cumulative (`the_trans3errlst_finalize` raises again for the errors of earlier files).

### Open problems (integration)

* 11 of the 30 mutants are not caught (above): more cases for linear closures, selection from linear records, `sharing`, exchange errors.
* The group tests still carry their own doubles of the other groups; they duplicate part of what the whole-file test now checks and may be retired.
* Aborted assertions print the location of the port's source, not ATS1's (normalized by `f3norm.sh`).

### Level 3 integration, test hardening

Added 18 hand-written cases to `test/t3cases/` (viewat, xchg, assgn, cbr, abort1-3, pat2, patcon2, lst, lamrec, dn2, loops2, decl2, sel, llam, ovl, lit): views/viewat, `:=:`, `:=`, call-by-reference,
patterns (defined constants, existentials, vbox, boxed/flat, arities, datacon decorations), untyped `val rec`/`fun` (syn_type), downward typing of lambdas/tuples/records, loops with linear states,
declarations (reassume/extype/metrics/var), selections and fold@/free@/addr@, linear closures, overloads and dot-symbols, literals. ATS1 vs ATS2 (`make t3filescompare`): identical, NO divergence found
in any module (all added regions behave as ATS1). `t3cases.md5` regenerated (new value 6f6f...); `f3anon.sh` now also drops the abort-location line of ATS1 (`.../src/pats_*.dats: N(line..) -- ..`),
which made `make t3filestest` fail for the abort cases (abort1: lvalres interror, abort2: patcst2 errpat, abort3: env_dvar check_llam). Pitfalls met: an evaluated `%(..)` float pattern, a
linear closure that preserves a captured variable and a call-by-reference on a selection without context END the process (kept as the abort*.dats); a pattern that binds fewer existential variables than
the type has hangs ATS1/ATS2 alike (G3-9a, never put in a case); `'[..]`/`list`/`$lst_t`/`$lst` on a prelude `list` do not exist in the no-GC prelude (the `list_t0ype_int_type` branch of
`p2at_trdn_lst` is unreachable); a trans1/trans2 error in a case drops only that declaration in RAW mode, so each file was iterated until it had none (the `error(2)` lines left are deliberate).
* Coverage (gcov by ATS line, corpus + cases), before -> after: env 89.4->89.7, env_dvar 87.9->93.1, env_effect 83.5, env_lamlp 81->88, env_lstate 79.1 (fprint code), env_pfman 85->85.8, env_print 0 (never called),
  env_scst 100, env_svar 63 (fprint), env_termet 95.6, error 100, syncst 78.6->85.3, util 72.6->88.7, dynexp_up 88.9, dynexp_dn 89.5->95.1, appsym 91.2->94.8, caseof 94.6, patcon 77.6->87.8, p2at 75.3->95.9,
  selab 83.7->95.3, fldfrat 87.4->95.5, lvalres 78.5->96.4, ptrof 84.6->97.9, viewat 69->93.4, deref 91.9->95.9, assgn 71.3->99.2, xchng 70.5->99.2, looping 93.2->97.1, decl 93.0->96.5, dynexp3 88.1->90.4.
  Below 90% what is left is mostly MatchError arms, `fprint_*` debug code (env_print, lstate, svar), empty case-clause lists (not parsable), the list_t branch of `$lst`, `D2Eliteral`, `lam@` bodies.
* Mutation (`f3mutate.py`, corpus + cases): **27 of 30** (cases alone: 26). Not detected: #6 (`npf > 0` -> `npf > 1` in `p2atlst_trdn_arg`: the `isprf` flag of the second proof argument is not
  visible in the dump), #13 (`termet_sortcheck`: `os2ts0 := os2ts` for a longer metric, no visible effect), #14 (`util` D2Elst `lin = 0`: needs the absent prelude `list`; equivalent in practice).
* Open: the group test `t3g1` no longer links (`d2var_get_type_some` is defined both by `t3g1dump.dats` and `pats_trans3_dynexp_up.dats`, a leftover of the integration, not touched here).
  Running `g2test` rebuilds tracked artifacts (`test/g2dump`, `test/obj/*.o`), which show as modified in git.

## ccomp group C1 (ccompenv/environ/caseof/looping/trywith/lazyeval): pats_ccomp_{ccompenv,environ,caseof,looping,trywith,lazyeval} (rules C1-1 .. C1-9)

Done (typecheck, link, differential test, see "Validation (C1)"): the six modules, 4.2k lines of ATS1, 3.5k of ATS2, same file names, same function names and external names as `src/` (the interface is `pats_ccomp.sats`,
the "ccomp interface" section, CC-1..CC-12). `make -C src2 check` typechecks them (`checkcc1`).

C1-1. **`ccompenv`** keeps the ATS1 shape: `datavtype ccompenv_vt = CCOMPENV of ccompenv_struct` (a flat `@{..}` with the linear stacks), `assume ccompenv_vtype = ccompenv_vt`. The pattern `CCOMPENV (!p)` of ATS1 is a syntax error
      in ATS2: use `val+ @CCOMPENV (p) = env` (`p.ccompenv_f`, `fold@ (env)` at the end). The initial struct is a RECORD LITERAL (`var p: ccompenv_struct = @{..}; CCOMPENV (p)`): assigning the fields of a `ccompenv_struct?` and then building
      the datavtype gives two different C struct types (gcc error). A nullary constructor of a linear datavtype (`MARKENVLSTnil`) is matched without `fold@`; a read-only traversal of the `markenvlst_vt` binds the tail by value
      (`MARKENVLSTmark (xs1) => loop (xs1)`), a mutating one uses `@MARKENVLSTcons_var (_, xs1)` + `fold@ (xs)`. `val-@list_vt_cons (x, _) = p.field` + `fold@ (p.field)` for the head of a stack.
C1-2. **Global state** (`the_exndeclst/saspdeclst/extypelst/extcodelst/staloadlst/dynloadlst/dyncstlst/dynconlst/funlablst`, the flag of `ccompenv_add_tempenver`, `the_toplevel_getref_*`) lives in cells of the global arena
      (`cell_make/get/set`, a word); a list is a `glist` newest first and `_get` returns `glist_reverse` of it and empties the cell (as the `list_vt_reverse` of ATS1). `d2cstset`/`d2conset` are the nonlinear sets of the libraries.
      `the_extcodelst_get` is a stable merge sort of the glist (comparison `pos1 - pos2`, `<= 0` takes the left one). `the_toplevel_getref_tmpvarlst/primdeclst` return the address of arena cells holding a `tmpvarlst`/`primdeclst`
      (nil at first): read and write them with `$UN.ptr0_get<tmpvarlst> (p)`.
C1-3. **Small data**: `looptmplab3` is the flat triple `@(init, fini, cont)` (`list_vt_free`), `tlcalitm` stays a `datavtype`; the stacks are `List0_vt` (`flabsetenv`, `dvarsetenv`, `vbindmapenv`: the sets and the maps are the avl trees of
      CC-5 / the nonlinear `d2varmap` of dynexp2, the latter with `<primval>`: `d2varmap_search<primval>`, `d2varmaplst_vt_insert<primval>`, `staload _ = "./pats_dynexp2_dvar.dats"`).
C1-4. **Options and lists** of the interface are `gopt`/`glist`: `case+ opt of Some/None` is `case+ gopt_view (opt) of ~GOsome/~GOnone`, `val-Some (x) = ..` is `val-~GOsome (x) = gopt_view (..)` (the MatchError when it fails, tested by the exit
      cases), tests of `tmpcstmat`/`tmpvarmat` are `tmpcstmat_is_TMPCSTMATnone` (the ATS1 `TMPCSTMATsome _ => opt | TMPCSTMATnone => ..` is one test), constructors are `tmpcstmat_TMPCSTMATnone ()`, `hiimpdec2_new (imp, tsub, tmparg)`,
      `hifundec2_new (hfd, tsub)`.
C1-5. **Names**: the `hidexplst_ccompv` that caseof.dats declares `extern` (a file-local function in ATS1, the C name carries the file) is `hidexplst_ccompv_caseof` here: the global `hidexplst_ccompv` is declared in the sats and
      implemented by `pats_ccomp_dynexp.dats`. `loopexnenv_free` is `list_vt_free`.
C1-6. **`funent_varbindmap_*`**: the global map `the_vbmap` is a cell holding the linear `d2varmap_vt (primval)` (taken out with `$UN.castvwtp0`, updated through `&`, put back).
C1-7. **caseof/looping/trywith/lazyeval** read the hidexp with `hidexp_node_view` (`val-~HDEloop (..) = ..`) and build the instructions with the `instr_*`/`primval_*` constructors of the interface; the order of the `val`s (hence of
      the stamps of tmplabs, tmpvars and funlabs) is that of ATS1. `hidexp_ccomp_ret_delay` ($delay) is kept although the no-GC rules reject `$delay` (it is the `lam`/`$ldelay` machinery: the code is shared in spirit).
C1-8. **What they call**: `hidexp_ccomp`, `hidexp_ccompv`, `hidexp_ccomp_ret`, `hiclaulst_ccomp`, `hidexp_ccomp_funlab_arg_body` (groups C2/C3), `*_tmpcst_match`/`*_tmpvar_match`/`funlab_tmparg_match` (template group), `the_d2varlev_get`
      (trans2_env), the printers of phase 1 (`fprint_tmpsub/tmpcstmat/tmpvarmat/hifundec2/hiimpdec2`; the print module needs `fprint_tmprimval` of claulst), `instrseq_*`, `funent_*`, `funlabset_*`, `d2envset_*` of phase 1.
C1-9. `fprint_ccompenv` prints only the markenvlst (as ATS1).

### Validation (C1) (ATS1 reference = the objects of the main tree `src/`: `SRC=<main tree>/src make -C test/cc1 compare`; `make -C test/cc1 test|cover|mutate|asan`)

* **`test/cc1/`**: `cc1_gen.py` generates ONE program of 80 scenarios (8 chunks, 21k lines, `CC1SEED=1 CC1SCALE=1`), written in the common subset of ATS1 and ATS2 (`cc1_common.hats`: the operations `op_*` that run a function of the six modules,
  print its result and the state; `cc1_impl.hats`: doubles; `cc1_lang1/2.hats`: the few constructors that differ), compiled by the ATS2 driver `cc1_drv.dats` (the modules of src2 + the modules of phase 1) and by the ATS1 driver
  `cc1_drv1.dats` (linked with the ATS1 objects of `src/`, without the ATS1 `_dynexp/_claulst/_decl/_hipat/_template/_subst/_hitype/_emit*/_main`). Families: 40 `env` scenarios (random sequences of ~60..100 operations on a
  ccompenv, a model of the depths of the stacks keeps them legal: counters, freecon/loopexn/tailcal/dvarset/flabset/vbindmap stacks, push/pop/localjoin, every `add_*`, the template matching through doubles, tempenver, the global lists, the
  stable sorting of the extcode, the set of the dynamic constants and constructors), 16 `environ` scenarios (random graphs of functions with levels, recursion, fnx groups: transitive closure, environments, `envful`, full argument types,
  the variable bindings of initize/initize2/uninitize), 24 `comp` scenarios (random trees of case/loop/loopexn/trywith/delay/ldelay/lazyeval compiled through the doubles of `hidexp_ccomp`, `hidexp_ccomp_ret`, `hiclaulst_ccomp`,
  `hidexp_ccomp_funlab_arg_body`, which record in comments the tmplevel/recdepth/tail-call flag/level at each leaf, bind variables inside scopes and look at the loop and tail-call stacks; the instruction trees are dumped completely
  by `dd_instr_deep`, the real printers print `INSloop(...)`). 25 cases end the process (`CC1EXIT=k`, `cc1_exit.hats`: every `val-` that can fail).
  **Result: stdout 16.6k lines and stderr 0 lines byte-identical in ATS1 and ATS2; the 25 exit cases fail in both with the same stdout** (`cc1_cmp.sh`); `cc1.md5` keeps the md5 of the ATS1 output (`make -C test/cc1 test` needs no ATS1; skipped while the
  modules of phase 1 are not in src2/). The phase-1 modules used are the real ones (tmplab, tmpvar, d2env, funlab, funent, instrseq, util, print, pats_ccomp); `cc1_dbl2.dats` is the double of the constructors/instrseq/funent kept for a tree without them.
* **Coverage** (`make -C test/cc1 cover`): gcov by ATS line (`--gline`, `-O0 --coverage`, the run and the 25 exit runs): ccompenv 1228/1231, environ 223/223, caseof 28/28, looping 45/45, trywith 20/20, lazyeval 64/64: **1608 of 1611 executable lines (99.8%)**; the 3 lines left are comment-only lines. Every function of `pats_ccomp.sats` that these
  modules implement in ATS1 is called, every operation of the common part is used by the scenarios (`cc1_cover.py`).
* **Mutation test** (`python3 cc1_mutate.py`): 102 deliberate bugs in the six modules (global lists, the printer, every counter and stack, loop labels, tail-call indices and tests, levels in the dvarset/flabset operations, maps,
  scopes, push/pop/join, the matching of instances, tempenver, the closure and environment computation, the variable bindings, every decision of caseof/looping/trywith/lazyeval): **102/102 detected** (101 in the first full run; the last one, the index of the tail-call function group, after a directed sequence was added).
  The first run missed 5 (the name of a staload file, the pervasive staload branch, the toplevel cells, and two patterns): I made the double of `filenv_get_name` depend on the file, added the directed sequence
  add_impdec/add_staload/tmpcst_match, and cells of different lengths.
* **AddressSanitizer** (`make -C test/cc1 asan`, leak detection on): no error, no leak report. Two more seeds at scale 3 (`CC1SEED=2|3 CC1SCALE=3`, 44k lines of output each) are identical in ATS1 and ATS2.
* **Line-by-line review**: every function of the six ATS1 files was read against its port (the ATS1 constructs mapped by C1-1..C1-7); then a mechanical check: the multisets of the identifiers and of the string literals of the
  comment-stripped ATS1 and ATS2 sources of each module were diffed: all string literals (the printed text) are identical, the identifier differences are only the ATS1/ATS2 vocabulary (`list_*` -> `glist_*`, `Some/None` ->
  `GOsome/GOnone`, `fold@`/`vbox`/`ref_*` removed, the helpers of the cells and of the stable sort).

### Notes for the integration agent, and doubts

* The test links the real modules of phase 1; whatever the C2/C3 groups implement differently from their ATS1 original does not matter here (doubles), but the signatures of `hidexp_ccomp*`, `hiclaulst_ccomp`,
  `hidexp_ccomp_funlab_arg_body` and the `*_match` functions are used as declared in `pats_ccomp.sats`. The printers of phase 1 print the instructions as ATS1 does (`INSloop(...)`, `INScaseof(...)`, `INStrywith(...)`:
  a differential test on the printers alone does not see the inner instructions).
* `pats_ccomp_print.dats` references `fprint_tmprimval` (implemented by claulst): a link without the claulst module needs a double (`cc1_impl.hats`).
* `ccompenv_free` frees the linear stacks; everything shared (cells, lists of the global state, the instructions) is in the global arena and is never freed.
* Doubts: `hidexp_ccomp_ret_delay`/`ldelay` are exercised through doubles only (the real `hidexp_ccomp_funlab_arg_body` is group C2's); `the_extcodelst_get` is now O(n log n) merge sort on an arena list (garbage per call).

## Constraint solving (constraint3): pats_constraint3{,_print,_icnstr,_simplify,_solve,_init,_mapgen,_jsonize}, pats_constraint3_appenv.hats (rules C3-1 .. C3-12)

Done (typecheck, link, differential test, see Validation): `pats_constraint3.{sats,dats}` (+ `pats_constraint3.spec`, generated `pats_constraint3_gen*.hats`, not in git, + `pats_constraint3.hats`: helpers),
`pats_constraint3_{print,icnstr,simplify,solve,init,mapgen,jsonize}.dats` and `pats_constraint3_appenv.hats`. The mapgen files are in the list of the task of "Tools": `c3nstr_mapgen_scst_svar` and
`c3nstr_export` (the `--constraint-export` output) need them. ATS1: 3.9k lines (with the sats), ATS2: 4.2k. Same file and function names as `src/`. `make -C src2 check` makes the generated file and
typechecks all of them.

C3-1. **`s3exp` is an arena AST** (`pats_constraint3.spec`, `--global --compact`, like `pats_staexp2.spec`): `s3exp_view (x)` for matching (`case+ s3exp_view (x) of ~S3Evar v => ..`), `s3exp_S3Evar (v)` the constructors,
      `s3exp_is_S3Evar`, `s3explst = glist (s3exp)`, `s3explst_vt = List0_vt (s3exp)`. The functions of the sats keep their names (`s3exp_var`, `s3exp_iadd`, `s3exp_make`...); the smart constructors normalize
      as in ATS1 (the ATS1 oddity `s3exp_unit = S3Enull ()` is kept). A match of a pair (`(S3Eisum xs1, S3Eisum xs2)`, `(S3Evar, S3Evar)`) is an `if` chain on `s3exp_is_X` in the order of the arms and the helpers
      `un_S3Eisum`.. of `pats_constraint3.hats` (S2B-2). The lists that `s3exp_iadd` builds (`list_vt`) become arena lists with `glist_make_list_vt`: the arena is never freed (it was the GC's).
C3-2. **Two `s3exp_type`**: `pats_lintprgm.sats` declares `abstype s3exp_type = ptr` (the `ICerr` payload, LP-8) and the generated one has the same name. The latter must be the last one opened: staloading
      a `.dats` opens the `.sats` it staloads, so `pats_constraint3_solve.dats` and the drivers `staload _` lintprgm*.dats BEFORE `staload "./pats_constraint3.sats"` (the error is
      "S2Ecst(s3exp_type) != S2Ecst(s3exp_type)"). `ICerr (loc, $UN.cast (s3e0))` as in ATS1.
C3-3. **The environment `s2vbcfenv`** is `absvtype s2vbcfenv_vtype = ptr`; the datavtype `s2vbclst` and the traversals are the ATS1 ones (`@S2VBCFLSTsvar (_, env1)` + `fold@`). The proof `s2vbcfenv_push_v` is dropped (T1-5):
      `s2vbcfenv_push (&env): void` and `s2vbcfenv_pop (&env): void` (one pop for each push; the ATS1 callers need `unit_v`-style axioms: `test/c3hand.tmpl`). `s2vbcfenv_extract` returns the flat `@(s2varlst_vt, s3explst_vt)`
      (oldest first, as ATS1).
C3-4. **The table of the special functions** (`s2cfunmap`, `s2cstmap (tfun)`, `tfun = (&s2vbcfenv, s2explst) -> s3exp`, the functions `f_add_int_int`.. of `pats_constraint3_init.dats`) is a plain function-pointer map
      (S2-3 `s2cstmap`); the map lives in a cell of the arena (`the_garena_alloc (sizeof<ptr>)`), `constraint3_initialize` takes it out, calls `constraint3_initialize_map (&map)` and puts it back. The user of `s2cstmap_*`
      has `staload _ = "./pats_staexp2_scst.dats"` (S2-4). `constraint3_initialize ()` needs the pervasive constants of `pats_stacst2` (the 35 `the_xxx` that `constraint3_initialize_map` inserts) in
      `the_s2expenv_pervasive_find`: call it after `stacst2_initialize ()`.
C3-5. **`s2varindmap (n)`** is `$LM.map (s2var, natLt (n))` of `libats/linmap_avltree` (real frees: `s2varindmap_free {n}`), the comparison is `implement $LM.compare_key_key<s2var> (x1, x2) = compare_s2var_s2var (x1, x2)`
      (rule 14). `s2varindmap_find` keeps the convention: 0 = not found, `n+1` otherwise (a repeated variable has the last index, as `linmap_insert`).
C3-6. **The solver module** (`pats_constraint3_solve.dats`): the kind of the integers is chosen by `#include "./pats_lintprgm_myint.dats"` (LP-1; `C3NSTRINTKND` of `pats_params.hats`, or `-DATS C3NSTRINTKND=intknd`), and
      `#include "./pats_lintprgm_solve.dats"` (NOT `staload _`: its templates use functions that are local to it, S2-4, `PMVerr` in the C). So the object of `pats_constraint3_solve.dats` defines the `indexset_*` functions:
      do not link `pats_lintprgm_solve.dats` apart. `pats_lintprgm.dats` and `pats_lintprgm_print.dats` are staloaded and linked/dynloaded (LP-1). `auxsolve<a>` takes the assumptions as `!s3explst_vt` (the linear list
      that `s2vbcfenv_extract` returns; ATS1: `$UN.castvwtp1{s3explst}`), builds the vectors in the order of ATS1 (the list `ics_asmp` is reversed, `ic_conc_neg` first) and frees them. `pats_constraint3_icnstr.dats` is
      staloaded after the sats (C3-2); its templates `s3exp2icnstr<a>`, `s3exp2myintvec<a>` are instantiated by the solver and by `test/c3dump` (direct tests).
C3-7. **Messages and errors**: `prerrln! (a, b)` is a sequence of `prerr_*` and `prerr_newline` with the same text (`prerr_error3_loc`/`prerr_warning3_loc` need `implement prerr_FILENAME<> () = prerr "pats_constraint3_xxx"` in the
      module, as ATS1); `c3nstr_ats2_solve` ends with `$ERR.abort<void> ()` (the exception `FatalErrorExn`) when something is unsolved. The `val-S2RTfun (_, s2t) = ..` of `s3exp_get_srt` (an application of a
      non-function: a nullary constant applied to no arguments) and the `val-list_cons` of `pats_constraint3_init.dats` are `$ERR.abort_interr<T> ()` (ATS1: MatchError): `FatalErrorExn_interr`, never raised by the compiler.
      `assertloc (false)` of `s3exp_bineq` (kind 0 on a constant) is kept.
C3-8. **`c3nstr`** (pats_trans3_env.spec): `c.c3nstr_loc ()`, `c.c3nstr_kind ()`, `c3nstr_node_view (c.c3nstr_node ())`; the ATS1 `ref (c3nstropt)` of `c3nstroptref` is `ctr.c3nstroptref_val ()` (E3-3):
      `S3ITMcnstr_ref` with `GOnone` ends the item list with "solved" (an ATS1 oddity: the rest of the items is not looked at). `c3nstr_solve_itmlst_disj` appends the branch in front (`glist_append (s3is, s3is0)`).
C3-9. **mapgen/export** (`pats_constraint3_mapgen.dats`, `pats_constraint3_appenv.hats`, `pats_constraint3_jsonize.dats`): as `pats_dynexp2_mapgen.dats` (`extern fun s2cst_app (x, env: !appenv)`, `#include "./pats_staexp2_appenv.hats"` and the
      new hats, the environment is a datavtype that is cast to `appenv`); `s2cst_app` marks the constant before it visits its definition (the recursion would loop otherwise); the sets are the persistent ones of S2-3.
      `c3nstr_mapgen_scst_svar` returns the flat `@(s2cstset_vt, s2varset_vt)`. `c3nstr_export` prints `{"s2cstmap": .., "s2varmap": .., "s2rtdatmap": .., "c3nstrbody": ..}` (`fprint_jsonval`).
      `jsonize_ignored<p2atcstlst> (p2tcss)` is a template (TL-9).
C3-10. **Dynload order** (after the list of E3-9): `jsonize`, `lintprgm`, `lintprgm_print`, `lintprgm_myint`, `constraint3` (its vals `s3exp_null`.. make intinfs and s3exps: after `pats_intinf`), `_print`, `_icnstr`, `_simplify`, `_solve`, `_init`,
      `_mapgen`, `_jsonize`, `jsonize_synent2` (`pats_main.dats` of ATS1 also loads the two `myint` files; here `pats_lintprgm_myint.dats` alone does the selection). Link `-lgmp` and `pats_error_sats.o`.
C3-11. **Not ported** (the sats declares them, ATS1 never implemented them either): nothing; `s2exp_metdec_reduce` and `s2exp_synlt/_synlte` are static in ATS1 and here.
C3-12. **Hints** (`print_icnstr`, `print_myintvec` ..) are those of `pats_lintprgm_print.dats` (LP-9); `s3exp` is printed by `print_s3exp` (`S3Ebineq(>=, S3Eisum(..))`, `S3Evar(x(7):S2RTbas(S2RTBASpre(int)))`).

### Validation (ATS1 reference = the objects of the main tree `src/`; `make -C src2/test c3compare | c3test | c3cover | c3mutate | c3asan`)

* **`test/c3dump`** (`c3dump.dats`, the same program for ATS1: `c3dump1.dats`, `c3dump1.sh`) is an INTERPRETER: it reads the problems of a data file (`c3_gen.py data`; one problem per line of integers, `c3_probs.py` is the generator,
  `c3_ops.py` the table of the 150+ operations, `python3 c3_probs.py dec < c3data_gmp.txt` prints a problem readably) and runs them with the real modules, printing every result with the printers of the modules and the dumpers of
  the level-3 test (`t3_gen.py`: the compat layers `K_..`, `dd_..` are those of `make t3gen`, also for ATS1). A problem is a sequence of operations on typed registers (variables, constants, sorts, static expressions, s3exp, items,
  constraints, the environment of the solver): create cells (`s2var`, `s2cst` of every sort, `d2var`, `d2con`, `s2Var`), build static expressions with the 118 pervasive constants (`add_int_int`.. through `ifint_bool_int_int`,
  addresses, classes `lte_cls_cls`, metrics `S2Emetdec` on integers and on `types` terms, `sizeof`, applications of abstract constants and of variables, tops, errors), `s3exp_make`/`lintize`/the s3exp algebra (every smart constructor and every
  raw node, `syneq`, `isgte`, `get_srt`, `get_fvs`), the environment (`add_svar`, `add_sbexp`, `find_nonlin/cstapp`, `replace_nonlin/cstapp`, `add_cstapp/nonlin`, push/pop, `extract`), `s3explst_solve_s2exp`, `s3exp2icnstr`/`s3exp2myintvec`/`s2varindmap`
  directly, constraint trees (`c3nstr` of every kind: `C3NSTRprop`, `itmlst` with variables, hypotheses prop/bind/eqeq, nested constraints, `cnstr_ref` none/some, disjunctions, `sVar`, `solassert`, every `c3nstrkind` incl. case exhaustiveness
  with `p2atcst` lists) through `c3nstr_ats2_solve` (the exception `FatalErrorExn` of an unsolved constraint is caught and printed), `fprint_c3nstr`, `jsonize_c3nstr`, `c3nstr_export` and `c3nstr_mapgen_scst_svar`.
  The generator makes 8 families: `make` (random hypotheses and conclusions, s3exp_make/lintize/solve), `real` (the shapes of the type checker: bounds of arrays `0 <= i < n`, lengths `n+m`, metrics `n-1 < n`,
  loops, division, products), `s3` (the s3exp algebra), `c3` (random constraint trees whose hypotheses are true under a planted assignment: every kind of constraint is solved, residual, or rejected), `env`, `icn`, `h3` (`h3ypo`, `s3explst_make`,
  `s3exp_make_s2cst_s2explst` of 35 constants), `exp` (the export: sorts that are functions, tuples, datasorts, variables, errors; data constructors). The generator respects the preconditions that stop ATS1 (a
  binding must not be cyclic, a function sort must be applied, `s3exp_bineq` of kind 0).
* **Result**: 25800 problems with the gmp integers (`c3data_gmp.txt`, 587k lines of stdout, 11.1k of stderr: the error messages of the solver, warnings, the exceptions; 5072 problems end in `FatalErrorExn`: a
  constraint that is not solved, or a shape that `s3exp2icnstr` rejects) and 12400 with `intknd` (`c3data_int.txt`, 262k/5.5k lines; `c3dump_int`: pats_intinf,
  pats_lintprgm_myint, pats_constraint3_solve compiled with `-DATS C3NSTRINTKND=intknd`, the ATS1 side: the same three from the ATS1 sources): **stdout, stderr and exit status identical to ATS1 for both kinds**. `c3dump.md5` has
  the md5 sums of the ATS1 outputs (gmp stdout, stderr, int stdout, stderr): `make c3test` checks the ATS2 build without ATS1.
* **jsonize of level 2** (`test/j2dump`, see "Level-2 jsonize"): 147 scenarios, JSON text identical.
* **Coverage** (`make c3cover`, gcov by ATS line: `patsopt --gline`, `-O0 --coverage`, the two drivers together; the driver is instrumented too: it instantiates `s3exp2icnstr` for the direct tests): the 9 files
  **3109 of 3119 executable lines (99.7%)**: constraint3 625/627, _print 110/110, _icnstr 178/182, _simplify 435/437, _solve 288/288, _init 207/208, _mapgen 38/38, _jsonize 196/196, jsonize_synent2 961/961, the hats 71/72. The rest: the
  `abort_interr` of a `val-` that does not match (3), `assertloc (false)` of `s3exp_bineq` (it ends the process), the header lines of a `local` that gcov does not attribute. All the 112 functions and values that the two sats declare are called
  (by an operation of the interpreter, `j2_cases.py`, or by a function of the modules that is called).
* **Mutation test** (`python3 c3mutate.py c3`, 73 deliberate bugs in the 8 modules: the kinds and sorts of the constructors, the structural order of the metrics (and their lexicographic combination), the constants true/false, the order in which the arguments
  of an application are made (the stamps of the new variables), the relations of the constants applications and their order, which terms are nonlinear, `find_cstapp`/`find_nonlin`, `pop` of the environment, the negation of the
  constructors, the constants of `badd/bmul/beq`, the sign of a constant inequality, `icff`, the order of the terms of a sum (`isgte`), the merge of two sums, the products of atoms, `lintize` flags, the conversions of the booleans into
  vectors (`beq`, `bneq`, `badd`, `bvar`, `bdom`), the coefficients, an unknown variable, the index of the first variable, the conclusion that is not negated, the order of the assumptions, the case exhaustiveness, a solved constraint, the order of
  the branches of a disjunction, the messages, the divisions `/`, `ndiv`, `idiv` by a negative constant, `min`/`max`, the classes, the traversal of the constants, the JSON labels and separators, the sorts of the export):
  **73/73 detected**. The equivalent mutants found on the way were replaced (`lte >= 0` for `lte > 0` on a value that is 1 or ~1, `n+0`; the hint set of `indexset_make_s3exp` (`ind > 0` -> `ind > 1`) changes only the order in which the solver eliminates
  the variables and no answer changed on 38200 problems: it is not in the list). The first run missed 15 (the others of its 74 were detected): it made me add the problems of the families (syntactic equality of different constructors, metrics on `types`, non-constant application heads, classes
  with super classes, `bdom`, raw sums for the vectors, relations of constant applications found as nonlinear terms, definitions of constants that mention themselves), and the dependency of `c3obj/c3dump.o` on `pats_constraint3_icnstr.dats`
  (the direct tests instantiate its templates in the driver).
* **AddressSanitizer** (`make c3asan`, leaks included): the 20728 problems that end without an exception (`c3noexn.py`): no error, no leak (the words of the data file that ATS1 keeps are suppressed: `c3lsan.supp`); all the 25800
  problems without the leak check: no error. A problem that ends in `FatalErrorExn` leaves the linear data that is alive (as in ATS1).

### Interface notes for the driver (pats_main) and ccomp

* `pats_main.dats`: `staload "./pats_constraint3.sats"` and `"./pats_jsonize_synent2.sats"`; dynload `pats_jsonize.dats`, `pats_lintprgm.dats`, `pats_lintprgm_print.dats`, `pats_lintprgm_myint.dats`, `pats_constraint3.dats`, `_print`, `_icnstr`, `_simplify`, `_solve`, `_init`,
  `_mapgen`, `_jsonize`, `pats_jsonize_synent2.dats` (C3-10). Call `constraint3_initialize ()` right after `stacst2_initialize ()` (as `pats_main.dats` of ATS1, line 957): the pervasive environment must hold the 35 constants. `c3nstr_ats2_solve (c3t)` ends with
  `$ERR.abort<void> ()` (`FatalErrorExn`) when something is unsolved: let it reach the handler of `patsopt_main`; `c3nstr_export (out, c3t)` and `d2eclist_jsonize_out (out, d2cs)` print the JSON of `--constraint-export` and `--jsonize-2`.
* The integers of the solver: default gmp (link `-lgmp`); the three modules `pats_intinf.dats`, `pats_lintprgm_myint.dats` and `pats_constraint3_solve.dats` must be compiled with the same `C3NSTRINTKND` (`-DATS C3NSTRINTKND=intknd`). Do not
  compile `pats_lintprgm_solve.dats` by itself (C3-6); compile `pats_lintprgm.dats` by itself (`myintvec0_free`).
* ccomp does not use these modules (it consumes the `hidexp` trees). The trans3 port calls `the_trans3_finget_constraint ()` (trans3_env) and gives the result to `c3nstr_ats2_solve`.

### Open problems (constraint3)

* The `s3exp` trees (normal forms of sums and products), the `glist`s that the sums and `s3explst_make` build, and the `jsonval` of an export are never freed (the arena); a program with many large constraints has not been measured. The `icnstr` and the vectors are linear and freed.
* An exception (`FatalErrorExn` of an unsolved constraint, a shape that `s3exp2icnstr` rejects) leaves the linear structures that are alive unfreed; the process ends in `patsopt`.
* The ATS1 `MatchError` of `val-S2RTfun` / `val-list_cons` is `abort_interr` here (exception `FatalErrorExn_interr` instead of the end of the process): the generator of the test avoids these inputs, so that the two builds can be compared.
* `s3exp_bineq` of the kind 0 (`int2` allows it) on a constant is `assertloc (false)` as in ATS1; `s2exp_metdec_reduce`'s non-integer order is the syntactic subterm order of `s2exp_synlt` (covered with `types` terms).
* The solver itself is exponential (LP notes): `c3dump` problems have at most 5 variables.

## Level-2 jsonize: pats_jsonize_synent2.{sats,dats} (rules J2-1 .. J2-8)

Done (typecheck, link, differential test, see Validation): `pats_jsonize_synent2.sats` (the declarations of ATS1, `jsonize_tyreckind` as a function with a named argument) and `pats_jsonize_synent2.dats`
(2.1k lines of ATS1, 2.1k of ATS2). It gives the `--jsonize-2` output (`d2eclist_jsonize_out`) and everything that `pats_constraint3_jsonize.dats` calls (`jsonize_s2var`, `jsonize1_s2exp`, `jsonize_d2var`, `jsonize_s2cst_long`..). The
`pats_jsonize.sats` declarations are as they were (TL-8, TL-9); `pats_dynexp2_mapgen.dats` (`d2eclist_mapgen_all`) was ported with the dynexp2 slice.

J2-1. **Matches are on the views**: `case+ s2exp_node_view (s2e0.s2exp_node ()) of ~S2Eint (i) => ..` (S2-1, D2-1) for `s2exp_node`, `p2at_node`, `d2exp_node`, `d2ecl_node`, `d2lab_node`, `labp2at`, `d2exparg`, `d2itm`, `s2zexp`, `wths2explst`,
      `tyreckind`, `s2rtbas`, `scstextdef` and `dcstextdef` (`$SYN.scstextdef_view`, `~$SYN.SCSTEXTDEFsome`); the default arms (`| _ (*rest*) => jsonval_conarg0 ("D2Eignored")`) free the view
      (`| v => (d2exp_node_view_free (v); ..)`, S2-10). The enum `pckind` and `caskind` are matched as before (`PCKcon ()`).
J2-2. **Lists and options of the tree are `glist`/`gopt`**: `jsonize_list_fun<T> (xs, f)` and `jsonize_option_fun<T>` of `pats_jsonize.sats` (the template implementations are `staload _`ed), the recursive
      `auxlst` of `jsonize_s2explst`/`jsonize_labs2explst` walk with `glist_is_cons`/`glist_head`/`glist_tail` in the order of ATS1 (head first). `labs2explst` is a list of records (`ls2e.labs2exp_lab ()`, `_nam`, `_elt`),
      `labd2exp` a record (`labd2exp_lab`, `labd2exp_elt`).
J2-3. **The JSON values are built with the API of TL-8**: the ATS1 lists `jsv1 :: jsv2 :: list_nil` are `cons (jsv1, cons (jsv2, nil))` with `macdef nil = glist_nil{jsonval} ()` and `macdef cons (x, xs) = glist_cons<jsonval> (x, xs)`;
      `JSONlist (xs)` is `jsonval_JSONlist (xs)`, `JSONoption (None ())` is `jsonval_JSONoption (gopt_none ())`; the `i2mpdec` is `jsonval_JSONlablist` of a glist of `labjsonval_new (label, value)`.
J2-4. **Tokens**: `val-$LEX.T_INT (base, rep, sfx) = tok.token_node` is `token_int_rep (tok)` (`pats_syntax_token.hats`, S2-kind helpers: `token_float_rep`, `token_char_get`, `token_string_get`); `int_of_char (c)` is `char2int0 (c)`.
J2-5. **Record fields of the syntax** are not visible as `x.l0ab_lab ()` through the qualified `staload SYN = "./pats_syntax.sats"`: `macdef l0ab_lab = $SYN.l0ab_lab`, `macdef i0de_sym = $SYN.i0de_sym` (function calls); the other records
      (`d2exp`, `p2at`, `s2cst`..) are accessed as `x.d2exp_node ()` (the sats of staexp2/dynexp2 are opened).
J2-6. **The sets of `d2eclist_jsonize_out`** (`s2cstset_vt` ..) are listized with `*_listize_free` as before; `$UN.linlst2lst (xs)` (a borrowed view) is `l2l (xs)` (`glist_make_list_vt`, consumes the list: no `list_vt_free`).
J2-7. **Messages**: the warning of `jsonize_d2exp` for an unsupported expression, `warning(ATS): [jsonize_d2exp]: ignored: D2Evararg(..)` (stderr), uses `prerr_d2exp`. The ATS1 oddities are kept (`D2Cstacons` is
      labeled `"D2Cstacsts"`, `jsonize_s2eff` is `jsonize_ignored`, a linked `S2RTVar` is followed, `S2Efun` loses `fc`, `lin` and the effect, `S2Eextype` loses its arguments).
J2-8. **Link/dynload**: `pats_jsonize_synent2.dats` after `pats_jsonize.dats` and the level-2 modules; it staloads `pats_jsonize.dats` (templates) and `pats_staexp2_util.sats` (`s2exp_hnfize`, for the flag 1 of `jsonize_s2exp`).

### Validation (ATS1 reference = the objects of the main tree `src/`; `make -C src2/test j2compare | j2test | c3cover | j2mutate | j2asan`)

* **`test/j2_gen.py` + `j2_cases.py`** make ONE program of 147 scenarios (`J2SEED=1`, `J2SCALE=2`; 8 chunks, 11k lines) in the common subset of ATS1/ATS2, with the machinery of the level-3 test (random level-2 trees of every constructor:
  `sc.gv ('d2ecl', depth)`, `K_<CON>` wrappers and the typed lists/options of `t3compat_gen.hats`, the setup of the 118 pervasive constants): families `static` (sorts incl. functions, tuples, datasorts, linked variables,
  errors; cells: `s2cst` with external names, supertypes and constructor lists, `s2var`, `s2Var` with `szexp`, `d2con`, `s2rtdat`; `s2exp` of every constructor with the flags 0 and 1 of `jsonize_s2exp`, lists, options, labeled lists with and
  without names, `wths2explst`, `s2eff`, `s2zexp`, `tyreckind` with stamps and external names), `dynamic` (`d2cst`, `d2var`, `d2itm`, random `d2ecl` and `d2eclist`), `exps` (EVERY constructor of `d2exp_node` and `p2at_node` as the definition of a declaration, at depths 3 and 4:
  all the arguments, `D2LABind`, `LABP2ATnorm`) and `out` (`d2eclist_jsonize_out`: the six maps and the declarations). Each result is printed by `fprint_jsonval` (stdout); the warnings of unsupported expressions are the stderr.
  **Result: stdout 6.8k lines and stderr 1.2k lines, byte-identical in ATS1 and ATS2** (`j2dump.md5`: `make j2test` checks the ATS2 build without ATS1).
* **Coverage** (`make c3cover`, with the constraint solver: gcov by ATS line): `pats_jsonize_synent2.dats` **961 of 961 executable lines (100%)**, `pats_constraint3_jsonize.dats` 196/196; the 38 functions of `pats_jsonize_synent2.sats` are called.
* **Mutation test** (`python3 c3mutate.py j2`, 14 deliberate bugs: labels, the order of the arguments of a constructor, the hnfize flag, the record of a labeled list, the supertypes of a constant, the kind of a sort variable,
  the clause fields, the locals, the separators and labels of the output, the characters): **14/14 detected**.
* **AddressSanitizer** (`make j2asan`, leaks included): no error, no leak.

### Open problems (level-2 jsonize)

* `d2eclist_jsonize_out` builds the whole JSON tree of the declarations (`jsonval`, arena) before it prints it, as ATS1 (a large file: memory ~ the tree); the stamps in the output are those of the process (the test compares builds with the same order of creation).
* The generator produces `s2exp` with the flag 1 (hnfize) only for the safe subset of constructors (acyclic); the others are jsonized with the flag 0 (`fulls2`).


## ccomp interface: pats_ccomp.sats, pats_ccomp.spec (rules CC-1 .. CC-12)

`pats_ccomp.sats` (src/ 2.5k lines, 535 functions) is ported with every declaration and every external C name of `src/`; the data it declares is generated by arenagen from `pats_ccomp.spec`
(`pats_ccomp_gen.hats` is `#include`d in the sats, `pats_ccomp_gen_dats.hats` in exactly ONE `.dats`: `pats_ccomp.dats`; both are in `.gitignore`, `make -C src2 check` makes them). Read the "Arena AST" and
"Erased trees (hidynexp)" sections first: everything below is the same machinery.

CC-1. **Types.** Records (flat cells in the global arena, never freed, address = identity): `tmplab tmpvar d2env funlab funent labprimval primdec primval primlab tmpmov instr ibranch hifundec2 hiimpdec2`.
      Datatypes (`T_CON(..)` constructors, `T_view` to match, `T_is_CON` tests): `tmpsub tmpcstmat tmpvarmat primcstsp primdec_node primval_node primlab_node patck tmprimval patckont instr_node`.
      Lists/options are `glist`/`gopt` (`tmpvarlst funlablst primvalist instrlst ibranchlst labprimvalist primlablst primdeclst tmpmovlst d2envlst funentlst ..`, `tmpvaropt funlabopt funentopt tmpsubopt
      instrlstopt funlablstopt d2envlstopt primvalopt`); the `_vt` ones (`tmpvarlst_vt funlablst_vt d2envlst_vt primvalist_vt labprimvalist_vt primdeclst_vt instrlst_vt tmpmovlst_vt`) are `List0_vt`,
      `funlabopt_vt tmpvaropt_vt funentopt_vt tmpsubopt_vt` are `Option_vt`. `vbindmap = d2varmap(primval)` (the avl map of dynexp2; templates `d2varmap_*<primval>`: `staload _ = "./pats_dynexp2_dvar.dats"`).
CC-2. **Constructing and reading.** `INSmove_val (tmp, pmv)` (ATS1 constructor) = `instr_node_INSmove_val (tmp, pmv)`; the smart constructors of the sats (`instr_move_val (loc, tmp, pmv)`,
      `primval_int (loc, hse, i)`, `primdec_list`, ..) are in `pats_ccomp.dats` and have the ATS1 names, argument orders and bodies. The ATS1 `'{instr_loc= l, instr_node= n}` is `instr_new (l, n)` (same for
      `primval_new (loc, type, node)`, `primdec_new`, `primlab_new`, `ibranch_new (loc, inslst)`); fields are `x.instr_loc ()`, `x.instr_node ()`, `x.primval_type ()`, `x.primval_node ()`, `x.ibranch_inslst ()`.
      A match is `case+ instr_node_view (ins.instr_node ()) of ~INSfcall (tmp, pmv, hse, pmvs) => .. | v => (instr_node_view_free (v); ..)`; a test without payload is `instr_node_is_INScond (nd)`.
      The one-constructor ATS1 datatypes became records: `LABPRIMVAL (l, pmv)` = `labprimval_new (l, pmv)` (`x.labprimval_lab ()`, `x.labprimval_elt ()`); `HIFUNDEC2 (hfd, tsub)` = `hifundec2_new (hfd, tsub)`
      (`hifundec2_hfd`, `hifundec2_sub`); `HIIMPDEC2 (imp, tsub, s2ess)` = `hiimpdec2_new (..)` (`hiimpdec2_imp/_sub/_arg`); the flat pair `@(src, dst): tmpmov` is `tmpmov_new (src, dst)`
      (`tmpmov_src ()`, `tmpmov_dst ()`); `D2ENV (d2v, hse)` is `d2env_new (d2v, hse)` (also `d2env_make`). `TMPSUBnil ()` is `tmpsub_TMPSUBnil ()` (a fresh cell, not a constant: test with `tmpsub_is_TMPSUBnil`).
      `PTCKNTnone ()`, `PMVtop ()`, `INSletpop ()`.. are `patckont_PTCKNTnone ()`, `primval_node_PMVtop ()`, `instr_node_INSletpop ()`.
CC-3. **Mutable cells = `mut` fields** (setter `set_<field> (x, v)`, raw getter `<field> (x)`; the ATS1 API stays a thin layer over them):
      `tmpvar` (type ref ret topknd origin suffix; ATS1 `patsopt_tmpvar_set_*` C functions: declared in the sats with the SAME C names and implemented in `pats_ccomp_tmpvar.dats`, so a module that declared
      `extern fun tmpvar_set_ref .. = "patsopt_tmpvar_set_ref"` just drops its declaration), `funlab` (tmpknd ncopy origin suffix funent), `funent` (tmpsub flablst_fin d2envlst_fin fnxlablst; the four
      `patsopt_funent_set_*` are declared in the sats with their C names, implemented in `pats_ccomp_funent.dats`). `hifundec`/`hiimpdec` (hidynexp) hold `funlab`/`instrlst` as the PLACEHOLDER types of
      histaexp/hidynexp: `hifundec_get_funlabopt`, `hiimpdec_get_funlabopt/_instrlstopt` and their setters (pats_ccomp.dats) are the `$UN.cast` layer over `hifundec_funlab ()`/`set_hifundec_funlab` etc.; do not use
      the `getref` addresses in ccomp. `tmpvar_ret` doubles as the tail-call counter (`tmpvar_get_tailcal`, `tmpvar_inc_tailcal`), as in ATS1.
CC-4. **`funlab` and `instrlst` are the real types** (`pats_ccomp.sats` shadows `typedef funlab`, `typedef instrlst` of histaexp/hidynexp; `hisexp_funlab_type`/`dynexp2_funlab_type` are the placeholders, same
      word at run time). `print_funlab/prerr_funlab/fprint_funlab` of ccomp have the C names `ext#patsopt_ccomp_{print,prerr,fprint}_funlab` (the histaexp placeholder versions own the plain C names:
      `pats_histaexp_funlab.dats` calls `patsopt_funlab_get_name`, which `pats_ccomp_funlab.dats` exports as the C name of `funlab_get_name`). `fprint_funlab` of ccomp prints `name$sfx(level=n)`.
CC-5. **Sets/maps** (`tmpvarset_vt`, `funlabset_vt`, `d2envset_vt`, `tmpvarmap_vt`) are linear `libats` avl trees (`linset_avltree`/`linmap_avltree`), `absvtype .. = ptr` in the sats; the comparison is the
      template `compare_elt_elt<T>`/`compare_key_key<T>` implemented once per type in the module of the type (tmpvar by stamp, funlab by stamp, d2env by `compare_d2var_d2var`). `tmpvarmap_vt_*` are
      TEMPLATES (`tmpvarmap_vt_nil<tmpvar> ()`, rule 15): the user has `staload _ = "./pats_ccomp_tmpvar.dats"`.
CC-6. **Abstract linear types of the sats**: `ccompenv` (`absvtype ccompenv_vtype = ptr`, `absview ccompenv_push_v`; the ccompenv module chooses the representation and `assume`s it; every function takes
      `!ccompenv`), `instrseq` (mine: `pats_ccomp_instrseq.dats`), `hitype` (`abstype hitype_type = ptr`, `pats_ccomp_hitype.dats`).
CC-7. **Function-typed constants** of ATS1 (`fun hidexp_ccomp : hidexp_ccomp_funtype`, `fun emit_instr : emit_instr_type`, `fun fprint_X : fprint_type (T)`) are ordinary declarations with explicit arguments
      (`fun hidexp_ccomp (env: !ccompenv, res: !instrseq, hde: hidexp): primval`, `fun emit_instr (out: FILEref, ins: instr): void`, `fun fprint_primval (out: FILEref, x: primval): void`); the typedefs are kept.
CC-8. **Where each function is implemented** (the file of `src/` that has its `implement`; the port keeps the split; a function that ATS1 declares and never implements stays unimplemented:
      `print_tmplab prerr_tmplab tmpvar_iserr d2envset_vt_ismem primval_is_empty emit2_s2cst`):
      `pats_ccomp.dats`: the `primdec_*`, `primval_*` (incl. `primval_make_*`), `primlab_*`, `instr_*`, `ibranch_make`, `hifundec/hiimpdec_get/set_funlabopt/instrlstopt` (and includes `pats_ccomp_gen_dats.hats`);
      `_tmplab`: tmplab; `_tmpvar`: tmpvar, tmpvarset/map, `tmpvar_set_*`; `_funlab`: funlab, funlabset, `funlab_get/set_funent`; `_funent`: funent, `funent_set_*`; `_d2env`: d2env, d2envset;
      `_instrseq`: instrseq; `_util`: `tmpsub2stasub tmpsub_append tmpvar_is_void primval_is_void/top/nshared primval_make_funlab/make2_funlab/make_d2vfunlab patckont_is_none instrlst/primdeclst_get_tmpvarset`;
      `_print`: every `print_/prerr_/fprint_` of primdec primval primlab labprimval patck patckont instr tmpsub tmpcstmat tmpvarmat primcstsp tmpmovlst vbindmap hifundec2 hiimpdec2 (not `fprint_tmprimval`: `_claulst`);
      `_ccompenv`: ccompenv and `the_exndeclst_*/saspdeclst/extypelst/extcodelst/staloadlst/dynloadlst/dynconlst/dyncstlst/funlablst_*`, `the_toplevel_getref_*`, `ccompenv_tmpcst_match/tmpvar_match`;
      `_environ`: `funlab_is_envful funlab_get_type_fullarg funent_eval_flablst/d2envlst funent_varbindmap_* the_funent_varbindmap_find`;
      `_hitype`: hitype, `hisexp_typize`, `emit_hitype/hisexp/hisexplst_sep/hisexp_sel`, `emit_the_typedeflst`; `_hipat`: `hipatck_ccomp himatch(2)_ccomp hifunarg_ccomp`;
      `_dynexp`: `hidexp_ccomp(_lam/_fix/v)`, `hidexp_ccomp_ret(_raise)`, `hidexplst_ccomp(v)`, `hidexp_ccomp_funlab_arg_body`, `hilab(lst)_ccomp`; `_caseof`: `hidexp_ccomp_ret_case`; `_looping`; `_trywith`; `_lazyeval`;
      `_decl`: `hiimpdec_ccomp(_if) hifundeclst_ccomp hidecl_ccomp hideclist_ccomp(0)`; `_claulst`: `hiclaulst_ccomp`, `fprint_tmprimval`; `_subst`: `t2mpmarglst_(t)subst d2envlst_subst funlab_subst funent_subst`;
      `_template`: the `*_tmpcst_match`, `*_tmpvar_match`, `ccomp_tmpcstmat/tmpvarmat`, `funlab_tmparg_match`, `hifundec2tmpvarmat`; `_emit`, `_emit2`, `_emit3`, `_main` as in ATS1 (the `emit_*` and `emit_the_*`).
CC-9. **Placeholders used by the generated dats**: the module that includes `pats_ccomp_gen_dats.hats` needs `staload _ = "./pats_dynexp2_dvar.dats"` (the `d2varmap` templates are not used by the generated code, but the
      typedef `vbindmap` is) and the arena (`staload _ = "libats/DATS/arena.dats"`); no other `.dats` includes it.
CC-10. **ATS1 oddities kept in the interface**: `funlab_make_tmpvar_type` is commented out in the sats (as in ATS1); `primlab_lab`/`primlab_ind` are declared twice (sats of ATS1 too); `funent_set_tmpsub` and
       `funent_set_fnxlablst` had plain C names, now `ext#patsopt_funent_set_tmpsub`/`..fnxlablst` (same symbol); `Option (T)` of the sats is `gopt(T)` everywhere (`tmpvaropt` etc.).
CC-11. **Names that clash with a spec field**: the record `tmpvar` has a field `tmpvar_type` (the erased type) next to the abstype `tmpvar_type` the generator makes: types and values are different namespaces and it
       works (same as `hidexp_type` of hidynexp); prefer `tmpvar_get_type`.
CC-12. **Typecheck**: `make -C src2 check` (the sats is in `SATS`; the `.dats` of the core modules are listed in "ccomp core modules"). Interface files: `pats_ccomp.sats pats_ccomp.spec` + generated `pats_ccomp_gen.hats
       pats_ccomp_gen_dats.hats` (the generator is `make pats_ccomp_gen.hats pats_ccomp_gen_dats.hats`).

## ccomp core modules: pats_ccomp.dats, pats_ccomp_{tmplab,tmpvar,funlab,funent,d2env,instrseq,util,print}.dats (rules CCM-1 .. CCM-12)

Done (typecheck, link, differential test, see Validation): the nine modules, 5.0k lines of ATS1 (`pats_ccomp.dats` 1.0k with the constructors of primval/instr/primdec, `_print` 1.5k, `_util`, `_tmpvar`, `_tmplab`, `_funlab`,
`_instrseq`, `_d2env`, `_funent`), 4.4k of ATS2. Same names and external C names as `src/`. `pats_ccomp.dats` was not assigned to anybody in the phases: it is here (it includes `pats_ccomp_gen_dats.hats`, CC-9).
The interface they implement is "ccomp interface" above (CC-1 .. CC-12): read it first.

CCM-1. **Constructors** (`pats_ccomp.dats`): `primval_make_node (loc, hse, node)` and `instr_make_node`/`primdec_make_node` are `extern fun` of the file (not in the sats) that call `primval_new`/`instr_new`/`primdec_new`;
       every smart constructor of the sats is a one-line call with the ATS1 argument order. `instr_move_fltrec2` reads the first labelled value of a singleton record (`assertloc (glist_is_cons ..)` for the MatchError of ATS1);
       its wildcard arm frees the view. The `hifundec/hiimpdec_{get,set}_funlabopt/instrlstopt` layer is the cast layer of CC-3.
CCM-2. **Sets** (`tmpvarset_vt`, `funlabset_vt`, `d2envset_vt`) are `libats/linset_avltree`: `implement $LS.compare_elt_elt<T>` (stamps for tmpvar and funlab, `compare_d2var_d2var` for d2env; the `Sgn` is cast to `int`);
       `libats/DATS/linset_avltree.dats` does NOT implement `linset_listize1` (declared only): the borrowing `*_listize` is `linset_listize (linset_copy (xs))`; the order of a list is ascending, as in ATS1
       (`linset_avltree` there too). The effect masks: the functions that are declared `:<>` in the sats use `$effmask_all` / `$effmask_wrt (linset_insert ..)`.
CCM-3. **`tmpvarmap_vt_*` are templates** (CC-5): `implement{a} tmpvarmap_vt_insert (..)` in `pats_ccomp_tmpvar.dats` over `linmap_avltree` (`compare_key_key<tmpvar>`); a user writes `tmpvarmap_vt_nil<tmpvar> ()` and has
       `staload _ = "./pats_ccomp_tmpvar.dats"` (and `libats/DATS/linmap_avltree.dats`, `arena.dats`: `mylibies.hats`). The instance is compiled into the USER module (a mutation of the template in tmpvar.dats is invisible to the test).
CCM-4. **Generated code and the instance of `d2varmap<primval>`**: `pats_ccomp.dats` has `staload _ = "./pats_dynexp2_dcst.dats"` / `"_dvar.dats"` and `./pats_avlmap.sats`; `pats_ccomp_print.dats` (`fprint_vbindmap` calls
       `d2varmap_listize<primval>`, then walks the linear list and frees it) has `staload _ = "./pats_dynexp2_dvar.dats"` (rule 16: without it the C code has `PMVtmpltcstmat[..]`).
CCM-5. **Names of functions** (`pats_ccomp_funlab.dats`): `funlab_make_type`/`_dcst_type`/`_dvar_type` build the name with `string_app2/3` = `string0_append` + `the_garena_strdup` (never freed); `__patsfun_` without a
       static prefix, `<prefix>patsfun_` with one (`$GLOB.the_STATIC_PREFIX_get`, `stropt_is_some`/`stropt_unsome`); `d2cst_get_gname` matches `$SYN.dcstextdef_view (extdef)` (`DCSTEXTDEFnone` -> the symbol name).
       `$STMP.tostring_prefix_stamp (flname, stamp)`. `funlab_make` takes the funclo from the type when `fcopt` is `None_vt` (`HSEfun (fc, _, _)`, else `FUNCLOfun`).
CCM-6. **The C function `patsopt_funlab_get_name`** that `pats_histaexp_funlab.dats` calls (HS-5) is exported by `pats_ccomp_funlab.dats` (`extern fun funlab_get_name_c (..) = "ext#patsopt_funlab_get_name"`). `print_funlab/prerr_funlab/
       fprint_funlab` have the C names `patsopt_ccomp_*_funlab` (CC-4). The placeholder funlab of a `HSEtyclo` (hisexp) is a real funlab: `hisexp_tyclo ($UN.cast{<placeholder>} (flab))`.
CCM-7. **MatchError / INTERROR**: `val-Some (hse) = d2var_get2_hisexp` (`d2var2env`) is `assertloc (gopt_is_some ..)`; `funlab_get_type_arg/res` of a non-function type print `INTERROR(pats_ccomp_funlab): : funlab_get_type_arg:
       hse = ..` (also for `_res`, as in ATS1), `assertloc (false)` and `$ERR.abort_interr` (dead code). `fprint_primdec` of a `PMDstaload/PMDdynload` whose declaration is not `HIDstaload/HIDdynload` is the
       MatchError `val-~HIDstaload (..) = hidecl_node_view (..)`.
CCM-8. **Printers** (`pats_ccomp_print.dats`, drafted by `utils/arenagen/port_ats1.py pats_ccomp.spec:pats_hidynexp.spec:pats_histaexp.spec:pats_dynexp2.spec:pats_staexp2.spec`): `fprintf` is `fprint_string`/`fprint_int`
       calls with the same text (`arg(%i)`, `int(%i)`), `char_isprint` is `isprint_char`, the `PMVchar` of a non-printable character prints `int(n)`; `fprint_instr` ends with `| v => (instr_node_view_free (v); prstr "INS...(...)")` (the
       ATS1 wildcard: `INSmove_ref` and a few others print `INS...(...)`); `fprint_hifundec2/hiimpdec2` print only `hfd`/`imp` and the substitution (as ATS1); `fprint_tmpmovlst` calls `fprint_tmprimval`, which ATS1
       defines in `pats_ccomp_claulst.dats` (the claulst port must provide it: the test doubles it); `fprint_labprimval` is `extern` in the .dats (not in the sats).
CCM-9. **`instrseq`** is `datavtype instrseq = INSTRSEQ of (List0_vt (instr))`, a REVERSED list (`instrseq_add` conses, `instrseq_get_free` reverses and makes a `glist`): the order of insertion is kept, as the queue of ATS1.
CCM-10. **ATS1 oddities that the reference shows** (the test works around them in `cc_hand1.hats`; nothing of this is in the ATS2 interface): the `instrlst` of the four constructors `PMDextvar/PMDvaldecs/PMDvaldecs_rec/PMDvardecs`
       and of `primdec_extvar/valdecs/valdecs_rec/vardecs` is the abstract `ccomp_instrlst_type` in ATS1 (the `where` binds `instrlst` only afterwards), `tmpvar_set_tyclo` takes the placeholder funlab, and a typedef of the
       file (`typedef instrlst = ..` of the hd test layer) wins over the staloaded one in ATS1. In ATS2 `instrlst` is one type (CC-1): the modules need no cast.
CCM-11. **Not implemented, as in ATS1**: `print_tmplab`, `prerr_tmplab`, `tmpvar_iserr`, `d2envset_vt_ismem`, `primval_is_empty`, `emit2_s2cst` (declared, no body). `funlab_make_tmpvar_type` is commented out in the sats.
CCM-12. **Dynload order** (adds to the lists above): `.. typerase_decl, ccomp, ccomp_print, ccomp_tmplab, ccomp_tmpvar, ccomp_d2env, ccomp_funlab, ccomp_funent, ccomp_util, ccomp_instrseq, ..` (the order of `pats_main.dats`;
       none of the nine has an initializer that depends on the others except through the arena/stamps).

### Validation (ATS1 reference = the objects of `src/` of the main tree: `SRC=<main tree>/src make -C test/cc compare`; `make -C test/cc test|cover|mutate|asan`)

* **`test/cc/cc_gen.py` + `cc_cases.py`** build on the hd test (the specs of staexp2, dynexp2, dynexp3, histaexp, hidynexp, its compat layers, its random builders and the pervasive setup) and add `pats_ccomp.spec`: wrappers `K_<CON>`
  of every constructor and record, typed lists/options, and a COMPLETE dumper `dd_<T>` of every type; the five cells (tmplab, tmpvar, d2env, funlab, funent: abstract in ATS1) are built through the API and dumped through
  their getters (a funlab shows its funent shallowly). ONE neutral program (the common subset) of 55 scenarios (`CCSEED=1 CCSCALE=3`, 22 chunks of 32k lines) is compiled by the ATS2 driver `ccdump.dats` and the ATS1
  driver `ccdump1.dats` (`cc1.sh`, linked with the ATS1 objects of the main tree). Families: `cell` (tmplab/tmpvar/d2env: every maker, getter, setter (the C setters of ATS1 through `t_tv_set_*`), `inc_tailcal`, `eq/compare`
  of all pairs, the sets (random insertions with duplicates, listize, free), the map (insert/search/remove), `d2var2env`, `d2envlst2set`), `funlab` (every maker, getter, setter, the types of arguments/results, `funlab_set_funent`,
  the sets with `ismem`, `fprint_funlabset_vt`, `funlablst2set`, the printers of lists/options), `funent` (`funent_make`, `funent_make2`, every getter/setter, the printers), `make` (every smart constructor of the sats parsed
  from `pats_ccomp.sats` twice with random arguments, dumped and printed with `fprint/print/prerr`, the predicates), `raw` (every constructor and record through `K_`, dumped and printed, printable and not printable characters,
  every list printer), `util` (`primval_is_*` on a primval of every constructor with void and other types, `primlab_is_*`, `patckont_is_none`, `primval_make_funlab` for every closure kind, `tmpsub2stasub` (applied to
  expressions and printed), `tmpsub_append`, `instrlst/primdeclst_get_tmpvarset` on random lists and on every instruction/declaration alone), `seq` (random sequences of every `instrseq_add*`), `dec` (the cast layer of
  hifundec/hiimpdec, `PMDimpdec` with and without an instruction list) and 7 cases that end the process (`ccexit.sh`: stdout identical, both fail, the INTERROR lines identical).
  **Result: stdout 22367 lines and stderr 3544 lines byte-identical in ATS1 and ATS2** (the first complete run was already identical); `cc.md5` keeps the md5 of the ATS1 output (`make -C test/cc test` needs no ATS1; line 2 is the md5 of `ccexit.sh`).
* **Coverage** (`make -C test/cc cover`): all 130 constructors and 9 non-cell records of the spec are built by the cases (the 5 cells through the API), and all 289 functions of `pats_ccomp.sats` that the ATS1 sources of the
  nine modules implement are called (`cccover.py`). gcov by ATS line (`patsopt --gline`, `-O0 --coverage`): **2153 of 2176 executable lines (98.9%)** of the nine modules; the rest are the paths that end the process (the
  7 exit cases abort: their counters are lost), `prerr_FILENAME` and two lines of the helper `string_app2`.
* **Mutation test** (`python3 ccmutate.py`): 89 deliberate bugs in the nine modules (flags and kinds of tmpvar, the setters, the increment of the tail-call count, the compare of tmpvars and funlabs, the sets, the names
  of funlabs and their separators, the level, `funlab_make` closure kind, `funent` getters/setters/`make2`, d2var2env, instrseq order, every arm of `primval_is_nshared`, the arms of the traversal of `get_tmpvarset`,
  the constructors (loop labels, local order, refarg kinds, casts), the text of the printers): **89/89 detected** (the first run missed 3: an equivalent change of a flag, a mutation of a template that is compiled into the chunks, an unreachable character fallback: the cases gained non-printable characters and nested declarations; the last survivor `PMDlocal` made me add the nested declarations of `fam_util`).
* **AddressSanitizer** (`make -C test/cc asan`, leak detection on): no error, no leak.

### Open problems (ccomp core modules)

* A mutation of a template that the cases instantiate (`tmpvarmap_vt_*`) is invisible to the mutation test (the instance is compiled into the chunk).
* The 7 cases that end the process only compare the status, stdout and the INTERROR lines (the text of the failure differs between ATS1 and ATS2).
* `cc2.sh` stages the whole src2 and the hd test files (a full build is ~45 s with `JOBS=16`; the ATS1 build ~30 s).
* `pats_ccomp.sats` was changed once after the first copy to the phase-2 worktrees (`/tmp/ccomp-iface-changes.txt`: `d2envset_vt_listize*` return `List0_vt (d2env)`).

## ccomp group A (emit): pats_ccomp_emit, pats_ccomp_emit2, pats_ccomp_emit3 (rules CA-1 .. CA-7)

Done (typecheck, link, differential test, see Validation): the C emitter, 5.9k lines of ATS1 -> 3.0k + 0.7k + 2.2k of ATS2 (`pats_ccomp_emit.dats` has the C helpers). Same file names, function names and
order of every `emit_*` call as `src/`; `make -C src2 check` runs `checkcca`.

CA-1. **Matching.** Trees are read with `*_node_view` (`~CON` arms; a wildcard arm frees the view: `| v => (primval_node_view_free (v); ..)`), one-arm reads are `val-~CON (..) = view (..)`, a mere test
      uses `_is_` (`hisexp_node_is_HSEtysum`). Lists are walked with `glist_is_cons/_head/_tail` (no allocation), options with `gopt_view` or `gopt_is_some`/`gopt_unsome`.
CA-2. **`fprintf` is gone**: `%i` is `fprint_int` between `emit_text`s; `%.18f` (floats), `%.3o` (octal escapes) and the time stamp are three C functions in a `%{$` block of `pats_ccomp_emit.dats`
      (`patsopt_emit_fprint_float18/_oct3/_time_when`). The escapes of `emit_char/emit_string` print the unsigned byte, `emit_ident` the sign-extended `uint` of the `char`, as ATS1 (`$UN.cast2uint (c)`).
CA-3. **Closures**: the `:<cloref1>` `loop` of `emit_instr_move_rec` is the toplevel `emit_instr_move_rec_loop (out, ..)`; `list_app_cloptr` of `emit_d2conlst_extdec/_d2cstlst_extdec` are recursions.
CA-4. **`the_nfnx`** (a `ref`) is an arena cell set at dynload: dynload `pats_ccomp_emit.dats` (order of `pats_main.dats`: .. environ, template, emit, emit2, emit3, main).
CA-5. **Not ported**: `emit_move_ptralloc` (a local extern of ATS1, never called), `emit_funtype_arg_res` (`#if(0)`). Kept ATS1 oddities: `pats_ccomp_emit3` says `pats_ccomp_emit2` in `INTERROR`; `emit_instr` ends the
      process (`assertloc`) on `INSmove_ref/_arg_val/_ptrofsel`; an `auxsel` on a non-record type prints `INTERROR` and ends the process.
CA-6. **What the modules call** (the integration needs them): tmpvar/tmplab/funlab/funent/d2env getters, `funent_eval_flablst/d2envlst`, `funent_varbindmap_*`, `the_funent_varbindmap_find`, `funlab_is_envful`,
      `funlab_get_type_fullarg`, `primval_is_void/_is_top`, `primval_ptrof`, `patckont_is_none`, `tmpvar_is_void`, `fprint_primval/_instr/_funlab/_funlablst/_d2envlst/_tmpsubopt`,
      `hiimpdec_get_instrlstopt`, `hisexp_typize`, `emit_hitype/_hisexp/_hisexp_sel/_hisexplst_sep`, `$TR2ENV.filenv_get_d2eclist`, `d2cst_get2_hisexp/_type_arg/_res`.
CA-7. **Output**: byte-identical C text to ATS1 (also `/* .. */` debugging lines, `#line`, stderr messages).

### Validation (ATS1 reference = the objects of the main tree `src/`; `make -C test/ca compare|cover|mutate|asan|test`, `SRC=<main tree>/src`)

* `test/ca/ca_gen.py` + `ca_cases.py` generate ONE program of 31 scenarios (12.6k lines, 8 chunks, `CASEED=1 CASCALE=3`) in the common subset of ATS1/ATS2 (wrappers K_x of `pats_ccomp.spec` and of the
  specs of hd_gen.py, hand wrappers `H_*`), compiled by `cadump.dats` (ATS2) and `cadump1.dats` (ATS1, linked with the REAL ATS1 ccomp modules): all 256 chars and special strings through every escaper,
  floats (nan, inf, -0), ints, labels, stamps, every `d2cst` kind/extdef x pack, `d2con` class (nullary, singular, list-like, exception, linear, tag -2), tmpvars (ref/ret/static/copy/tailcall), funlabs (origin
  chains, suffix, template, closures), arrays (int, intinf, unknown dims), every primval and instr constructor, type paths for select/select2/selptr/ptrofsel/store, calls (constant, label, closure, bottom,
  template), tail calls, patcks of every con class, branches, loops, try-with, staload/include/local trees through a filenv, funents (envless/envful/template/fnx siblings/closures), debugging flags.
  **Result: stdout 22302 lines and stderr 57 lines identical in ATS1 and ATS2; 11 cases that end the process (`CAEXIT=k`) fail in both with the same stdout and INTERROR lines** (also at seed 2). `ca.md5`
  keeps the md5 of the ATS1 output (`make -C test/ca test` needs no ATS1).
* Test doubles (ATS2, `ca_dbl.dats`; written from the ATS1 sources, compared through the emitted text): tmplab, tmpvar, funlab, funent (the closure of `funent_eval_*` is NOT computed: the cases set the `_fin`
  fields), d2env, util, the printers, `filenv_get_d2eclist`. The hitype/hisexp emitters are doubles on BOTH sides (`ca_dbl1.hats`: same text), they belong to another group.
* Coverage (gcov by ATS line): **2616 of 2619 executable lines (99.9%)**; the rest are two dead-code arms and a comment line.
* Mutation test (`camutate.py`): **107 deliberate bugs, 107 detected** (escapes, octal width, names, separators, kinds, orders, closures, tail calls, staload kinds ...; one survivor of the first run made me add a case).
* AddressSanitizer (`make -C test/ca asan`): no error, no leak. The literal/identifier sequences of ATS1 and ATS2 were also compared mechanically (only the `fprintf` splits and the view/option syntax differ);
  the differential test found one real bug of the first port (the missing backslash of the octal escapes).

### Open problems (emit)
* The real phase-1 modules (not the doubles) were not linked in this test; the first `make` of the integrated tree is the check. `emit_funent_implmnt` needs `funent_eval_*` to be correct.

## ccomp group C2 (dynexp/decl/claulst): pats_ccomp_dynexp, pats_ccomp_decl, pats_ccomp_claulst (rules C2-1 .. C2-10)

Done (typecheck, link, differential test, see Validation): `pats_ccomp_dynexp.dats` (`hidexp_ccomp`, `_ret`, `hidexp_ccompv`, `hidexplst_ccomp(v)`, the applications with tail calls, lists, records, arrays,
lambdas/fixpoints, `hidexp_ccomp_funlab_arg_body`), `pats_ccomp_decl.dats` (`hidecl_ccomp`, `hideclist_ccomp(0)`, function groups, `val`/`val rec`/`var`, `hiimpdec_ccomp(_if)`), `pats_ccomp_claulst.dats`
(`hiclaulst_ccomp`: the pattern matrices, the jump continuations, `fprint_tmprimval`). 5.4k lines of ATS1, 5.5k of ATS2. Same file and function names as `src/`; no change to `pats_ccomp.sats`.

C2-1. **Method.** By hand from the ATS1 text, with `utils/arenagen/port_ats1.py pats_hidynexp.spec:pats_ccomp.spec X.dats` for the first draft (constructors, views, fields): `case+ hde.hidexp_node of` is a
      match on `hidexp_node_view` (`~HDEx (..)`, a `v => (hidexp_node_view_free (v); ..)` arm for the wildcard), `val-HDEx (..) = node` is `val-~HDEx (..) = hidexp_node_view (..)`, the lists are `glist`
      (head first, as in ATS1). A loop that built a `list_vt` in place (`hidexplst_ccomp`, `labhidexplst_ccomp`, `hideclist_ccomp`, `hiclaulst_patcomp`, `auxclist`, `auxcomplst`) conses on a `List0_vt`
      accumulator and `glist_ofrev_vt` (`pats_ccomp_c2.hats`) makes the `glist` with one arena cell per element: the calls (and so the stamps of temporaries and labels) happen in the order of ATS1.
C2-2. **Proofs.** `the_d2varlev_inc ()`/`_dec ()` have no proof; `ccompenv_push (env)` still returns `(pf | ())` (`ccompenv_pop (pf | env)`, `ccompenv_localjoin (pf1, pf2 | env)`).
C2-3. **`funlab`/`instrlst` are the real types** (CC-4): `tmpvar_set2_tyclo` of ATS1 is the direct call `tmpvar_set_tyclo (tmpret, flab)`; `hifundec_set_funlabopt`, `hiimpdec_set_funlabopt/_instrlstopt` take `gopt (funlab)`/`gopt (instrlst)`;
      the `$D2E.d2cst_set_funlab` of `hiimpdec_ccomp` still wants the placeholder option: `$UN.cast{dynexp2_funlabopt} (opt)`. `list_copy (flabs)` of a mutual-recursion group is `glist_listize<funlab>`.
C2-4. **The private types of claulst** (`matoken`, `patcomp`, `patckontref = ref (patckont)`) are generated from `pats_ccomp_claulst.spec` (`make -C src2 pats_ccomp_claulst_gen.hats ..`; sats `pats_ccomp_claulst.sats`, gen dats
      included by the `.dats`): `patckontref` is a one-field record with a `mut` field (`patckontref_val`, `set_patckontref_val`), the patterns of ATS1 `_ when x1 as PTCMPany _` are `patcomp_is_PTCMPany (x1)` tests
      (same order of tests). The `rxs` (reversed prefix) of `patcomplst_jumpfill_rest` is a `glist`: each `PTCMPpatlparen` builds `glist_reverse (patneg :: rxs)` in the arena (O(n^2) cells per clause, never freed).
C2-5. **`patcomplst_subtest`** calls `auxmovfin` before the match on the result of `auxlst` (ATS1: only on the `Some_vt` branch; it only adds moves to a list that the `None_vt` branch frees) so that the `tmvlst` variable
      is consumed once. `tmpmovlst_vt` arguments are `&tmpmovlst_vt >> _`.
C2-6. **Kept ATS1 behaviour** (the test covers it): `hidexp_ccomp_ret` has no case for `HDEcstsp`, `HDEtyrep`, `HDEtempenver`, `HDErefarg`, `HDEerrexp` (INTERROR/exit), `hidexp_ccomp` none for `HDEarrinit` (exit), `HDEsif` prints
      "[sif] is not supported after proof-erasure." and gives `primval_error`; `val-Some` failures are `assertloc (gopt_is_some ..)`; the `int_of_llint` of `HIPintrep` is a cast (`g0int2int_llint_int` has no C);
      `hilab_ccomp`/`hilablst_ccomp` are implemented here under the name of the sats of ATS2 (in ATS1 the sats copy is never implemented, the .dats has a private one).
C2-7. **Not here** (declared in the sats, implemented by other groups): `hidexp_ccomp_loop(exn)`, `_ret_case/_delay/_ldelay/_lazyeval/_trywith`, `hipatck_ccomp`, `himatch(2)_ccomp`, `hifunarg_ccomp`, `ccomp_tmpcstmat/tmpvarmat`, the `ccompenv_*`.

### Validation (ATS1 reference = the objects of the main tree: `SRC=<main tree>/src make -C test/cc2 compare|cover|mutate|asan`; `make -C test cc2test` needs no ATS1)

* **Method** (`test/cc2/cc2_gen.py`, `cc2_cases.py`, `cc2_dbl.py`, `cc2_state.c`): ONE program of 418 scenarios (53 chunks, 39k lines, `CC2SEED=1 CC2SCALE=3`) in the common subset of ATS1 and ATS2, built by the generator of the hd test (random erased
  trees of every constructor with the smart constructors, patterns of small domain so that clauses overlap, declarations of every kind) and run by the ATS2 driver (`cc2dump.dats`: the real front end of src2 and the three ported modules)
  and the ATS1 driver (`cc2dump1.dats`: the real front end and the three ATS1 objects of `src/`). Everything else of ccomp is a TEST DOUBLE written once for both languages (the smart constructors of the trees
  generated from the sats, the five cells tmplab/tmpvar/d2env/funlab/funent, `ccompenv` in `cc2_state.c`, instrseq, and the functions of the other groups, which print their arguments and add a comment instruction);
  every double that changes a state prints a line `  | ...`, so the order of the calls, their arguments and the numbering of tmpvars/tmplabs/funlabs are compared; the results are dumped completely (`cd_primval`, `cd_instrlst`,
  `cd_primdec`, `cd_ibranchlst`, `cd_funent`..., generated from `pats_ccomp.spec` in both languages). Families: `exp` (value/ret/ccompv with levels, bindings, tail-call frames, template level, `tlcalopt` 0/1/2), `tail` (every kind of
  function value in a frame), `lists`, `lam` (lambdas, fixpoints, `hidexp_ccomp_funlab_arg_body`), `dec`/`fun` (every declaration, function groups of every kind, implementations), `claulst` (matrices of 1-3 columns,
  1-6 clauses, guards, every fail continuation). 8 cases end the process (`CC2EXIT=k`).
* **Result: stdout 25224 lines and stderr 236 lines byte-identical in ATS1 and ATS2; the 8 exit cases fail in both with the same stdout and the same messages** (`cc2cmp.sh`); `cc2.md5` keeps the md5 of the ATS1 output.
* **Coverage** (`make -C test/cc2 cover`, gcov by ATS line, the run and the 8 exit runs): **2150 of 2270 executable lines (94.7%)**: dynexp 915/924, decl 435/435, claulst 800/911; the rest is the debugging printers `fprint_patcomp(lst(lst))`/`fprint_tmprimval` (dead in ATS1 too), the `exit` arm printing of `hidexp_ccomp_ret` (covered only by the exit case, which stops before gcov writes), and arms of the tail-call table that no frame reaches.
* **Mutation** (`cc2mutate.py`, 37 deliberate bugs in the three modules: levels, tail-call counters, branches of `if`, kinds of records, template kinds, closures, function groups, `val+`, impdec, `var`, the matrix tests, the jump continuations, the order of the moves): **37/37 detected** (the first run missed one, `d2cst_set_funlab` of `hiimpdec_ccomp`, which made me dump `d2cst_get_funlab` after each implementation).
* **AddressSanitizer** (`make -C test/cc2 asan`, leak detection on): no error, no leak report, same stdout and stderr as the plain build.

### Notes for the integration agent, and doubts

* The doubles of pats_ccomp.dats/_ccompenv/... are NOT the real modules: the first thing to do after the merge is a run of `cc2dump.dats` with the real phase-1/C1 modules in place of `cc2_dbl2.dats` (the scenarios print the trees completely;
  the ATS1 reference output changes with the doubles of ATS1, so compare whole-file C output instead).
* The generated `*_gen*.hats` of `pats_ccomp.spec` and `pats_ccomp_claulst.spec` are produced by the rules appended to `src2/Makefile` (`CCC2GENHATS`); the phase-1 rules of the same files must be merged (same file names).
* `patcomplst_jumpfill_rest` allocates O(n^2) arena cells per clause (see C2-4): a `case` with thousands of clauses of 50 tokens would use hundreds of MB.

## ccomp group B (hitype/hipat/subst/template/main)

Ports of `src/pats_ccomp_{hitype,hipat,subst,template,main}.dats` (same file and external names, same output). Interface: `pats_ccomp.sats` (not edited by this group).

### Rules

* **hitype**: the private types `hit` / `labhit` (hisexp -> C type, the type tables) are arena types generated from `pats_ccomp_hitype.spec` (`--global`, `--compact`) into `pats_ccomp_hitype_gen{,_dats}.hats` (small, kept in git); the bodyless generated `fun`s need `pats_ccomp_hitype_priv.sats`. Matching goes through `hit_view` with `~` patterns and `hit_is_*` tests. The table of types is a `hashtbl_linprb`; keys that are pointers need `keyitm_is_null`. The equality of types returns a `bool` instead of raising `abort()` (a mismatch of the tags of sums cannot happen: the mutant that replaces the field comparison is caught, the one that ignores the tags is equivalent to ATS1's abort).
* **hipat**: `hipatck`, `himatch`, `himatch2`, `hifunarg` keep the order of the emitted instructions; `ccompenv_inc_freeconenv` is called before the match as in ATS1. Nested ATS1 closures are named functions with explicit environments.
* **subst**: `tmpvarmap` is a `linmap_avltree` keyed by `tmpvar`: the comparison `compare_key_key<tmpvar>` must be implemented at toplevel in the client (an implementation made inside the `local` of a library is not visible to clients); `pats_ccomp_subst.dats` does that after `staload _ = ./pats_ccomp_tmpvar.dats`, `#include "./mylibies.hats"` and `staload LM = libats/SATS/linmap_avltree.sats`. Instruction lists are `glist` and are reversed explicitly where ATS1 builds them backwards (`glist_reverse<instr>`).
* **template**: the `impenv` is a datavtype; the matchers take indexed lists (`{m,n:nat}`) so that the pairwise traversal needs no exception for lists of different lengths (ATS1 aborts). `ccomp_tmpcstmat` / `ccomp_tmpvarmat` return the `tmpcstmat` / `tmpvarmat` views.
* **main**: `ccomp_main` and its emitters; the lambdas of the ATS1 version are named functions (no cloref); the caches are arena cells.
* No GC: no `list`, `option` or `lam` closure on the heap anywhere in the five modules; `ref`s only from toplevel `var`s.

### Validation (`make -C test/ccb test|compare|cover|mutate|asan`; `make -C test ccbtest`)

* **Differential**: a generator (`ccb_gen.py`, `ccb_cases.py`; families hit, pat, tmpl, sub, main; `CCBSEED`, `CCBSCALE`) writes scenarios in the subset common to ATS1 and ATS2, with complete dumpers of every result; the ATS1 driver links the real ATS1 objects of the main tree (`ccb1.sh`), the ATS2 driver the ports plus phase 1's real modules (the copies in `dbl/`) (`ccb2.sh`). Mocks (`ccb_mock.hats`, `ccb_stub.c`) replace ccompenv, emit and the global lists. 281 scenarios, 38 chunks, 72036 lines of stdout and 573 of stderr: identical (`ccbcmp.sh`). `ccb.md5` is the md5 of the ATS1 output, so `make test` needs no ATS1 (about one minute).
* **Coverage** (`ccbgcov.sh`, gcov by ATS line, scale 3): 3010 of 3266 executable lines (92%) of the five modules.
* **Mutation** (`ccbmutate.py`): 36 deliberate bugs in the five modules, all detected (the first run left one survivor, a comparison that is unreachable in ATS1 too because it aborts; replaced by a mutant of the comparison of the fields).
* **AddressSanitizer**: no error; the only leaks are those of the mocks of `ccb_stub.c` (the global lists, stacks): the ports leak nothing. Stdout identical to the plain build.
* **Review**: the ports were written function by function next to the ATS1 sources (control flow, order of emission and of list construction, the places where ATS1 aborts or uses exceptions); the differential cases and mutants then check the result. No separate second reading pass was made after the tests passed.

## Driver and ccomp integration: pats_main.dats, pats_atspre.dats, `patsopt2` (rules DR-1 .. DR-10)

Done: `pats_main.dats` (the whole driver of `src/pats_main.dats`: `process_cmdline*`, `the_fixity_load`, `pervasive_load`, `the_prelude_load(_if)`, `do_depgen/taggen/atsreloc/codegen_2/jsonize_2`,
`do_trans1/12/123/1234`, `do_transfinal(2)`, `-o/--output(-w|-a)`, stdin, `-dd`, `patsopt_usage/version`, the exit status) and `pats_atspre.dats` (a stub, DR-9). `make -C src2 patsopt2 -j N` builds `src2/patsopt2`
(`-O2`, `-lgmp`, objects in `patsopt2.obj/`, `C3NSTRINTKND=intknd` and `P2OPT=`, `P2EXE=`, `P2OBJDIR=` are knobs; `make checkdrv` typechecks the two files). It runs with `PATSHOME` = the repository as the ATS1-built `src/patsopt`.
The first complete `patsopt` built from ATS2 sources: **no bug was found in the ccomp groups, the trans/constraint modules or the tools by the integration** (everything below is identical to ATS1); the only
problems were in the new driver text itself (typechecking: see DR-2, DR-3).

DR-1. **Build.** One object per module (`patscc -c`, from the directory `patsopt2.obj/`), all `pats_*.dats` of `src2/` except `pats_atspre`, `pats_lintprgm_solve` (included by `pats_constraint3_solve.dats`, C3-6) and
      `pats_lintprgm_myint_{gmp,int}` (included by `pats_lintprgm_myint.dats`), plus `pats_error_sats.o` (`patsopt --output .. --static pats_error.sats`, rule 17). 186 objects, 36 s with `-j24`. Typecheck of `pats_main.dats`: 0.3 s.
DR-2. **Dynload order** (`pats_main.dats`, no `#define ATS_DYNLOADFLAG 0`, rule 17: the dynloads run from `main0`'s own initialisation): error, basics, utils, global, intinf, counter, stamp, errmsg, symbol, label, filename, location, effect, fixity_{prec,fxty},
      reader, lexbuf, lexing*, tokbuf, syntax(_print), staexp1/dynexp1(_print), symmap, symenv, parsing*, trans1_env, e1xpval*, trans1_*, filename_reloc, **jsonize, depgen, taggen, comarg**, avlmap, staexp2*, stacst2, namespace, dynexp2 (dyncst2, dcst, dmac, dvar,
      print, util), trans2*, staexp2_solve, dynexp2_mapgen, patcst2, codegen2*, dmacro2*, trans3_error, dynexp3(_print), trans3_env*, trans3_{syncst,util,dynexp_up,..,decl}, lintprgm, lintprgm_print, lintprgm_myint, constraint3 (+ print, icnstr, simplify,
      solve, init, mapgen, jsonize), jsonize_synent2, histaexp*, hidynexp*, typerase*, ccomp, ccomp_print, hitype, tmplab, tmpvar, d2env, funlab, funent, util, ccompenv, instrseq, hipat, dynexp, caseof, claulst, lazyeval, trywith, looping, decl, subst, environ,
      template, emit, emit2, emit3, main. It is the union of the orders of the per-phase drivers (`f3dump.dats`, `toolmods.hats`, C3-10, CCM-12) and worked at the first run: no module needed to move. `the_prelude_load` calls `constraint3_initialize ()` right after
      `stacst2_initialize ()` (as ATS1) and `the_trans3_env_initialize ()` is called once per translated file (as ATS1; it is called per file there too).
DR-3. **ATS1 -> ATS2 changes of the driver.** `outchan` (`OUTCHANref/ptr of FILEref`: a datatype with arguments) is the pair of flat fields `outchan: FILEref`, `outchan_isptr: int`; `outmode` is an int (0 `w`, 1 `a`); the output file is opened/closed
      by two static C functions of a `%{^` block (`fopen` failure falls back to `stderr`, as ATS1). `waitknd` stays an enum datatype (`WTKnone ()`..). `comarg` is the flat `@(i, s)` (TL-1), patterns `@(1, key) when nif > 0`. `fn*` is `fun`
      (`fn*` is ATS1-only). `state.infil` is passed to the parsers as a `var fil: filename` copied back (an `&filename? >> filename` argument cannot be a record field). `parse_from_given_arglst_toplevel` (`-dd`) re-conses the first option
      argument (flat `comarg`, no `fold@`/`free@`) and gives `parse_from_givenames_toplocal2` a `glist(string)` (reversed). `fprintf` is `fprint_*` (version line, `#error(PATSOPT_ERROR_(..))`), `prerrln!` is `prerr_string .. prerr_newline`.
      `theOutFilename_get/set` (a `vbox` on a toplevel `var`) were dropped: nothing reads them. `main0` takes `argv` out with `argv_takeout_strarr` (TL-1); fewer than 2 arguments prints `Hello from ATS2(ATS/Postiats)!`.
      `process_ATSPKGRELOCROOT` does not exist in this `src/` (only `process_PATSRELOCROOT`, ported in `pats_comarg.dats`, called as in ATS1).
DR-4. **Exceptions.** `do_transfinal2` catches the five `PATSOPT_*_EXN` (prints `#error(PATSOPT_ERROR_(patsopt(FILE): trans2-errors))` when the output level is 1, counts the error, the process aborts with `FatalErrorExn` after the last file if
      `nerror > 0`). The other exceptions (`FatalErrorExn`, `PATSOPT_FILENONE_EXN`) are NOT caught by the driver, as in ATS1: the ATS2 runtime ends the process with status 1 and prints `exit(ATS): uncaught exception at run-time:\n<path>:FatalErrorExn(tag)`
      where ATS1 printed `exit(ATS): uncaught exception: <mangled C name>(tag)`; same status, different text by construction. A failed assertion (`assertloc`) and a MatchError also print a different text (the location of the source of the compiler; ATS1:
      `.. match failure.`, ATS2: `unmatched value at run-time:`). `--debug` error messages carry `[<compiler source file>]:` (ATS1) or `[<file>: <loc>]:` (ATS2). The text of a failed `fopen` of the prelude (relative `PATSHOME`) differs too (`fileref_open_exn`).
DR-5. **What is identical** (`REF` = `src/patsopt` of the main tree, ATS1-built; `src2/test/drvfiles.sh`, `drvopt.py`, `drvcc.sh`, `make -C src2/test drvfiles|drvopt`): stdout (the generated C, byte for byte, including `#line`/debug comments), stderr and the exit status of
      2383 `.sats/.dats` (prelude, libats, doc, contrib, utils, src (ATS1 syntax), src2 and its tests; 1625 give C code, 758 fail identically with an error report: ATS1 sources, files that need other libraries, deliberate errors) and 319 `.hats`, in
      `-s/-d` mode and in 14 more configurations (`--typecheck`, `--depgen`, `--taggen`, `--jsonize-2`, `--codegen-2`, `--constraint-export`, `--constraint-ignore`, `--atsreloc`, `--gline`, `--debug`, `--debug2`, `--tlcalopt-disable`; every file forced
      to `-s`; every file forced to `-dd`; `-IATS src2 -DATS FOO=1 -DATSBAR=2 --gline`) = about 38400 runs, **0 differences** after the normalizations of DR-4 (uncaught exception text, assertion location, the `--debug` tag, the time stamp of the C file);
      no timeout of the reference (the `p2at_trdn_exist` hang was not hit). Option lines: the 782 lines of `comtable.txt` and 387 new lines (`drvtable.txt`: two files, `-s` + `-d`, `-dd`, `-o` to a file / `-` / unwritable / append, type and parse
      errors in compile mode, `-DATS`, `-IATS` in both forms, stdin with `-`/`-d`/`-s`, missing files, `-h/-v/--help/--version`, unknown options) compare stdout, stderr, status and the written files: **0 differences**. No `PATSHOME`, `ATS2HOME` fallback, no argument: identical.
DR-6. **patscc flow**: the 235 programs of `doc/EXAMPLE` through `PATSOPT=<ref|patsopt2> patscc -DATS_MEMALLOC_LIBC .. -latslib` and executed: 163 identical (stdout, stderr, status), 68 do not build with the reference either, 4 differ only by an address,
      the program name, a temporary file name or a timing line (the C code is identical anyway).
DR-7. **Fixpoint**: `make patsopt2 P2EXE=patsopt2b P2OBJDIR=patsopt2b.obj PATSOPT=$PWD/patsopt2` (every module of `src2` compiled by `patsopt2` itself): the 186 objects and the executable are **bit-identical** to those compiled with the ATS1-built `patsopt`.
DR-8. **AddressSanitizer** (`P2OPT="-O1 -g -fsanitize=address"`, `NOULIMIT=1 ASAN_OPTIONS=detect_leaks=0` for `drvfiles.sh`: ASan needs no `ulimit -v`): 1191 files (every second file of the corpus), no memory error, same output; with leak detection on three large files:
      no report (the arena is reachable).
DR-9. **`pats_atspre.dats`** includes `share/atspre_staload.hats` only: the ATS1 file included the implementations of the ATS1 prelude (list, array, option ..) so that the compiler could `staload` them as `$ATSPRE`; in ATS2 every module includes the real
      prelude (and `list`/`option`/`array` of the old prelude do not exist in the no-GC prelude). `pats_main.dats` does not staload it. `utils/libatsopt` (`libatsopt_*` C names: `patsopt_main`, `the_prelude_load`, ..) keeps its `ext#libatsopt_*` names
      in `pats_main.dats` but `main0` is always defined (no `PATSOPT_MAIN_NONE` switch, no `ATS_DYNLOADFLAG 0` manual dynloading: a libatsopt of ATS2 sources would have to call `libatsopt_dynloadall`; not ported).
DR-10. **Speed and memory** (`/usr/bin/time`, 32 cores, `patsopt2` -O2 vs the ATS1 `patsopt` -O2, one file per process, prelude load included): 150 of the largest ATS2 sources of the repository: 65.5 s vs 57.8 s total (+13%), peak 219 MB vs 258 MB
      examples: `src2/pats_ccomp_emit.dats` 0.67 s / 150 MB vs 0.58 s / 185 MB, `src2/pats_main.dats` 1.06 s / 181 MB vs 1.05 s / 238 MB, `src2/pats_trans2_dynexp.dats` 1.09 s vs 1.15 s. A generated 8000-line, 900 KB file
      (6000 functions): 13.8 s / 1.24 GB vs 10.6 s / 1.34 GB (+30% time, -8% memory): no blow-up from the arena (it never frees; the ATS1 build holds the same data under the GC).

### Open problems (driver)
* The text of uncaught exceptions, aborted assertions, MatchErrors and `fopen` failures differs from ATS1 (DR-4); `drvfiles.sh` normalizes it. A `--debug` message carries the location of the port's source instead of the file of the ATS1 source.
* `libatsopt` (the library flavour with `libatsopt_dynloadall`) is not built from `src2`.
* The arena never frees: a process compiling thousands of large files in one invocation (`-dd` of many files) accumulates memory; the longest single input measured (900 KB) needed 1.2 GB.

## Completion of the port

Every file of `src/` now has a counterpart in `src2/`, except the build files of the ATS1 build, which have no ATS2 meaning: `CMakeLists.txt`, `CMKBLD/`, `Makefile.atxt`/`Makefile.gen` (the atsdoc generator of `src/Makefile`),
`Makefile_CBOOT{gmp,int}` and `CBOOT/` (C sources generated by ATS1 to bootstrap without ATS1; `src2/Makefile` builds from the `.dats` with `patsopt` itself, see DR-7). The sections above that say
"`pats_symmap_htlinprb.hats` is not ported", "`pkgsrcname_relocatize` not ported yet", "`pats_atspre.dats` is a stub" and "`libatsopt` is not built from `src2`" are superseded by this section.

CP-1. **`pats_symmap_htlinprb.hats`** is ported (`src2/pats_symmap_htlinprb.hats`) on `libats/hashtbl_linprb` (keys are the stamps, as ATS1; key 0 marks an empty slot through `hashtbl_linprb_keyitm_is_null`;
      the hash is the C function `patsopt_hashint_jenkin32`, same body as ATS1). It is disabled as in ATS1 (nothing includes it); `src2/symmap_htlinprb_check.dats` includes it and `make checkdrv` typechecks it.
      The `.dats`/`.hats` only typecheck: it is not linked with anything.
CP-2. **`pats_atspre.dats`** now includes what still exists of the ATS1 list of the prelude implementations (`pointer`, `reference`, `list_vt`, `array`, `option_vt`; `DATS/list.dats` and `DATS/option.dats` do not exist in the no-GC prelude).
      Nothing loads it (every module includes `share/atspre_staload.hats`); `make checkdrv` typechecks it.
CP-3. **libatsopt2** (`make -C src2 libatsopt2.a`, `make -C src2 libatsopt2test`). The objects of `patsopt2` without the driver (`pats_main_dats.o`, `pats_runtime_ats1.o`) plus
      * `pats_main.dats` compiled with `-DATS PATSOPT_MAIN_NONE` (`pats_main_none_dats.o`): no `main0`, and `#define ATS_DYNLOADNAME "libatsopt_dynloadall"`: the C function `libatsopt_dynloadall()` runs the `dynload`s
        of the file (the initialisation of every module, in the order of DR-2); `libatsopt_patsopt_main`, `libatsopt_the_prelude_load(_if)`, `libatsopt_pervasive_load`, `libatsopt_the_fixity_load`, `libatsopt_patsopt_version` keep the
        `ext#libatsopt_*` names of ATS1. ATS2 dynloading: a module with the default `ATS_DYNLOADFLAG` expects its flag to be defined by a `dynload` of it elsewhere (`ATSdynloadflag_ext`), so
        `libatsopt_ext.dats` has `dynload "./pats_main.dats"` (and `#define ATS_DYNLOADFLAG 0`: it has nothing to initialise).
      * `libatsopt_ext.dats`: `libatsopt_patsopt_main_opt(argc, argv)` (a `try` around `patsopt_main`: the exceptions of the compiler, e.g. `FatalErrorExn` after an error report, give `false`).
      * `libatsopt_ext.c`: the rest of the API of `utils/libatsopt/DATS/patsopt_ext.dats` in plain C: `libatsopt_comarg_{strlit,strinp,prefil,postfil}`, `libatsopt_comarglst_{nil,cons}`, `libatsopt_patsopt_main_arglst`
        (a `strinp` is written to a `libatsopt_string2file_XXXXXX` temporary file, preceded/followed by the `prefil`/`postfil`s seen so far, removed after the call), `libatsopt_patsoptres_main_arglst` and
        `libatsopt_patsoptres_get_{nerr,stdout,stderr}` (stdout/stderr captured by `dup2` to temporary files). The ATS1 comarg/list/result are ATS datatypes: here opaque malloc'ed pointers (never freed).
        Differences: the result function restores the descriptors 1 and 2 (ATS1 closes them), flushes the C streams, and reads the captured text from the start of the files.
      Not provided: `patsopt_tcats_d3eclist_{exn,opt}` (returns an ATS1 `d3eclist`; the level-3 tree is an arena `glist` here; nothing in the repository calls it).
      The host program provides the ATS2 run-time (a program with `main0`, compiled by `patscc`): `patscc -DATS_MEMALLOC_LIBC -D_GNU_SOURCE -include alloca.h prog.dats libatsopt2.a -lgmp`
      (`C3NSTRINTKND=intknd` and no `-lgmp` as for `patsopt2`). `src2/test/libatsopt2/libatsopt2_test.dats` + `run.sh` (`make libatsopt2test`) call the API: 15 checks (`main_opt` on 7 files of prelude/libats/doc/src2 in `-d`, `-s`,
      `--typecheck`, an erroneous file, a missing file and `--version`: the stdout (the C code) and the stderr are identical to `patsopt2`'s and the status is `exited normally` / `exited abnormally`; a `strinp` with `prefil`/`postfil`; the captured result
      of a good file and of a file with errors): 0 failures. An `exit` (`#error`, `#assert`) in the library kills the host process, as in ATS1.
CP-4. **`#error` / `#assert`** (`do_e0xpact_error/assert`, `pats_trans1_e0xp.dats`): the ATS1 code calls `exit {void} (1)` after printing to stderr (`prerr`), and so do the ports (`exit` of libc through `$extfcall`). Compared on
      `#error "boom"`, `#error 12`, `#assert (0 > 1)`, `#assert N` with `--output FILE` and on stdout: same stderr (`<loc>: error(1): [#error] directive is encountered: boom` without a newline,
      `<loc>: error(1): [#assert] failed!`), same status 1, and the output file exists and is empty in both (libc `exit` flushes and closes the streams; nothing has been written to it yet). Nothing to change.
CP-5. **Run-time messages** (`pats_runtime_ats1.c`, `assertloc`/`exitloc`: `pats_assert.hats`).
      * An uncaught exception: `exit(ATS): uncaught exception: <mangled path>__<name>(<tag>)` as ATS1 (was `exit(ATS): uncaught exception at run-time:\n<path>:<name>(<tag>)`). The ATS2 exception constructor carries `"<path>:<name>"`; the C
        handler mangles the path as ATS1 does (`/` -> `_2`, any other character that is not alphanumeric or `_` -> `_` + two hexadecimal digits: `-` -> `_2d`, `.` -> `_2e`, checked against atsopt on a path with `+?~#! `). `patsopt2` is linked with this
        run-time: `pats_main.dats` is compiled with `-D_ATS_CCOMP_RUNTIME_NONE_` (Makefile) and `pats_runtime_ats1.c` includes the ATS2 run-time files with the three handlers renamed and defines them. The library libatsopt2 does not carry it
        (the host program has the ATS2 run-time of its own).
      * A MatchError: `exit(ATS): <loc>: match failure.` / `exit(ATS): <loc>: funarg match failure.` (was `exit(ATS): unmatched value at run-time:\n<loc>`).
      * A failed `assertloc`: `exit(ATS): [assert] failed: <loc>` (was `<loc>` only). The 47 modules that use `assertloc`/`exitloc` include `pats_assert.hats` after `share/atspre_staload.hats`: it shadows the macros of `prelude/macrodef.sats`
        (`assert_errmsg2 (tf, "exit(ATS): [assert] failed: ", $mylocation)`). `exitloc` prints `<loc>\n` as ATS1 does (the ATS2 `exit_errmsg` would add `exit(ATS): `). ATS1 prints one more empty line after a failed assertion
        (its `#LOCATION` is concatenated with `"\n"`): ATS2 macros cannot concatenate strings, so that empty line is missing. Exit statuses are unchanged (1).
      * What stays different, by construction: the path (`src2/pats_x.dats` instead of `src/`) and the offsets of every location in these messages, and the tag of an exception (1029 for `FatalErrorExn` against ATS1's 1025: the numbers come from a counter in the run-time that
        counts exception constructors in initialisation order; four others are initialised before `pats_error.sats` in the ATS2 build, not investigated further), the empty line after `[assert] failed`.
      * The ATS2 library keeps its own messages (`prelude`'s `assert_errmsg`, `ArraySubscriptExn`, `AssertExn`..., the special cases of `atsruntime_handle_uncaughtexn`: `DivisionByZeroExn` etc. are printed as the generic text here).
CP-6. **Tests.** `drvfiles.sh` normalises: the whole `exit(ATS): [assert] failed: ...` line (and the empty line that ATS1 adds after it), the MatchError / funarg lines, the path and the tag of an uncaught exception, the `[file]:` of `--debug`, the time stamp
      (the old rules for the ATS2 texts are removed); `drvopt.py` lost its ATS2-text rules (its assertion rule already allowed both). `f3norm.sh` (drops every `exit(ATS)` line, locations and empty lines) is unchanged.
CP-7. **Validation** (ATS1 reference outside the repository, a rebuild of the old sources under a cache directory that has since been deleted: `SRC=<that dir>/src`, `REF=$SRC/patsopt`): `make -C src2 check`, `make drvfiles` (3649 files of prelude, libats, doc, contrib, utils, src2 incl. its generated test sources, as `-s/-d`): 0 differences; `make drvopt`
      (`comtable.txt` 782 lines, `drvtable.txt` 387 lines): 0 differences; `make libatsopt2test`: 0 failures; md5 suites `t1test s2test d2test m2test cgtest t3test t3g1 hdtest hstest lptest tooltest` as expected (`lpdrv2.sh` now copies `pats_assert.hats` to its temporary directory).
      `t2test` does not print `output as expected` in this worktree: the same happens with the unmodified HEAD (copied and rebuilt in /tmp), and the outputs of both builds agree once the checkout path is normalised: the md5 depends on the checkout path (`prelude/` locations), not on this work.
CP-8. **Other small deviations** found while reading the notes of the sections above (none fixed, all by construction): the stale notes listed at the top of this section; `queue_get_strptr1` (needs the removed `libats/linqueue_arr`; the only user
      `pats_lexbuf.dats` has its own buffer); the arena never frees (see "Open problems (driver)"); `fopen`-failure text of a relative `PATSHOME` (`fileref_open_exn`) is the ATS2 library's.

## Quality gaps closed

Branch `selfhost-gaps` (from `selfhost` c826e30d6). ATS1 reference: objects rebuilt from a copy of `ats1-ref/src` in a scratch directory (`make -j24 C3NSTRINTKND=gmpknd patsopt`; the C names of
the ATS1 objects contain the path of the source, so `f3dump1`/`d2dump1`.. must be linked against objects built where `SRC` is: a copy of the objects moved to another directory does not link),
the reference `patsopt` of `ats1-ref` for the driver tests.

### (1) The group tests and the md5 suites

* `t3g1`: the double of `d2var_get_type_some` was not in `t3g1env.tmpl` (that template is right) but the generators of the different tests all wrote the SAME file `t3env.hats` (`t3_gen.py`, `g2_gen.py`,
  `c3_gen.py`: with the double; `t3g1_gen.py`: without), so the test that was generated last decided whether `t3g1` linked (it failed after `make -j` / after `make all`). `t3g1_gen.py` now writes
  its own `t3g1envx.hats`/`t3g1envx1.hats` (included by `t3g1dump.dats`, `t3g1dump1.dats`, listed in `t3g1.mk`, ignored by git). `t3g1.mk` also regenerates the hats when only the (tracked) stamp
  `t3g1gen.stamp` exists (a fresh checkout).
* `make -C src2/test all` is not parallel safe (several targets compile `pats_*_dats.c` of the same name in the same directory, and the `pats_error_sats.c` rule): run it without `-j`
  (6 min). Result in the worktree and in a copy of the repository in another directory: every suite gives its md5 (`t1test t2test t3test t3filestest t3g1 g2test t3g3test g4test c3test j2test cgtest m2test
  s2test d2test lp hs hd cc cc1 cc2 ccb ca` and the unit tests, pardump, e1xdump, treedump).
* Three md5 files were stale or time dependent, not the code:
  - `ca/ca.md5`: the C file starts with `** The starting compilation time is: 2026-10-17: 11h: 7m` (the minute is padded with a BLANK) and the mask replaced digits by `#`, so the md5 depended on whether
    the run was made at a one-digit or a two-digit minute/hour. The mask (`ca/Makefile`, `ca/cacmp.sh`, `ca/camutate.py`) now replaces the whole line.
  - `t2cases.md5`, `t3cases.md5` (and `ca.md5`) were regenerated from the ATS1 output (`make t2compare t3filescompare`, `make -C ca small`; ATS1 and ATS2 identical). The new values are
    the same in three checkouts (`wt-gaps`, `/tmp/.../xcopy`, `/tmp/.../ATS-Postiats`: different name lengths), which also rules out offsets that depend on the path length.
* Location independence (item 5): the suites strip the checkout root (`sed "s|ROOT/||g"`, `f3anon.sh`); the only other dependences found were the time stamp above and the generated hats / stamp of `t3g1`;
  `t1test t2test t3filestest t3g1 ca` and `make -k all` were run in a second directory (a copy made from `git ls-files` + the untracked files, with `prelude libats ccomp share contrib utils src`; the
  generated `*_gen*.hats` must be copied or regenerated by `make -C src2 check`) and pass there with the md5 files of the first one. The old `src/` is still read by `tree1_gen.py` (`deepdump_t1.hats`)
  and by the `SRC=` default of the compare targets: they must be pointed at the ATS1 reference (`SRC=`) after the rename.

### (2) trans3: mutation and coverage

* New cases (`t3cases/`, ATS1 == ATS2 on all of them, `make t3filescompare`: identical, `t3cases.md5` regenerated, 40 files): `eff.dats` (effect variables `{fe:eff}`, `<!exn>`, `<!ntm>`, `<!ref>`, `<!wrt>`, `<!all>`,
  `$effmask_*`; note `:<fe>` is one token, `lam` takes no effect annotation, `-<fun,!exn>` needs the `fun,`), `up3.dats` (`$extfcall`/`$extmcall` with linear arguments, `$vcopyenv_v/vt`, `$arrpsz`,
  `$raise` in a pure function, untyped declarations whose result is every kind of literal / `$lst_t` / `'[..]` / `$lst_vt`, `lam@` bodies, `$literal(1)`), `pfm.dats` (views in flat tuples and records, nested,
  lambdas with proof arguments typed downward, `prfun`/`praxi`), `termet.dats` (mutually recursive functions whose metrics differ in length and sort, `.<>.`), `pat3.dats` (exhaustiveness of ints, chars,
  strings, bools, constructors, records, tuples), `abort4/5/6.dats` (`$literal(1.5)`, `("abc")`, `(1.5f)`: the pervasive `literal_float`/`literal_string` do not exist, INTERROR ends the process in ATS1 and ATS2).
  Found on the way: `scase` cannot be written with the syntax of ATS2 patterns (parse error in both compilers), an or-pattern `| 0 | 1 =>` does not exist, `!@(..)` is one token (write `! @(..)`),
  `$literal(float)` and `$literal(string)` always abort.
* Mutation (`f3mutate.py`, 30 mutants): the three survivors are now detected by the hand cases alone (each run with `f3mutate.py t3list.txt 1 K`, baseline of the unmutated copy against ATS1: 0 chunks differ):
  #6 (`npf > 0` in `p2atlst_trdn_arg`: `pfm.dats`, a `lam (pf | p) => ..` typed downward is the only path that marks the proof variable `isprf`, `fun` goes through `trup`),
  #13 (`termet_sortcheck`: `termet.dats`, a metric of a different SORT at the position of a longer adopted metric, `.<n>.`, `.<n,m>.`, `.<n,b>.` with `b:bool`), #14 (`util` `lin = 0`: `$lst_t(1,2)` in an untyped declaration:
  the prelude `list` is not needed, only the element variable's sort shows in the type). The other 27 are unchanged (corpus + cases), so 30 of 30; the full 30-mutant run on the new cases was not repeated.
* Coverage (gcov by ATS line, `f3gcov.sh` on 5266 translations: 2528 files x {FILE, RAW} of prelude, libats, src2, doc/EXAMPLE, contrib + the cases; the compiler `patsopt2` run through the same corpus for the
  modules the whole-file driver does not run: `svar` is used by the constraint solver, `patcst2` by the exhaustiveness checks of the solver; `python3 covunion.py DIR..` takes the union of gcov directories, `covexcl.txt`
  lists the lines no ATS source can reach: debug printers without a caller and functions without a caller). Before -> after, whole file / without the excluded lines:

  | module | before | after | after, reachable | excluded lines |
  |---|---|---|---|---|
  | env_svar | 63.0 | 72.6 | 94.5 | `fprint_the_s2varbindmap` |
  | env_lstate | 79.1 | 79.1 | 97.2 | 6 debug printers, `restore_linval_type`, `lstaftitmlst_reverse` (no caller) |
  | env_effect | 83.5 | 92.7 | - | |
  | env_pfman | 85.8 | 86.5 | 97.6 | `fprint_the_pfmanenv`, `add_dvarlst/dvaropt` (no caller), `pop_loop` on an empty stack |
  | util | 88.7 | 89.5 | 94.4 | `d3lablst_is_overld`, `d3explst_get_ind` (no caller) |
  | syncst | 79.8 | 90.8 | - | |
  | dynexp_up | 88.7 | 90.6 | - | |
  | patcst2 | 73.2 | 77.3 | 90.3 | `fprint_p2atcst` and co (debug), `p2atcstlstlst_of_vt` |

  (The "before" column is the same corpus measured again; the earlier text quotes other numbers because that corpus included generated files of `src2/test`.) The remaining unreached lines of `lstate`/`pfman`
  are two header lines of `d2var_search_sexp_at` / `sexp_tyrec` (views nested in flat tuples are never found: the proof search of `!p` fails on `@(int @ l1, int @ l2)` in both compilers) and the S2Eexi/S2Emetfun arms
  of `s2exp_is_cloref` in `util` (the type of a `D3Elam_dyn` is always an `S2Efun`/`S2Euni`); `dynexp_up` keeps ~26 MatchError arms (`| v => $ERR.abort_interr`), `scase` (4 lines) and `D2Esym` ones.
* No divergence between ATS1 and ATS2 was found by the new cases in any module.

### (3) Leaks on exception paths

Measured with `make f3dump_asan` (leaks on, every 8th line of the corpus + the cases = 739 translations): **39 LeakSanitizer reports** (42 direct + 32 indirect leaks, 2576 bytes, all `list_vt` cells of the accumulator
of `glist_map_loop`: 35 in `d0eclist_tr`, 6 in `d2eclist_tr`, 1 in `d1eclist_tr`), no memory error. ATS1 has no such leak by construction (its `list_map` result is garbage collected). The leak is the accumulator
`res` of the map over the declarations when `d0ecl_tr`/`d1ecl_tr`/`d2ecl_tr` raises one of the exceptions of the compiler. Fix (`pats_trans1.hats`: `glist_map_loop_g`/`glist_map_fun_g`, used only by
the three declaration-list maps): each element is translated inside a `try` that catches the compiler's exceptions (`FatalErrorExn`, `FatalErrorExn_interr`, `PATSOPT_FILENONE_EXN(s)`, `PATSOPT_FIXITY_EXN`, `PATSOPT_TRANS1..4_EXN`),
frees the accumulator and raises the same exception again (they carry no argument but the file name, so the exception is the same value: the text of the uncaught exception and the exit status are unchanged,
checked by the driver differential below). A handler of `try` cannot consume a linear variable of the enclosing function, so the accumulator is borrowed as a `ptr` before the `try`. The `setjmp` is paid per
declaration, not per element of every list (the other maps are not changed). After: **0 reports** on the same 739 translations. Not covered: an exception of the prelude (`Subscript` ..) leaking through the
declaration maps (none can occur in the compiler), and the nested maps below a declaration (an exception unwinds them too; ASan found no report from them).

### (4) Memory with many files in one process

`patsopt2 -d f1 -d f2 ..` (the driver takes several inputs; output byte-identical to ATS1 except the time stamp), the N largest `src2/pats_*.dats`, peak RSS / time:

| files | ATS2 | ATS1 |
|---|---|---|
| 1 | 208 MB, 1.09 s | 244 MB, 0.78 s |
| 5 | 333 MB, 2.2 s | 409 MB, 2.5 s |
| 20 | 688 MB, 6.4 s | 828 MB, 6.6 s |
| 60 (98 MB of C) | 1.49 GB, 15.3 s | 1.70 GB, 15.1 s |

About 24 MB per additional large file in both: ATS2 does not grow faster than ATS1 (the arena never frees, ATS1's GC has nothing to free either: the data of a file stays reachable from the global tables that a later
`staload` of the same file needs: the symbol tables, `filenv` with its `d2eclist`/`d3eclist`, the stamp counters). No per-file transient data that is provably dead was found (what is transient, the accumulators
and the `list_vt` of the typing, is already freed); a "free the arena at the end of each file" would break `staload` caching, so nothing was changed.

### Validation after the changes

`make -C src2 check`, `make -C src2 patsopt2`; `make -C src2/test drvfiles` (reference: ATS1-built `patsopt` of `ats1-ref`): 6825 files (.sats/.dats/.hats of prelude, libats, doc, contrib, utils, src2 with its test outputs), stdout/stderr/status
identical in every file (0 differences); `drvopt` on `comtable.txt` (782 lines) and `drvtable.txt` (387 lines): 0 differences.

Note (end of the gaps work): `t3cases/` has 41 files (`pat3.dats` was added last; `t3cases.md5` was regenerated after it, ATS1 == ATS2). Build outputs of the unit tests (`test_*`, `d1dump`, `e1xdump`, `pardump`,
`treedump`, `d1obj/`) are now ignored. In the second checkout the suites that ran and passed are `t1test t2test t3filestest t3g1 ca` and `make -k all` apart from the targets that were (wrongly) run in parallel with it;
`c3test`/`s2test`/`t3test`/`g*` passed in the worktree only after the last change (`make -C src2/test -k all` there: every suite gives its md5).

## pats2xhtml and libatsynmark

`utils/libatsynmark` (the library: `SATS/libatsynmark.sats`, `DATS/libatsynmark{,_psynmark,_pats2xhtml,_pats2xhtml_bground,_pats2xhtml_embedded}.dats`,
`dynloadall.dats`, `TEST/`) and `utils/atsynmark` (`pats2xhtml`) are ported to ATS2 / no GC on the modules of `src/` (lexer, tokbuf, parser,
`pats_syntax`, `pats_comarg`, ...). Same file names, same functions, same command line. Build (ATS1 is not needed): `make -C utils/atsynmark`
(builds `utils/libatsynmark/BUILD/libatsynmark.a`, `utils/atsynmark/BUILD/pats2xhtml`, copies it to `bin/`; needs `src/libatsopt.a`, built if missing);
`make -C utils/libatsynmark test` runs the md5 suite. Variables: `utils/libatsynmark/Makefile_vars`. The libraries `libatsynmark.a` and `libatsopt.a` are
linked as in `src/test/libatsopt`; `libatsynmark_dynloadall()` (C name kept) calls `libatsopt_dynloadall` and `the_trans1_env_initialize` once.

Rules applied (the rules above hold):
* `putc_type` (`char -<cloref1> int`) is the flat pair `@(env: ptr, fun: (ptr, char) -> int)`: `putc_make(env, f)`, `putc_call(putc, c)` (rule 13). Strings
  are built with a C buffer (`libatsynmark_sbuf_*`, in `libatsynmark.dats`). Functions called by the template bodies (`psynmarklstlst_free`, `putc_call`..) are in the
  `.sats` (a non-exported `fun` is invisible at the instantiation: `PMVerr` in the C code). Every module has `ATS_DYNLOADFLAG 0` (nothing to initialize).
* `psynmark` is `@(lint, synmark, int)` (rule 10); `synmark` is an enumeration (the `globalref` constructors, which nobody could build, are nullary);
  `charlst` is `glist(char)`; `d0eclrep`/`guad0eclrep` come from `libatsynmark.spec` (arenagen, `make -f Makefile_build gen`).
* `lexbufobj`/`tokbufobj` are `= ptr` allocated with `ptr_alloc`; `list_vt` accumulators + reverse replace the in-place `fold@` constructions;
  a `val () = (case .. of ..) : void` whose branches change a `&res >> res` list is unsolved (`n >= 0`): make the `case` the body of a function.
* New in the API: `libatsynmark_char_list_vt_make_file` (`char_list_vt_make_file` is gone), `libatsynmark_fopen_exn` (the ATS1 `fopen_exn` message),
  `libatsynmark_dynloadall`, `putc_make/putc_call`. `psmss` type arguments of the `&` parameters are `>> T`.
* `pats2xhtml_main.dats`: `outchan` is `@(0|1, FILEref)`, string patterns are `if key = ".."` chains, `printf` is `fprint_string`; the options and their quirks
  (`-d` followed by an option takes it as a file name, `-o`/`--output` before the file, ...) are unchanged.

Validation (ATS1 reference = `utils/libatsynmark`/`atsynmark` of commit 2ac9ab45d built with ATS1 0.2.12 against the old `src/` objects; the ATS1 `libatsopt.a` was
renamed with `objcopy --redefine-syms` because the path of the checkout is in its C names; `api1.dats` is the ATS1 twin of `TEST/test03.dats`):
* pats2xhtml, ATS1 against ATS2, stdout + status + stderr + written files: 2458 repository files (prelude, libats, doc, contrib, src, utils, ...; 7 modes each
  `-s/-d`, `--embedded`, `-o`, stdin: 17206 runs), 251 ATS1 sources of the old `src/` (1757), 4000 fuzzed files (truncation, deleted/duplicated lines, inserted
  tokens, byte flips; 28000 runs), 129+54 hand-written edge cases (comments nested/unterminated, strings/chars with escapes, every number form, `#` directives,
  `%{ %}`, `$extype`, unicode, invalid UTF-8, CRLF/CR, BOM, 100 KB lines, 3000-deep nesting, ...; 1281), 2097 command lines (every option alone, with files,
  `-DATS/-IATS`, `-o` to bad paths, waiting states, 1500 random combinations): 0 differences. The API (`test03`: the tokens through the 3 lexbufobj makers,
  psynmarks and split, `lexbufobj_level1_psynmarkize`, the 4 `*_pats2xhtmlize_*`, `fstring_putc/fhtml_putc`, the 3 `*_psynmarklstlst_process`,
  `charlst_declitemize` + `d0eclreplst_find_synop`): 13545 runs, 0 differences (26 where ATS1 aborts, see below).
* `TEST/suite.py` (5228 cases, `expected.md5` made from the ATS1 programs; no ATS1, any directory, locale pinned): `make -C utils/libatsynmark test`.
  Deliberate mutations of the port (28: marks, begin/end tests, list order, escapes, option handling, class names, ...): all 28 make the suite fail.
* gcov by ATS line (`patsopt --gline`, -O0, all corpora): `pats2xhtml_main/level1` 100%, `libatsynmark.dats` 99% (the rest: `fprint_position`, which ATS1 declared
  but never implemented, and unreachable lines after `abort`), `libatsynmark_psynmark.dats` 96.7% (dead code of ATS1 too: `s0rtopt_mark`, `a0msrtlst_mark`, the
  `SMscst_*`.. arms; plus a few lines that gcov attributes to the wrong line).
* AddressSanitizer with leak detection (our objects instrumented, `libatsopt.a` not): pats2xhtml on 3000 repository files, the CLI and edge sets, and `test03`: no
  error, no leak (the only reports are the driver's own `malloc`ed symbol names).
* Speed (264 files, 3.9 MB, one process per file): ATS1 1.18 s, ATS2 1.44 s; one 2.2 MB file: 2.95 s / 3.30 s (a malloc per `_view` match).

Differences from ATS1 (all by construction):
* Uncaught exceptions print the ATS2 run-time text (path and tag differ), as for patsopt (CP-5); the status is the same.
* A NUL byte outside a string or comment: the ATS1 lexer makes it a symbolic identifier (`strchr` finds the terminator), the ATS2 lexer reports an unsupported char and
  skips it. This is a difference of `src/pats_lexing.dats`, not of this port (the suite has no such input). The stack overflow of the parser comes at the same size
  in both (a 100000-term expression; 50000 is fine).
* `charlst_declitemize`: ATS1 raises a `MatchError` (in `EOLgetpos`) when two declarations are on one line; the port returns what is left of the text.
* `libatsynmark_fopen_exn` reproduces the ATS1 messages; `-o` to a path that cannot be opened keeps the ATS1 behaviour (output to stderr, `nerror`).
* `d0eclrep`, `psynmark`, `putc_type`, `charlst`, `tokenlst` have the types above (clients such as `share/DOCUGEN/htmlgendecl.*` are GC-style ATS and are not ported).
* `utils/libatsynmark/CBOOT/Makefile` (the ATS1 C bundle) is removed.

## atsdoc and libatsdoc

`utils/atsdoc` (the tool: `SATS/atsdoc_translate.sats`, `DATS/atsdoc_{main,translate,translate_error,translate_item}.dats`, `atsdoc_translate.spec`, `HATS/*.hats`, `TEST/`) and
`libatsdoc` (the run-time library of the generated programs: `SATS/libatsdoc_{atext,symbol}.sats`, `DATS/libatsdoc_{atext,symbol}.dats`, `CATS/`, `dynloadall.dats`,
`libatsdoc_atext.spec`) are ported to ATS2 / no GC. ATS1 is not needed to build or use them. Size: the tool 2100 lines (ATS1: 2100), HATS 940 (ATS1: 900), the library 1270
(ATS1: 6500 for libatsdoc, which also held a lexical buffer, readers, locations, file names, symbols and maps). Build: `make -C utils/atsdoc` (`bin/atsdoc`, and
`ccomp/atslib/lib/libatsdoc.a` through `libatsdoc/Makefile`; `make -f Makefile_devl bin_atsdoc`, not part of `all`: it needs `src/libatsopt.a`, which `all` builds, and takes 10 s); `make -C utils/atsdoc test`
runs the md5 suite. The pipeline of an `.atxt` file is now

    atsdoc --outcode X_atxt.dats -i X.atxt > X_atxt.txt
    patscc -DATS_MEMALLOC_LIBC -o X_atxt.exe X_atxt.dats -latsdoc
    ./X_atxt.exe > X

(`atsdoc` generates no `main`: the `.atxt` files have their own `implement main ... = fprint_filsub (stdout_ref, "X_atxt.txt")` in a `%{ %}` block, which must be `main0` in ATS2.)
The generated program (the `--outcode` file) is byte for byte what ATS1 generates; the text is too.

Design (the rules above hold):
* `atext` is a handle into the global arena (arenagen `--global`, `libatsdoc_atext.spec`: nil, strcst, strsub, apptxt2/3, appstr2/3, concatxt, concatxtsep), nonlinear as in ATS1, never freed. The ATS1
  functions are smart constructors with the same names (`atext_strcst`, `atext_apptxt3`, ...); match on `atext_view(x)` with `~ATEXTnil()`.. A list of atexts is a `glist(atext)` (rule 9);
  `atext_concatxt_vt`/`atext_concatxtsep_vt` (new) take a `List0_vt(atext)`. The strings given to the constructors are copied into the arena (a `string` can be the freed `strptr` of the caller);
  `atext_strptr` & co consume the `Strptr1` and keep its string. `theAtextMap_search` returns `Option_vt(atext)`. `file2strptr` is C, `tostring_fprint` uses `tmpfile` (the prefix is not used).
* libatsdoc.a is self-contained: the table of the symbols (`libatsdoc_symbol.sats`, the ATS1 API: `symbol_make_string`, `symbol_get_name/stamp`, `compare`..) is a C hash table
  (`CATS/libatsdoc_symbol.cats`), `theAtextMap` stores the value in the symbol, the readers of `fprint_strsub/fprint_filsub` are 30 lines of C (`libatsdoc_rd_*`), and `sbuf` (`CATS/libatsdoc_sbuf.cats`)
  replaces the `stroutptr` (a `linqueue_lst` of chars). So it does not use (nor need the initialization of) the modules of `src/`: `-latsynmark -latsdoc -latsopt -lgmp` links
  (the other design, linking `pats_symbol` & co into libatsdoc.a, cannot be mixed with libatsopt.a: both would define the `__dynloadflag` of these modules).
  The other modules of ATS1 libatsdoc (lexbuf, reader, location, filename, symmap, error) are not ported: nothing but atsdoc itself used them; atsdoc uses the ones of `src/`.
* `dynload "libatsdoc/dynloadall.dats"` works as before; the name of the function it calls contains the path of that file (a rule of patsopt): compile the programs with the PATSHOME that libatsdoc.a was built
  with. `libatsdoc_dynloadall()` (`#define ATS_DYNLOADNAME`) has a fixed name. Inside the library `staload "./../SATS/x.sats"` (not `"libatsdoc/SATS/x.sats"`: the C names embed the path as found).
* atsdoc itself (`libatsopt.a`; the modules are initialized by `libatsopt_dynloadall`): `lexbuf` = `pats_lexbuf` (`lexbuf_set_position` is `lexbuf_reset_position`), positions and locations = `pats_location`;
  `funarg`, `tranitm`, `docerr` are arenagen trees (`atsdoc_translate.spec`), `funarglst` a `glist`, the lists of items and errors are cells of the global arena holding a `glist`, `stroutptr` is `sbuf`, `docerr_node` is an `int`.
  The file name: ATS1 looked the name up in its own lists of paths (both empty in atsdoc: a relative name is searched in the current directory, the full name is the normalized absolute path,
  the name that is printed in the messages is the one given), `filenameopt_make_relative` of `src/` searches differently: `atsdoc_filename_make` redoes the ATS1 lookup with `filename_make`, and `fprint_loc` prints the given name.
  The command line is a loop over `argv` (same state machine, same quirks, same messages including `waring(ATSDOC)`), outputs are two cells (file, own?). `fprint_newline` of the ATS2 prelude checks the output and
  exits; the ATS1 one ignores the errors and flushes: `libatsdoc_fprint_newline` does the latter. A NUL in an external code block or in a string argument is an error (`exit(ATS): a string cannot contain null
  characters in the middle.`, status 1) as in ATS1; `isspace/isdigit` are the ones of the C locale, EOF of a string reader is -1 as in ATS1 (the byte 0xFF ends a string).
* HATS (`postiatsatxt.hats`, `xhtmlatxt.hats`, `docbookatxt.hats`, `pats2dbookatxt.hats`, `pats2xhtmlatxt.hats`, ported from the ATS1 install, where they were the only files of `utils/atsdoc` besides the sources): `#include "share/atspre_staload.hats"`,
  `libats/libc` for `time`, `sprintf` -> `string0_append*`/`tostrptr_int`, `ref` -> `ref_make_viewptr` on a toplevel `var`, `Option` -> `Option_vt`, `timestamp()` copies the `ctime` string
  (`string0_copy`), `pats2xhtmlatxt.hats` staloads `utils/libatsynmark/SATS/libatsynmark.sats` as `$PSM` (programs that use it call `libatsynmark_dynloadall()`, are compiled with `-I$PATSHOME/src` and linked with
  `libatsynmark.a libatsdoc.a libatsopt.a -lgmp`). `utils/atsdoc/DOCUMENT/TUTORIALATS/tutorialatxt.dats`, which 6 files include, is neither in the repository nor in the ATS1 install: not ported.

Validation (ATS1 reference = `atsdoc` 0.2.12 of the ATS1 install and its `libatsdoc.a`):
* `--outcode` on the 415 `.atxt` files of the repository (`-i`): the text (stdout), the program, stderr (2 files have errors) and the exit status are identical for 415/415. No adaptation of the generated programs
  was needed (they contain no `main`), so there is no difference to report.
* 218 hand-written cases (unclosed argument lists and strings, `\#` `\\` `##` `\<newline>`, nested placeholders in strings, `#name{..}`, `#f[res]`, funres errors, `#` and `%` at the end, empty file, CRLF, NUL and non-ASCII bytes,
  1 MB lines, 20000 calls, 100+ errors, every option and quirk of the command line, bad files and outputs, `/dev/full`, directories as input, stdin): stdout, stderr, status and written files identical.
  126000 fuzzed runs (random token soups and mutated pieces of the corpus, `-i` and stdin): 0 differences (the same under ASan+LeakSanitizer, 20000 runs).
* libatsdoc: `TEST/drv.dats` (ATS2) and `TEST/drv1.dats` (ATS1, with the ATS1 `libatsdoc.a`) execute scripts of commands (every function of the atext API, `fprint_strsub`, `fprint_filsub` on 7 files including a 500 KB one and
  missing ones, `atext_filepath`, `tostring_strsub`, 0xFF and 0xE9 bytes): 110000 scripts, 0 differences (20000 of them under ASan+LeakSanitizer). The only difference found: a cycle of strsub definitions overflows the stack in both.
* End to end on `prelude/SATS/CODEGEN/{bool,char,integer}.atxt` in a scratch copy (see the list below for the changes): the `.sats` equal the tracked ones except the `Time of generation` line.
* ASan/LeakSanitizer on the 415 files, the 218 cases and the library: clean (it found 2 leaks of mine, fixed).
* Mutations (`TEST/mutate.py`): 26 deliberate bugs (identifier and digit classes, the columns of `%{` and `%}`, the delimiters, string escapes, the limit of 100 errors, messages, the counter of tokens, `-h`/`-oc` states, NUL check, relative
  names, `\#`, unknown tokens, `concatxtsep`, newline, signed chars, replacement in the map, ...): 26 detected.
* Speed (one process per file): the 415 files take 0.75 s (ATS1: 0.58 s; the start of the ATS2 program initializes the modules of `src/`: 1.8 ms against 1.4 ms per file); a 5 MB file (100000 calls, a 200000-line
  block): 0.45 s against 1.52 s.
* `TEST/suite.py`: 2653 md5 cases (56 files of the repository kept in `cases/`, the edge cases, 600 fuzzed ones, the command lines, 1515 API scripts; `expected.md5` is made from the ATS1 programs), 4 s, `make -C utils/atsdoc test`;
  it passes in a copy of the tree in another directory under `LC_ALL=de_DE.UTF-8` (the Makefile pins `LC_ALL=C`: the md5 sums contain `perror` messages and sorted names, and `PATSHOME` to the canonical root: the
  C names of the dynload functions contain it).

What phase 2 (adapting the `.atxt` corpus) has to change. Counts are `.atxt` files, from a scan of the 991 `%{ %}` blocks and of the 12 helper files that they include (`prelude/*/CODEGEN/*_atext.hats`, `doc/**/MYTEXT/*`, `share/DOCUGEN/*`), "affected"
including the files that include a helper that has the construct; and, in brackets, the files whose ATS2 compilation stops at that error (first phase that fails; all 415 fail now):
* `implement main (argc, argv) = ..` / `main () = ..` (ATS1 `main` returning void): 289 files -> `main0`.
* `sprintf (fmt, @(..))` returning a `strptr`: 110 (37 blocks, 7 helpers) [27 stop at `sprintf`]; `printf/fprintf/prerrf`: 49 [16 at `fprintf`]; `string_of_strptr`: 57 [16]. There is no variadic: `string0_append{3,4,5,6}`, `tostrptr_int`,
  or a `%s`-only helper (the scratch tests used overloads of `sprintf` on flat tuples of strings, 12 lines of C, and that was enough for bool/char/integer).
* `staload "prelude/DATS/list.dats"` (does not exist; `list_vt.dats`, `reference.dats`, `unsafe.dats` do): 75 [73]; `List`, `list_cons/list_nil/list_reverse/list_of_list_vt` (the atext lists, `res: atextlst = list_nil`): 63 -> `glist_cons<atext>`,
  `glist_reverse<atext>`, or `atext_concatxt_vt`; `Option/Some/None`: 60 (helpers) -> `Option_vt`.
* `staload "libc/SATS/{stdio,time,math,..}.sats"`: 75 [89 time.sats, 45 stdio.sats] -> `libats/libc/SATS/..`; `$TIME.time_get/ctime`: 50 (the `timestamp()` of the helpers; the ATS2 version is in `postiatsatxt.hats`);
  `$STDIO.fopen_exn/fclose_exn`, `open_file_exn/close_file_exn`: 22; `$UN.cast2ptr/castvwtp1/..`: 52 (some renamed).
* `ref<T>`, `!r := v`: 33 (helpers: counters and prefixes; `ref_make_viewptr` on a toplevel `var`, as in `pats2xhtmlatxt.hats`); closures (`:<cloref1>` nested functions, `lam`, `=<cloptr1>`): 51 (the nested `fun .. :<cloref1>` called directly lose the annotation);
  `$delay/stream`: 8; `datatype`, `viewtype`: 1; hash tables of libats in the blocks: 11.
* the helpers of the documents: `declatext.dats`, `htmlgendecl.dats` (share/DOCUGEN, 122 files stop at `srcfilename_get`/`decltitle`), `ats2tutorial.dats` (30), `int2proginats.dats` (18), `mytextfun.hats` (8), `prelude_*_atext.hats` (22) are ATS1 programs
  with the constructs above, plus `staload "libatsdoc/..."`/`dynload "libatsdoc/dynloadall.dats"` (100 blocks; unchanged) and `#include "utils/atsdoc/HATS/postiatsatxt.hats"` (81; unchanged, now in the repository).
* missing files: `utils/atsdoc/DOCUMENT/TUTORIALATS/tutorialatxt.dats` (6 files), `./ATEXT/ats2cairo.dats` (6), `htmlgendecl_data_atxt.dats` (1, generated by an earlier step).
* the Makefiles run `atscc ... -latsdoc` (ATS1) on `X_atxt.dats`: use `patscc -DATS_MEMALLOC_LIBC`; the documents that use pats2xhtml add `-I$PATSHOME/src`, `utils/libatsynmark/BUILD/libatsynmark.a` (`make -C utils/libatsynmark install` puts it
  in `ccomp/atslib/lib`) and `libatsopt.a` (note that `ccomp/atslib/lib/libatsopt.a` may be an older build: the C names embed the path where `src` was built).
Changes made in the scratch copy for the end-to-end run: bool.atxt (2 `sprintf` -> `string0_append6`, `main` -> `main0`), char.atxt (`main0` and the `sprintf` shim), integer.atxt + `prelude_SATS_atext.hats` (the shim; the two `staload` of list -> arena; `list_nil`/`list_cons`/
`list_reverse` -> `glist`; one `:<cloref1>` dropped).

Open problems (atsdoc and libatsdoc):
* The error messages of the ATS2 prelude when an output fails (`exit(ATS): [fprint_string] failed.` without the newline of ATS1) are not reproduced exactly (the exit status is); `/dev/full` as `--outcode` gives the same result as ATS1.
* A cycle of `#name$` markers between two `atext_strsub` values recurses forever (stack overflow), as in ATS1.
* `libatsdoc_dynloadall()` does not initialize libatsopt/libatsynmark: a program that uses `pats2xhtmlatxt.hats` calls `libatsynmark_dynloadall()` itself.

## atsdoc corpus adaptation (phase 2: the 415 `.atxt` templates and their helpers on the ATS2 pipeline)

The templates are now ATS2 programs under the no-GC rules; the pipeline of every directory is
`atsdoc --outcode X_atxt.dats -i X.atxt > X_atxt.txt; patscc -DATS_MEMALLOC_LIBC -o X_atxt.exe X_atxt.dats -latsdoc [-latslib]; ./X_atxt.exe > X`
(documents that use pats2xhtml: `-I$PATSHOME/src -latsynmark -latsdoc -latslib -latsopt -lgmp`). Nothing needs ATS1 any more, not even `make -f codegen/Makefile_atslib`.

What changed (289 `.atxt`, 15 helper files, 47 Makefiles/Makefile.atxt/Makefile.gen, the docs; counts of the lists above in "atsdoc and libatsdoc"):
* `main`/`main ()` -> `main0` (288 files; mechanical, inside `%{ %}` blocks only).
* `utils/atsdoc/HATS/atsdoc_compat.hats` (new, included by `postiatsatxt.hats` and `xhtmlatxt.hats`, and by the 73 templates that include no helper): the ATS1 spellings that the blocks use.
  `sprintf/printf/fprintf/prerrf (fmt, @(s1, .., sn))` for 1 <= n <= 16 string arguments (all conversions are `%s`; overloads on flat tuples of strings, one variadic C function
  `atsdoc_vsprintf`; `atsdoc_compat_gen.py` generates the overloads; a template that formatted an int, `%i` in `HR`, uses `tostrptr_int`), `string_of_strptr` (the string is never freed, as when
  it was GC'ed), and `staload` of `libats/SATS/arena.sats` + `libats/DATS/arena.dats` (templates of `glist`). A generic tuple template (`@(a1,a2)` with `a1,a2:t@ype`) does not work:
  the C struct of the instance and the one of the call differ (`ptrk` against `string`): hence monomorphic overloads.
* lists of atexts: `list_nil/list_cons/list_reverse/list_of_list_vt (list_reverse ..)` -> `glist_nil()/glist_cons/glist_reverse` (`atextlst` is a `glist`: the three
  `prelude_*_atext.hats`, which 110 templates include, and `prelude/DATS/CODEGEN/float.atxt`), `case+ xs of list_cons ..` -> `case+ glist_view(xs) of ~GLcons ..` (`theCodeLst` of the four book helpers, `share/DOCUGEN`), `:<cloref1>` nested
  functions lose the annotation, `ref<T>` -> `ref_make_viewptr` on a toplevel `var` (`theCodeLst`, `declatext.dats`), `staload "prelude/DATS/list.dats"` deleted, `libc/SATS/` -> `libats/libc/SATS/`,
  `$STDIO.fopen_ref_exn/fclose_exn` unchanged (they exist; link `-latslib`), `string1_of_string/string_make_list_rev_int` (`stringrepl` of `ccomp/atslib/Makefile.atxt`) -> a loop on the copy of the string,
  `addr_is_gtez/strptr_is_null` (mytextfun.hats) removed (`string_pats2xhtmlize_bground` returns a `Strptr1`), `dynload "utils/libatsynmark/dynloadall.dats"` -> `libatsynmark_dynloadall ()`.
* `\X` in a string: ATS1 kept the backslash of an unknown escape (`"\#"` has two characters and `fprint_strsub` turns `\#` into `#`), the ATS2 lexer rejects it. In the arguments of the placeholders
  (the text that atsdoc copies into the program: `\\` -> `\`, `\#` -> `#`) 20 places of 11 files now have 2 more backslashes (a script reads the offsets that atsdoc prints in the program,
  the rule is "an odd run of backslashes before the character in the program becomes even"); in blocks, `\${ATSHOME}` -> `\\${ATSHOME}` (32 files). The program text is the same string.
* a module must not `dynload "libatsdoc/dynloadall.dats"` twice (the flag is defined by each `dynload`, in one module or in two modules of a program): the explicit `dynload` was removed from the 19
  INTPROGINATS-2013-03-24 files, 3 man pages and `htmlgendecl.atxt` (its helper hats file does it); `htmlgendecl.dats` (a separate module) defines `ATSDOC_NO_DYNLOAD` before including `xhtmlatxt.hats`.
* `#itemizedlist{item1, item2}` is `itemizedlist$lst(item1, item2)` (ATS1: `f$lst (..)` built a list): the one chapter that uses it defines `itemizedlist$lst (x1, x2)`.
* `share/DOCUGEN/{declatext,htmlgendecl}.{sats,dats}` (122 documents; 114 run): `datatype declitem`/`paramadd` (rejected: non-nullary constructors) are flat tuples `(tag, string, string)` with
  `#define DITMname 0 ..` in the SATS, lists are `glist`s of the arena, `List_vt (strptr1)` is `List0_vt (Strptr1)`, `htmlgendecl.atxt` reads the source with `libatsynmark_char_list_vt_make_file/_fopen_exn`.
* Makefiles: `Makefile.gen` (the symlinks point at `share/Makefile.gen`, two symlinks of the libz3 and libevent DOCUGEN directories were dangling and are fixed), the 24 `Makefile.atxt`
  (their text: `PATSCC`, `PATSCCFLAGS=-DATS_MEMALLOC_LIBC`, no `.sats` objects, `-latsynmark -latsdoc -latslib -latsopt -lgmp`, `-IATS $(PATSHOMEQ)` only), the generated `Makefile`s (regenerated; the
  tracked ones of 7 DOCUGEN dirs were older than their templates, so those diffs show more than the compiler lines), the book/EFFECTIVATS/cairo/jansson Makefiles (`ATSCC -D_ATS_NGC` -> `PATSCC -DATS_MEMALLOC_LIBC`).
  `Makefile_devl bin_pats2xhtml` installs libatsynmark.a into ccomp/atslib/lib. Release flow: two bugs of the swap are fixed (`src/Makefile clean` called `make -C test` that is not packaged;
  `doc/DISTRIB/ATS-Postiats/Makefile_dist cleanall` called `cleanall` of src/CBOOT): `make -C src CBOOT && make -C doc/DISTRIB atspackaging atspacktarzvcf_gmp` makes ATS2-Postiats-gmp-0.4.3.tgz (79 MB, 2746 entries); re-added to the CI.

Validation (`/tmp` scratch; ATS1 reference = the ORIGINAL templates of the commit before this work, run with ATS1 atsdoc/atscc and libatsdoc; the DOCUGEN and mytextfun documents with an ATS1 build of
libatsynmark (`git show 2ac9ab45d:utils/libatsynmark`, built with `atscc` against the ATS1 build of the old `src/`) and the ATS1 build of share/DOCUGEN; text compared after replacing the time stamps by `<TIMESTAMP>`):

| group | templates | identical | differ | cannot run (ATS1 and new alike) |
|---|---|---|---|---|
| a. prelude CODEGEN (SATS 36, DATS 38, DATS/SHARE 14, CATS 22) | 110 | 106 | 4 (the `Makefile.atxt`: compiler lines) | 0 |
| contrib CODEGEN (jansson, cairo) | 2 | 2 | 0 | 0 |
| b. other Makefile templates (DOCUGEN 17 + Makefile_html, ATSLIB, MISC, ccomp/atslib, DISTRIB) | 21 | 3 (ATSLIB, MISC, ccomp/atslib: patscc already) | 18 (compiler lines) | 0 |
| c. doc/DISTRIB/ATEXT | 48 | 48 | 0 | 0 |
| d. DOCUGEN documents (114 two-stage, 3 single) | 128 | 117 | 0 | 11 (8 describe `.sats` that the no-GC prelude/libats removed: arrayref, fcontainer, giterator, list, matrixref, option, stream, hiredis_ML; mylib_dats/mylib_html: `#implement(..)` is a syntax error and libats/ML is gone; share/DOCUGEN/htmlgendecl.atxt is the program, not a document) |
| d. books and tutorials (ATS2TUTORIAL 30, FUNCRASH 21, INT2PROGINATS 37, APUE3 2, cairo 6) | 96 | 90 | 0 | 6 (cairo TUTORIAL: `utils/atsdoc/DOCUMENT/TUTORIALATS/tutorialatxt.dats` is neither in the repository nor in its history nor in the ATS1 install) |
| d. EFFECTIVATS | 9 | 3 | 0 | 6 (`stacode`, `dyncode`, `patsyntax` are undefined: ATS1 stops too) |
| utils/atexting/TEST/data.atxt | 1 | 0 | 0 | 1 (syntax error in both) |
| total | 415 | 369 | 22 | 24 |

The 22 that differ have only the lines that name the compiler different (`ATSHOMEQ/ATSCC/ATSOPT/GCFLAG/-IATS $(ATSHOMEQ)/*_sats.o` against `PATSCC/PATSCCFLAGS`...: diffed line by line). Besides the text:
the 19 `doc/BOOK/ATS2TUTORIAL/TEMP/*.dats` that the chapters write and the TRYIT files of the DOCUGEN documents are identical to the ATS1 ones; `main.db` through `Makefile_chap` equals the pipeline's text;
`make -C <DOCUGEN dir> HTML/gmp.html` (the generated Makefile) gives the same HTML; `make -f codegen/Makefile_atslib` regenerates the 106 generated prelude files and the 4 Makefiles: the tracked files are
unchanged except the `Time of generation` line (`git diff -I'Time of generation'` shows only the 4 Makefiles).

Regression: `make -C utils/atsdoc genall` (`TEST/genall.sh`, 30-45 s with 8 jobs, LC_ALL=C and the canonical PATSHOME pinned like the other suites; also from another directory and under `de_DE.UTF-8`) regenerates the text of the
391 templates and compares the md5 sums with `TEST/genall.md5` (made from the output that is identical to ATS1's, the 22 Makefile templates excepted); `make -C utils/atsdoc genprelude` (`genall.sh prelude`) regenerates
the four prelude CODEGEN directories in a scratch copy with `Makefile.gen` and `Makefile` and compares each of the 110 generated files with the tracked one (changing one character of `bool.atxt`
is detected by both). `genall.sh clean` removes the `*_atxt.*` programs that the runs leave (they are ignored by git, like the files that the documents write: TEMP, TRYIT, HTML).

Open problems (atsdoc corpus):
* the 24 templates above cannot be run by either toolchain; `tutorialatxt.dats` would have to be written (the DocBook functions `para/emph/code/title..` of the cairo tutorial; `ats2tutorial.dats` is the nearest).
* `sprintf` has string arguments only (the one `%i` was converted by hand); a template that needs another conversion calls `tostrptr_int` and the like.
* `mytexting.dats` (4 copies in doc/*/MYTEXT), `utils/ats2srcgen` and the `ats1-libatsopt` package are ATS1 programs for ATS1 libraries that are not part of the pipeline: not ported.
* the C names of the dynload functions embed the path of `libatsdoc/dynloadall.dats`: all the programs are compiled with the PATSHOME that libatsdoc.a was built with (`genall.sh` takes the one of its own location).

## Unrunnable templates: libcairo tutorial

The 6 chapters `npm-utils/contrib/atscntrb/atscntrb-hx-libcairo/TUTORIAL/ATEXT/chap_{hello,objtypes,funtypes,drawline,drawrectcirc,drawtext}.atxt` stopped at
`the file [utils/atsdoc/DOCUMENT/TUTORIALATS/tutorialatxt.dats] is not available for inclusion` (and, run from the `ATEXT` directory instead of `TUTORIAL`, at
`./ATEXT/ats2cairo.dats`: the Makefile of `TUTORIAL` runs them from there). `git log --all` (every path, deleted ones included) has no file of that name or under `TUTORIALATS/`:
it was in the ATS1 install only, which the repository never held. The chapters (and, before the move of `contrib/cairo` to `npm-utils`, `contrib/GTK/TUTORIAL`) only
`#include` it. What they use is a small DocBook vocabulary: `para` 63, `dyncode` 46, `atscode` 44, `comment` 31, `stacode` 20, `code` 12, `emph` 9, `title` 6, `timestamp` 6,
`command` 3, `filename` 2 (plus `ulink1`, `mydoclink`, `mycodelink`, `myimagelink`, `MYIMAGEROOTget` of `ATEXT/ats2cairo.dats`). All but `dyncode` and `stacode` are in `utils/atsdoc/HATS/docbookatxt.hats`
(with `xhtmlatxt.hats`: `comment` is `<!-- -->`, `timestamp`), and the two are `xmltagging ("code", ..)` in `doc/BOOK/ATS2TUTORIAL/MYTEXT/ats2tutorial.dats`.
`utils/atsdoc/DOCUMENT/TUTORIALATS/tutorialatxt.dats` is therefore rebuilt as `#include docbookatxt.hats` + those two macros (and `#define ATSDOC_NO_DYNLOAD`, the chapters
have their own `dynload`); the chapters are unchanged. This is a reconstruction, not the lost file: no generated version of the tutorial is tracked (the html is uploaded to the
web site by the Makefile), so the output could not be compared with a reference. The six `.db` texts are well-formed XML (`xmllint`), the placeholders are all replaced, the code
blocks are CDATA as in the other books. The six are in `utils/atsdoc/TEST/genall.md5` (397 entries); `genall.sh` runs them from `TUTORIAL`.

## Unrunnable templates: mylib, EFFECTIVATS, atexting test

Of the 24 templates that "cannot run" (table in "atsdoc corpus adaptation") 9 were examined again; none was an obsolete atsdoc template. Result: 5 are atsdoc templates that lacked three helper functions (now fixed), 4 are not atsdoc templates but inputs of the other preprocessor, atexting (`##name(..)`), and run with it. Only 15 of the 24 remain; the corpus of `genall.md5` has 396 entries.

* `doc/EXAMPLE/EFFECTIVATS/{prop-logic,PwTP-bool-vs-prop,Readers-and-Writers,sorting-linear-lists,stack-array}/main.atxt` (atsdoc, single `#`): they use `#stacode(..)`, `#dyncode(..)` and (stack-array) `#keycode(..)`, which no helper ever defined (`git log -S`: not in `ATEXT/atextfun.hats`, `MYTEXT/mytextfun.hats`, `xhtmlatxt.hats`; the books define them as `<code>` in their own MYTEXT, the markup of EFFECTIVATS is different). The tracked `main.html` of four of them (the fifth never had one) shows the markup that was used: `<span style="color: #0000F0;">` (stacode), `<span style="color: #F00000;">` (dyncode), `<span style="color:#000000;font-weight:bold;">` (keycode); the same colours are in `MYTEXT/mytexting.dats` (the atexting driver). `MYTEXT/mytextfun.hats` now defines the three functions with that markup. The text that atsdoc/patscc/libatsdoc generate is byte-identical to the four tracked `main.html` (md5 equal, time stamps do not occur); PwTP-bool-vs-prop has no tracked output, its text has no `#name(` left. The five are in `genall.md5` (kind plain).
* `doc/EXAMPLE/EFFECTIVATS/linear-streams/main.atxt` is an atexting document (74 `##name(..)`; its Makefile runs `MYTEXT/bin/mytexting`, not atsdoc). The ATS2 adaptation had turned its two `\%{^`/`\%}` into `\\\%{^`/`\\\%}` (the rule for atsdoc arguments); atexting takes `\%` as an escape, so the snippet went to pats2xhtml with the three backslashes and failed to parse. Restored to the original; `mytexting` (built from `MYTEXT/mytexting.dats`) then generates a `main.html` identical to the tracked one. Not in `genall.md5` (that file knows atsdoc kinds only).
* `doc/BOOK/ATS2FUNCRASH/LECTURE/MYLIB/DOCUGEN/{mylib_dats,mylib_html}.atxt` are atexting inputs too (`##interface("int_foreach")`, `##implement(..)`, `##dyncode(..)`; `mylib_atexting.dats` is their driver, already ported; the Makefile of the directory builds and runs it). atsdoc reads `##implement(` as `#` followed by a call and writes a program with a syntax error: that was the reported error, not a defect of the files. With atexting both run (`make copy build` in the directory, in a scratch copy): `mylib_atxt.html` equals the tracked `doc/BOOK/ATS2FUNCRASH/HTML/mylib_atxt.html` except the three `<script src=..>` lines (the template is newer than the tracked page). The generated `mylib_atxt.dats` includes `share/atspre_staload_libats_ML.hats` and uses `list0`: libats/ML is gone, so it cannot be compiled by the no-GC library (the content of the book page, nothing to fix in the template).
* `utils/atexting/TEST/data.atxt` is the input of `mytexting` in that directory (`##ctime()`, `##litdouble(..)`): not an atsdoc template. `make -C utils/atexting/TEST regress` works once the Makefile names the new libraries (`-latsynmark -latsopt -latslib -lgmp`, `-I$(PATSHOME)/src`; it still had the ATS1 `-lats` and `ats_prelude.c`); same change in `doc/EXAMPLE/EFFECTIVATS/MYTEXT/Makefile`. The other `MYTEXT/Makefile` of the books (3) have the same ATS1 library line and were not touched.
* The `.atxt` files of atexting do not belong to the atsdoc corpus; `make -C doc -f Makefile_test` does not run them.

## Unrunnable templates: prelude/contrib DOCUGEN

Eight DOCUGEN documents cannot be generated: `prelude/SATS/DOCUGEN/{arrayref,fcontainer,giterator,list,matrixref,option,stream}.atxt` and
`contrib/atscntrb/atscntrb-hx-libhiredis/SATS/DOCUGEN/hiredis_ML.atxt`. The pipeline fails at the same place for all eight (atsdoc and patscc succeed;
the program of `htmlgendecl.atxt` stops): `fopen: No such file or directory` / `exit(ATS): [fopen("../X.sats", "r")] failed`. `srcfilename_get` of each template names a `.sats` that is gone:
* `list`, `option`, `stream`, `arrayref`, `matrixref` `.sats`: deleted by 841056b28 (Remove GC support; the nonlinear containers). The documents describe the nonlinear API (`list0`-free `list`, `arrayref_*`, `matrixref_*`, ...);
  the linear replacements (`list_vt`, `option_vt`, `stream_vt`, `arrayptr`, `matrixptr`) have their own documents already (`list_vt.atxt`, ...), so retargeting would only duplicate them with names that do not match.
* `fcontainer`, `giterator`: moved out of prelude to `libats/ATS2` upstream by 1394a2555 (Dec 2017, the ATS1/ATS2-era templates were stale already then), and `libats/ATS2` was deleted by 043308092.
* `hiredis_ML.sats`: deleted by 63c3db311 ("remove the ML-style layers hiredis_ML and pcre_ML", nonlinear heap).
Verdict: none can be fixed; PROPOSE REMOVAL (nothing was deleted). Removal would take: the 8 `.atxt`; the `#make_entry("list"|"option"|"arrayref"|"matrixref"|"stream"|"giterator"|"fcontainer")` lines (130, 133, 139, 143, 145, 150, 152)
of `prelude/SATS/DOCUGEN/Makefile.atxt` and `Makefile_html.atxt` (the generated `Makefile` is not tracked: regenerate with `make -f Makefile.gen`); the lines `all_html:: HTML/{arrayref,list,option}.html` of the tracked
`prelude/SATS/DOCUGEN/DBOOK/Makefile`. No generated HTML/TRYIT of them is tracked, nothing else refers to them (the tests `utils/atsdoc/TEST/cases/*fcontainer*` and `*hiredis_ML*` only
check the atsdoc translation, which works, and can stay). None has a line in `genall.md5`.


**Update:** the eight templates (prelude/SATS/DOCUGEN/{list,option,stream,arrayref,matrixref,fcontainer,giterator}.atxt and contrib/atscntrb/atscntrb-hx-libhiredis/SATS/DOCUGEN/hiredis_ML.atxt) were removed, together with their `#make_entry(...)` lines in prelude/SATS/DOCUGEN/Makefile.atxt and Makefile_html.atxt, the three `all_html::` lines in DBOOK/Makefile and the stale `hiredis_ML` lines of the hiredis TEST/README. The `.sats` files they described no longer exist; the linear replacements (list_vt, option_vt, stream_vt, arrayptr, matrixptr) have their own documents. The translation fixtures under utils/atsdoc/TEST/cases stay.
