(* SPDX-FileCopyrightText: 2026 Mikhail Sorochan *)
(* SPDX-License-Identifier: MIT *)
(* ****** ****** *)
//
// HX-2026-10: the surface printer of the static terms ("sprint")
//
// The error messages print the static terms (types, props, sorts) in the
// syntax of the source language: [list_vt(int, 3)], [n - 1 >= 0], [t@ype],
// instead of the constructor syntax of [fprint_s2exp] (pats_staexp2_print)
// and [fpprint_s2exp] (pats_staexp2_pprint); the output of these two is not
// changed (the md5 suites of src/test hash it).
//
// The names: an s2cst that is the head of a registered alias ([stadef],
// [typedef], [viewtypedef], [tkindef]) is printed as the alias
// ([g0int_t0ype(atstype_int)] is printed as [int]); two variables of the
// same name in one message are told apart by [#2], [#3]... (the state is
// per message: [sprint_reset ()] starts a message).
//
(* ****** ****** *)

staload "libats/SATS/arena.sats"
staload "./pats_staexp2.sats"

(* ****** ****** *)
//
// HX: the per-message state: the names given to the variables
//
fun sprint_reset (): void
//
(* ****** ****** *)
//
fun fsprint_s2rt (out: FILEref, s2t: s2rt): void
fun fsprint_s2exp (out: FILEref, s2e: s2exp): void
fun fsprint_s2explst (out: FILEref, s2es: s2explst): void
fun fsprint_s2var (out: FILEref, s2v: s2var): void
fun fsprint_s2cst (out: FILEref, s2c: s2cst): void
//
fun print_s2rt_s (s2t: s2rt): void
fun prerr_s2rt_s (s2t: s2rt): void
fun print_s2exp_s (s2e: s2exp): void
fun prerr_s2exp_s (s2e: s2exp): void
fun print_s2explst_s (s2es: s2explst): void
fun prerr_s2explst_s (s2es: s2explst): void
fun print_s2var_s (s2v: s2var): void
fun prerr_s2var_s (s2v: s2var): void
fun print_s2cst_s (s2c: s2cst): void
fun prerr_s2cst_s (s2c: s2cst): void
//
(* ****** ****** *)
//
// HX: the name of a variable of kind [knd] (0: static, 1: dynamic)
// whose identity is [id] (the address of its cell): the symbol [sym]
// without the suffix [$n] of the copies, and [#k] when it is the k-th
// variable (k >= 2) of that name in the current message.
// [fsprint_d2var] (pats_dynexp2.sats) is implemented with it.
//
fun fsprint_varname
  (out: FILEref, knd: int, sym: symbol, id: ptr): void
//
// HX: the static variables printed since [sprint_reset], in the order
// of their first occurrence
//
fun sprint_s2vars_seen (): List0_vt (s2var)
//
(* ****** ****** *)
//
// HX: [ctx] is the precedence of the context (0: none; 31: an operand of [==])
//
fun fsprint_s2exp_ctx (out: FILEref, s2e: s2exp, ctx: int): void
//
fun fsprint_s2eff (out: FILEref, s2fe: s2eff): void
//
// HX: the static variables that occur in [s2e] (not bound in it; the
// links of the existential variables are followed, nothing is changed)
// are added to [acc] (the newest first, no duplicate)
//
fun s2exp_sprint_svars (s2e: s2exp, acc: glist(s2var)): glist(s2var)
//
// HX: the number of the leading arguments of [s2c(s2es)] that its
// printed alias hides ([int(3)] is [g1int_int_t0ype(int_kind, 3)]: 1)
//
fun s2exp_sprint_nlead (s2c: s2cst, s2es: s2explst): int
//
// HX: the head constant of a static application (the links of the
// existential variables followed), or false
//
fun s2exp_sprint_head
  (s2e: s2exp, s2c: &s2cst? >> s2cst, s2es: &s2explst? >> s2explst): bool
//
(* ****** ****** *)
//
// HX: the registration of the aliases (by trans2): [s2c] is made by a
// [stadef]/[typedef] (its definition is that of the alias), or by a [tkindef]
//
fun sprint_alias_add_s2cst (s2c: s2cst): void
fun sprint_alias_add_tkind (s2c: s2cst): void
//
(* ****** ****** *)

(* end of [pats_staexp2_sprint.sats] *)
