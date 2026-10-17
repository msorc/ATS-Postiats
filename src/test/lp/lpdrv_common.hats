(*
** The driver of the linear constraint solver, in the common subset of ATS1 and
** ATS2 (it is #include-d by lpdrv1.dats and lpdrv2.dats after the definitions
** of [knd], [i2g1] and [i2sz1], the C declarations (lpdrv_decls.hats), the
** modules, and pats_lintprgm_solve.dats whose internal functions it tests).
** It reads problems and prints what the functions of the sats compute, the
** internal functions of pats_lintprgm_solve.dats and the integer operations.
*)

macdef out = stdout_ref
macdef prs (s) = fprint_string (out, ,(s))
macdef prn () = fprint_newline (out)
macdef pri (i) = fprint_int (out, ,(i))

extern castfn drv_loc (x: ptr): $LOC.location
extern castfn drv_s3e (x: ptr): s3exp
extern castfn drv_ptr0 (x: int): ptr

(* ****** ****** *)

fun mkint (s: string): myint(knd) = let
  val x = myint_make_intinf<knd> (intinf_make_string (lpdrv_abs (s)))
in
  if lpdrv_isneg (s) > 0 then neg_myint<knd> (x) else x
end // end of [mkint]

fun mknat2 (k: int): nat2 = let
  val [k:int] k = i2g1 (k) in if k = 0 then 0 else 1
end // end of [mknat2]

fun mkint2 (k: int): int2 = let
  val [k:int] k = i2g1 (k) in
  if k <= ~2 then ~2 else (if k >= 2 then 2 else k)
end // end of [mkint2]

(* ****** ****** *)

fun drv_set_at {n:int}
  (iv: !myintvec(knd, n), i: natLt n, x: myint(knd)): void = let
  val (pf | p) = myintvec_takeout {knd} (iv)
  val (pfat, fpf | pi) = array_ptr_takeout<myint(knd)> (pf | p, i2sz1 (i))
  val () = myint_free<knd> (!pi)
  val () = !pi := x
  prval () = pf := fpf (pfat)
  prval () = myintvecout_addback (pf | iv)
in
  // nothing
end // end of [drv_set_at]

fun mkvec_loop {n:pos}{i:nat | i <= n}
  (iv: !myintvec(knd, n), k: int, N: int n, i: int i): void =
  if i < N then let
    val () = drv_set_at (iv, i, mkint (lpdrv_coef (k, i)))
  in
    mkvec_loop (iv, k, N, i+1)
  end else ()

fun mkvec {n:pos} (k: int, N: int n): myintvec(knd, n) = let
  val iv = myintvec_make<knd> (N)
  val () = mkvec_loop (iv, k, N, 0)
in
  iv
end // end of [mkvec]

// the vector j of the problem
fun mkvecj {n:pos} (j: int, N: int n): myintvec(knd, n) = mkvec (lpdrv_vec (j), N)

fun mkvlist {n:pos} (j: int, m: int, N: int n): myintveclst(knd, n) =
  if j < m then list_vt_cons (mkvecj (j, N), mkvlist (j+1, m, N)) else list_vt_nil ()

fun mkic {n:pos} (k: int, N: int n): icnstr(knd, n) = let
  val t = lpdrv_ntype (k)
in
  if t = 0 then ICvec (mkint2 (lpdrv_nknd (k)), mkvec (k, N))
  else if t = 1 then ICveclst (mknat2 (lpdrv_nknd (k)), mkiclst (k, 0, lpdrv_nch (k), N))
  else ICerr (drv_loc (drv_ptr0 (0)), drv_s3e (drv_ptr0 (0)))
end // end of [mkic]

and mkiclst {n:pos} (k: int, j: int, m: int, N: int n): icnstrlst(knd, n) =
  if j < m then list_vt_cons (mkic (lpdrv_ch (k, j), N), mkiclst (k, j+1, m, N))
  else list_vt_nil ()

fun mktops {n:pos} (j: int, m: int, N: int n): icnstrlst(knd, n) =
  if j < m then list_vt_cons (mkic (lpdrv_top (j), N), mktops (j+1, m, N)) else list_vt_nil ()

// the hint set of the problem, [N] bounds the indices
fun mkiset {n:pos} (j: int, m: int, N: int n, xs: indexset(n)): indexset(n) =
  if j < m then let
    val [i:int] i = i2g1 (lpdrv_hint (j))
  in
    if i >= 1 then (if i < N then mkiset (j+1, m, N, indexset_add {n} (xs, i)) else mkiset (j+1, m, N, xs))
    else mkiset (j+1, m, N, xs)
  end else xs

(* ****** ****** *)

fun pvec {n:pos} (iv: !myintvec(knd, n), N: int n): void = let
  val () = prs "["
  val () = fprint_myintvec<knd> (out, iv, N)
  val () = prs "]"
in
  // nothing
end

fun pvecln {n:pos} (tag: string, iv: !myintvec(knd, n), N: int n): void = let
  val () = prs tag
  val () = pvec (iv, N)
  val () = prn ()
in
  // nothing
end

fun pint1 (tag: string, i: int): void = (prs tag; pri i; prn ())

fun pmi (tag: string, x: !myint(knd)): void = let
  val () = prs tag
  val () = fprint_myint<knd> (out, x)
  val () = prn ()
in
  // nothing
end

fun sgn1 (i: int): int = if i < 0 then ~1 else (if i > 0 then 1 else 0)

(* ****** ****** *)

fun at_loop {n:pos}{i:nat | i <= n}
  (tag: string, iv: !myintvec(knd, n), N: int n, i: int i): void =
  if i < N then let
    val x = myintvec_get_at<knd> (iv, i)
    val () = prs tag
    val () = pri i
    val () = prs ": "
    val () = fprint_myint<knd> (out, x)
    val () = prs " "
    val () = pri (sgn1 (myintvec_compare_at<knd> (iv, i, 0)))
    val () = prs " "
    val () = pri (sgn1 (myintvec_compare_at<knd> (iv, i, 3)))
    val () = prs " "
    val () = pri (sgn1 (myintvec_compare_at<knd> (iv, i, ~7)))
    val () = prn ()
    val () = myint_free<knd> (x)
  in
    at_loop (tag, iv, N, i+1)
  end else ()

fun comb_loop {n:pos}{i:nat | i <= n}
  (iv1: !myintvec(knd, n), iv2: !myintvec(knd, n), N: int n, i: int i): void =
  if i < N then let
    val () = (
      if i >= 1 then let
        val r = myintvec_combine_at<knd> (iv1, iv2, N, i)
        val () = (prs "  combine_at "; pri i; prs ": ")
        val () = pvecln ("", r, N)
      in
        myintvec_free<knd> (r, N)
      end else ()
    ) : void
  in
    comb_loop (iv1, iv2, N, i+1)
  end else ()


(* ****** ****** *)
//
// the operations on the vectors j and j+1 (cyclically) of the problem
//
fun inspect4 {n:pos} (j: int, N: int n): void = let
  val iv = mkvecj (j, N)
  val () = pint1 ("  inspect(2): ", myintvec_inspect<knd> (2, iv, N))
  val () = pint1 ("  inspect(~2): ", myintvec_inspect<knd> (~2, iv, N))
  val () = pint1 ("  inspect(1): ", myintvec_inspect<knd> (1, iv, N))
  val () = pint1 ("  inspect(~1): ", myintvec_inspect<knd> (~1, iv, N))
  val () = pint1 ("  inspect(5): ", myintvec_inspect<knd> (5, iv, N))
  val () = pint1 ("  inspect_gte: ", myintvec_inspect_gte<knd> (iv, N))
  val () = pint1 ("  inspect_lt: ", myintvec_inspect_lt<knd> (iv, N))
  val () = pint1 ("  inspect_neq: ", myintvec_inspect_neq<knd> (iv, N))
  val () = myintvec_free<knd> (iv, N)
  // [inspect_eq] normalizes the vector
  val iv = mkvecj (j, N)
  val ans = myintvec_inspect_eq<knd> (iv, N)
  val () = pint1 ("  inspect_eq: ", ans)
  val () = pvecln ("  after inspect_eq: ", iv, N)
  val () = myintvec_free<knd> (iv, N)
in
end // end of [inspect4]

fun gcdnorm {n:pos} (j: int, N: int n): void = let
  val iv = mkvecj (j, N)
  val g = myintvec_cffgcd<knd> (iv, N)
  val () = pmi ("  cffgcd: ", g)
  val () = myint_free<knd> (g)
  val () = myintvec_free<knd> (iv, N)
  val iv = mkvecj (j, N)
  val () = myintvec_normalize_gte<knd> (iv, N)
  val () = pvecln ("  normalize_gte: ", iv, N)
  val () = myintvec_free<knd> (iv, N)
in
end // end of [gcdnorm]

fun unary {n:pos} (j: int, N: int n): void = let
  val iv = mkvecj (j, N)
  val () = pvecln ("  vec: ", iv, N)
  val c = myintvec_get_at<knd> (iv, N-1)
  val iv2 = myintvec_copy<knd> (iv, N)
  val () = pvecln ("  copy: ", iv2, N)
  val () = myintvec_free<knd> (iv2, N)
  val iv2 = myintvec_copy_cff<knd> (c, iv, N)
  val () = pvecln ("  copy_cff(last): ", iv2, N)
  val () = myintvec_free<knd> (iv2, N)
  val cm = myint_make_int<knd> (~3)
  val iv2 = myintvec_copy_cff<knd> (cm, iv, N)
  val () = pvecln ("  copy_cff(~3): ", iv2, N)
  val () = myintvec_free<knd> (iv2, N)
  val () = myintvec_scale<knd> (c, iv, N)
  val () = pvecln ("  scale(last): ", iv, N)
  val () = myintvec_negate<knd> (iv, N)
  val () = pvecln ("  negate: ", iv, N)
  val () = myintvec_scale<knd> (cm, iv, N)
  val () = pvecln ("  scale(~3): ", iv, N)
  val () = myintvec_add_int<knd> (iv, 7)
  val () = myintvec_add_int<knd> (iv, ~12)
  val () = pvecln ("  add_int(7, ~12): ", iv, N)
  val () = myint_free<knd> (c)
  val () = myint_free<knd> (cm)
  val () = myintvec_free<knd> (iv, N)
  val iv = mkvecj (j, N)
  val () = at_loop ("  at ", iv, N, 0)
  val () = myintvec_free<knd> (iv, N)
in
end // end of [unary]

fun binary {n:pos} (j: int, j2: int, N: int n): void = let
  val iv1 = mkvecj (j, N)
  val iv2 = mkvecj (j2, N)
  val () = myintvec_addby<knd> (iv1, iv2, N)
  val () = pvecln ("  addby: ", iv1, N)
  val () = myintvec_subby<knd> (iv1, iv2, N)
  val () = myintvec_subby<knd> (iv1, iv2, N)
  val () = pvecln ("  subby*2: ", iv1, N)
  val c = myintvec_get_at<knd> (iv2, N-1)
  val () = myintvec_addby_cff<knd> (iv1, c, iv2, N)
  val () = pvecln ("  addby_cff(last): ", iv1, N)
  val () = myint_free<knd> (c)
  val () = myintvec_free<knd> (iv1, N)
  val iv3 = mkvecj (j2, N)
  val () = comb_loop (iv2, iv3, N, 0)
  val () = myintvec_free<knd> (iv3, N)
  val iv1 = mkvecj (j, N)
  val () = comb_loop (iv1, iv2, N, 0)
  val () = myintvec_free<knd> (iv1, N)
  val () = myintvec_free<knd> (iv2, N)
in
end // end of [binary]

// the index of the least coefficient and the elimination of an equality
fun elim_loop {n:pos}{i:nat | i <= n}
  (iv: !myintvec(knd, n), iveq: !myintvec(knd, n), j: int, j2: int, N: int n, i: int i): void =
  if i < N then let
    val () = (
      if i >= 1 then let
        val iv1 = mkvecj (j, N)
        val () = myintvec_elimeq_at<knd> (iv1, iveq, N, i)
        val () = (prs "  elimeq_at "; pri i; prs ": ")
        val () = pvecln ("", iv1, N)
        val () = myintvec_free<knd> (iv1, N)
      in
      end else ()
    ) : void
  in
    elim_loop (iv, iveq, j, j2, N, i+1)
  end else ()

fun absmin {n:pos} (j: int, j2: int, N: int n): void = let
  val iv = mkvecj (j, N)
  val g = myintvec_cffgcd<knd> (iv, N)
  val nzflag = (compare_myint_int<knd> (g, 0) != 0) // false when the coefficients are 0
  val () = myint_free<knd> (g)
  val () = (
    if nzflag then pint1 ("  absmincff: ", myintvec_get_index_of_absmincff<knd> (iv, N))
    else prs "  absmincff: none\n"
  ) : void
  val iveq = mkvecj (j2, N)
  val () = elim_loop (iv, iveq, j, j2, N, 0)
  val () = myintvec_free<knd> (iv, N)
  val () = myintvec_free<knd> (iveq, N)
in
end // end of [absmin]

fun vecs_loop {n:pos} (j: int, m: int, N: int n): void =
  if j < m then let
    val j2 = (if j+1 < m then j+1 else 0): int
    val () = (prs "VEC "; pri j; prn ())
    val () = unary (j, N)
    val () = inspect4 (j, N)
    val () = gcdnorm (j, N)
    val () = binary (j, j2, N)
    val () = absmin (j, j2, N)
  in
    vecs_loop (j+1, m, N)
  end else ()

(* ****** ****** *)
//
// the lists of vectors
//
fun split_loop {n:pos}{i:nat | i <= n} (m: int, N: int n, i: int i): void =
  if i < N then let
    val () = (
      if i >= 1 then let
        var ivs = mkvlist (0, m, N)
        val ans = myintveclst_split_at<knd> (ivs, N, i)
        val () = (prs "  split_at "; pri i; prs " -> "; pri ans; prn ())
        val () = print_myintveclst<knd> (ivs, N)
        val () = myintveclst_free<knd> (ivs, N)
      in
      end else ()
    ) : void
  in
    split_loop (m, N, i+1)
  end else ()

fun elimlst_loop {n:pos}{i:nat | i <= n} (m: int, N: int n, j2: int, i: int i): void =
  if i < N then let
    val () = (
      if i >= 1 then let
        val ivs = mkvlist (0, m, N)
        val iveq = mkvecj (j2, N)
        val () = myintveclst_elimeq_at<knd> (ivs, iveq, N, i)
        val () = (prs "  elimeq_at(list) "; pri i; prn ())
        val () = print_myintveclst<knd> (ivs, N)
        val () = myintveclst_free<knd> (ivs, N)
        val () = myintvec_free<knd> (iveq, N)
      in
      end else ()
    ) : void
  in
    elimlst_loop (m, N, j2, i+1)
  end else ()

fun lists {n:pos} (m: int, iset: indexset(n), N: int n): void = let
  var ivs = mkvlist (0, m, N)
  val () = prs "lists:\n"
  val () = print_myintveclst<knd> (ivs, N)
  val ans = myintveclst_inspect_gte<knd> (ivs, N)
  val () = (prs " inspect_gte -> "; pri ans; prn ())
  val () = print_myintveclst<knd> (ivs, N)
  val () = myintveclst_free<knd> (ivs, N)
  var ivs = mkvlist (0, m, N)
  val () = myintveclst_normalize_gte<knd> (ivs, N)
  val () = prs " normalize_gte:\n"
  val () = print_myintveclst<knd> (ivs, N)
  val () = myintveclst_free<knd> (ivs, N)
  val () = split_loop (m, N, 1)
  val () = elimlst_loop (m, N, (if m > 1 then 1 else 0), 1)
  val ivs = mkvlist (0, m, N)
  val ans = myintveclst_solve<knd> (iset, ivs, N)
  val () = (prs " myintveclst_solve -> "; pri ans; prn ())
in
end // end of [lists]

(* ****** ****** *)
//
// the stacks of equalities and the lists of inequalities with marks
//
fun eqstack {n:pos} (j: int, m: int, N: int n, i1veqs: &myiveqlst(knd, n) >> myiveqlst(knd, n)): void =
  if j < m then let
    val iv = mkvecj (j, N)
    val g = myintvec_cffgcd<knd> (iv, N)
    val nzflag = (compare_myint_int<knd> (g, 0) != 0)
    val () = myint_free<knd> (g)
    val () = (
      if nzflag then let
        val i = myintvec_get_index_of_absmincff<knd> (iv, N)
      in
        i1veqs := myiveqlst_cons<knd> (j, i, iv, i1veqs)
      end else myintvec_free<knd> (iv, N)
    ) : void
    val () = (if j mod 3 = 1 then i1veqs := myiveqlst_mark<knd> (i1veqs))
  in
    eqstack (j+1, m, N, i1veqs)
  end else ()

fun elimstack_loop {n:pos} (j: int, m: int, N: int n, i1veqs: !myiveqlst(knd, n)): void =
  if j < m then let
    val iv = mkvecj (j, N)
    val () = myintvec_elimeqlst<knd> (0, iv, i1veqs, N)
    val () = pvecln ("  elimeqlst(0): ", iv, N)
    val () = myintvec_free<knd> (iv, N)
    val iv = mkvecj (j, N)
    val () = myintvec_elimeqlst<knd> (2, iv, i1veqs, N)
    val () = pvecln ("  elimeqlst(2): ", iv, N)
    val () = myintvec_free<knd> (iv, N)
  in
    elimstack_loop (j+1, m, N, i1veqs)
  end else ()

fun ivstack {n:pos} (j: int, m: int, N: int n, i1vs: &myivlst(knd, n) >> myivlst(knd, n)): void =
  if j < m then let
    val iv = mkvecj (j, N)
    val () = i1vs := MYIVLSTcons (j, iv, i1vs)
    val () = (if j mod 2 = 0 then i1vs := myivlst_mark<knd> (i1vs))
  in
    ivstack (j+1, m, N, i1vs)
  end else ()

fun stacks {n:pos} (m: int, N: int n): void = let
  var i1veqs: myiveqlst(knd, n) = MYIVEQLSTnil ()
  val () = eqstack (0, m, N, i1veqs)
  val () = prs "stack of equalities:\n"
  val () = elimstack_loop (0, m, N, i1veqs)
  var i1vs: myivlst(knd, n) = MYIVLSTnil ()
  val () = ivstack (0, m, N, i1vs)
  val res = myivlst_elimeqlst<knd> (i1vs, i1veqs, N)
  val () = prs " myivlst_elimeqlst:\n"
  val () = print_myintveclst<knd> (res, N)
  val () = myintveclst_free<knd> (res, N)
  // one more equality then unmark
  val () = i1veqs := myiveqlst_unmark<knd> (i1veqs, N)
  val () = i1vs := myivlst_unmark<knd> (i1vs, N)
  // HX: the [prev] of the head is stale after [unmark] until the next [mark] or [cons]
  val () = i1veqs := myiveqlst_mark<knd> (i1veqs)
  val () = prs " after unmark:\n"
  val () = elimstack_loop (0, m, N, i1veqs)
  val res = myivlst_elimeqlst<knd> (i1vs, i1veqs, N)
  val () = print_myintveclst<knd> (res, N)
  val () = myintveclst_free<knd> (res, N)
  val () = i1veqs := myiveqlst_unmark<knd> (i1veqs, N)
  val () = myivlst_free<knd> (i1vs, N)
  val () = myiveqlst_free<knd> (i1veqs, N)
in
end // end of [stacks]

(* ****** ****** *)
//
// the constraints (as a whole) and the solver
//
fun solves {n:pos} (iset: indexset(n), N: int n): void = let
  val () = prs "constraints:\n"
  val ntop = lpdrv_ntop ()
  var ics = mktops (0, ntop, N)
  val () = print_icnstrlst<knd> (ics, N)
  val ics2 = icnstrlst_copy<knd> (ics, N)
  val () = prs "copy:\n"
  val () = print_icnstrlst<knd> (ics2, N)
  val ics2 = icnstrlst_negate<knd> (ics2)
  val () = prs "negate:\n"
  val () = print_icnstrlst<knd> (ics2, N)
  val () = icnstrlst_free<knd> (ics2, N)
  val ic = mkic (lpdrv_top (0), N)
  val ic2 = icnstr_copy<knd> (ic, N)
  val () = print_icnstr<knd> (ic2, N)
  val () = prn ()
  val ic2 = icnstr_negate<knd> (ic2)
  val () = print_icnstr<knd> (ic2, N)
  val () = prn ()
  val () = icnstr_free<knd> (ic2, N)
  val () = icnstr_free<knd> (ic, N)
  val ans = icnstrlst_solve<knd> (iset, ics, N)
  val () = (prs "solve: "; pri ans; prn ())
  val () = prs "after solve:\n"
  val () = print_icnstrlst<knd> (ics, N)
  val () = icnstrlst_free<knd> (ics, N)
  // without hint
  var ics = mktops (0, ntop, N)
  val ans = icnstrlst_solve<knd> (indexset_nil {n} (), ics, N)
  val () = (prs "solve (no hint): "; pri ans; prn ())
  val () = icnstrlst_free<knd> (ics, N)
  // the negation of the constraints
  var ics = icnstrlst_negate<knd> (mktops (0, ntop, N))
  val ans = icnstrlst_solve<knd> (iset, ics, N)
  val () = (prs "solve (negated): "; pri ans; prn ())
  val () = icnstrlst_free<knd> (ics, N)
in
end // end of [solves]

(* ****** ****** *)

// the hint set: the membership of every index and the order of the indices of the solver
fun iset_loop {n:pos}{i:nat | i <= n} (iset: indexset(n), N: int n, i: int i): void =
  if i < N then let
    val () = (if i >= 1 then pri (if indexset_is_member {n} (iset, i) then 1 else 0))
  in
    iset_loop (iset, N, i+1)
  end else ()

fun ilst_loop {n:pos} (xs: &indexlst(n) >> indexlst(n), N: int n): void = let
  val i = indexlst_choose {n} (xs)
in
  if i > 0 then (pri i; prs " "; ilst_loop (xs, N)) else ()
end // end of [ilst_loop]

fun show_iset {n:pos} (iset: indexset(n), N: int n): void = let
  val () = prs "iset: "
  val () = iset_loop (iset, N, 0)
  val () = prn ()
  var xs = indexlst_make {n} (iset, N)
  val () = prs "ilst: "
  val () = ilst_loop (xs, N)
  val () = prn ()
  val () = indexlst_free {n} (xs)
in
end // end of [show_iset]

fun run_problem (): void = let
  val Nraw = lpdrv_N ()
  val [n:int] N = i2g1 (Nraw)
  val () = assertloc (N >= 1)
  val () = (prs "P "; prs (lpdrv_id ()); prs " "; prs (lpdrv_label ()); prs " N="; pri N; prn ())
  val iset = mkiset {n} (0, lpdrv_nhint (), N, indexset_nil {n} ())
  val () = show_iset {n} (iset, N)
  val m = lpdrv_nvec ()
  // HX: the number of vectors of the operations is limited: the solver is exponential
  val m4 = (if m < 4 then m else 4): int
  val m5 = (if m < 5 then m else 5): int
  val () = vecs_loop (0, m4, N)
  val () = lists (m5, iset, N)
  val () = stacks (m5, N)
  val () = solves (iset, N)
in
end // end of [run_problem]

(* ****** ****** *)
//
// the operations on integers
//
fun run_arith (): void = let
  val sa = lpdrv_arg (0) and sb = lpdrv_arg (1)
  val () = (prs "I "; prs sa; prs " "; prs sb; prn ())
  val a = mkint (sa) and b = mkint (sb)
  val () = pmi ("  a: ", a)
  val () = pmi ("  b: ", b)
  val x = neg1_myint<knd> (a)
  val () = pmi ("  neg1(a): ", x)
  val () = myint_free<knd> (x)
  val x = neg_myint<knd> (myint_copy<knd> (a))
  val () = pmi ("  neg(a): ", x)
  val () = myint_free<knd> (x)
  val x = add_myint_int<knd> (myint_copy<knd> (a), 5)
  val () = pmi ("  a+5: ", x)
  val () = myint_free<knd> (x)
  val x = add_myint_int<knd> (myint_copy<knd> (a), ~5)
  val () = pmi ("  a+(~5): ", x)
  val () = myint_free<knd> (x)
  val x = add01_myint_myint<knd> (myint_copy<knd> (a), b)
  val () = pmi ("  add01: ", x)
  val () = myint_free<knd> (x)
  val x = sub01_myint_myint<knd> (myint_copy<knd> (a), b)
  val () = pmi ("  sub01: ", x)
  val () = myint_free<knd> (x)
  val x = mul01_myint_myint<knd> (myint_copy<knd> (a), b)
  val () = pmi ("  mul01: ", x)
  val () = myint_free<knd> (x)
  val x = mul10_myint_myint<knd> (a, myint_copy<knd> (b))
  val () = pmi ("  mul10: ", x)
  val () = myint_free<knd> (x)
  val x = mul11_myint_myint<knd> (a, b)
  val () = pmi ("  mul11: ", x)
  val () = myint_free<knd> (x)
  val x = gcd01_myint_myint<knd> (myint_copy<knd> (a), b)
  val () = pmi ("  gcd01: ", x)
  val () = myint_free<knd> (x)
  val () = (prs "  cmp(a,b): "; pri (if lt_myint_myint<knd> (a, b) then ~1 else (if gt_myint_myint<knd> (a, b) then 1 else 0)); prn ())
  val () = (prs "  lt/lte/gt/gte: "; pri (if lt_myint_myint<knd> (a, b) then 1 else 0);
    pri (if lte_myint_myint<knd> (a, b) then 1 else 0);
    pri (if gt_myint_myint<knd> (a, b) then 1 else 0);
    pri (if gte_myint_myint<knd> (a, b) then 1 else 0); prn ())
  val () = (prs "  a vs ints: "; pri (sgn1 (compare_myint_int<knd> (a, 0)));
    pri (sgn1 (compare_myint_int<knd> (a, 100)));
    pri (sgn1 (compare_myint_int<knd> (a, ~100)));
    pri (if lt_myint_int<knd> (a, 3) then 1 else 0);
    pri (if lte_myint_int<knd> (a, 3) then 1 else 0);
    pri (if gt_myint_int<knd> (a, 3) then 1 else 0);
    pri (if gte_myint_int<knd> (a, 3) then 1 else 0);
    pri (if eq_myint_int<knd> (a, 3) then 1 else 0);
    pri (if neq_myint_int<knd> (a, 3) then 1 else 0); prn ())
  val bz = (compare_myint_int<knd> (b, 0) = 0)
  val () = (
    if bz then () else let
      val x = div01_myint_myint<knd> (myint_copy<knd> (a), b)
      val () = pmi ("  div01: ", x)
      val () = myint_free<knd> (x)
      val x = mod01_myint_myint<knd> (myint_copy<knd> (a), b)
      val () = pmi ("  mod01: ", x)
      val () = myint_free<knd> (x)
      val x = mod11_myint_myint<knd> (a, b)
      val () = pmi ("  mod11: ", x)
      val () = myint_free<knd> (x)
      // a*b is divided by b exactly
      val ab = mul11_myint_myint<knd> (a, b)
      val x = ediv01_myint_myint<knd> (ab, b)
      val () = pmi ("  ediv01(a*b,b): ", x)
      val () = myint_free<knd> (x)
    in
    end
  ) : void
  val () = myint_free<knd> (a)
  val () = myint_free<knd> (b)
in
end // end of [run_arith]

(* ****** ****** *)

// the solver only: the answer
fun run_bench (): void = let
  val Nraw = lpdrv_N ()
  val [n:int] N = i2g1 (Nraw)
  val () = assertloc (N >= 1)
  val iset = mkiset {n} (0, lpdrv_nhint (), N, indexset_nil {n} ())
  var ics = mktops (0, lpdrv_ntop (), N)
  val ans = icnstrlst_solve<knd> (iset, ics, N)
  val () = icnstrlst_free<knd> (ics, N)
in
  prs (lpdrv_id ()); prs " "; pri ans; prn ()
end // end of [run_bench]

fun run_all (): void = let
  val k = lpdrv_next ()
in
  if k = 1 then (run_problem (); run_all ())
  else if k = 2 then (run_arith (); run_all ())
  else if k = 3 then (run_bench (); run_all ())
  else ()
end // end of [run_all]
