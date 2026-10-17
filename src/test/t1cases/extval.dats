(* $extval, $extfcall, $extmcall, $extype, ... *)
abstype T = $extype"mytype"
typedef V = $extype_struct "mystruct" of {x= int, y= $extype"foo"}
typedef W = $extkind "mykind"
val a = $extval (int, "42")
val b = $extfcall (int, "f", 1, 2)
val c = $extfcall (void, "g")
val d = $extmcall (int, a, "m", 1)
val e = $extmcall (int, a, "m")
val f : int = $literal (1)
val g = $tyrep (int)
val h = $effmask_all (1)
val i = $effmask_ntm (1)
val j = $effmask_exn (1)
val k = $effmask_ref (1)
val l = $effmask_wrt (1)
val n = $vcopyenv_v (a)
val o = $vcopyenv_vt (a)
val p = $showtype a
val q = $myfilename
val r = $mylocation
val s = $myfunction
val t = $raise (X ())
val u = $arrpsz{int}(1, 2, 3)
val v = $arrpsz(1, 2)
val w = @[int][3](0)
val x = @[int][3]()
val y = $tup (1, 2)
val z = $rec {a=1, b=2}
val z1 = $ldelay (1)
val z2 = $delay (1)
val z3 = '(1, 2)
val z4 = @(1, 2)
val z5 = @{a=1, b=2}
val z6 = '{a=1, b=2}
val z7 = $lst (1, 2)
val z8 = $lst_t {int} (1, 2)
val z9 = $lst_vt {int} (1, 2)
val z10 = list_vt_cons (1, list_vt_nil ())
val z11 = $solver_assert (pf)
val z12 = $solver_verify (x)
