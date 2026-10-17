(* the cases of the API of pats_jsonize.{sats,dats}, shared by tooldump1.dats (ATS1) and tooldump.dats (ATS2) (see PORTING.md, section Tools)
   The driver defines before the include: the sets of jz_* of jzdump(1).hats, jz_ints (): list of the ints 1,2,3, jz_nil_ints (),
   jz_some7 (), jz_none7 (), jz_null (), jz_symopt_none (), jz_symopt_some (sym), jz_enums () (a list of the jsonvals of the enumerations). *)

fn api_case (name: string, jv: jsonval): void = {
  val () = (fprint_string (stdout_ref, "API "); fprint_string (stdout_ref, name); fprint_string (stdout_ref, ": "))
  val () = fprint_jsonval (stdout_ref, jv)
  val () = fprint_newline (stdout_ref)
}

fun api_strings (lo: int, hi: int, step: int): void =
  if lo <= hi then let
    val hi1 = (if lo + step - 1 < hi then lo + step - 1 else hi): int
    val s = jz_mkstr (lo, hi1)
    val () = (fprint_string (stdout_ref, "API str"); fprint_int (stdout_ref, lo); fprint_string (stdout_ref, ": "))
    val () = fprint_jsonval (stdout_ref, jsonval_string (s))
    val () = fprint_newline (stdout_ref)
  in api_strings (lo + step, hi, step) end

fun api_doubles (k: int): void =
  if k <= 8 then let
    val () = api_case ("double", jsonval_double (jz_double (k)))
  in api_doubles (k+1) end

fun api_run (): void = {
  val () = api_case ("int0", jsonval_int (0))
  val () = api_case ("int-", jsonval_int (~12345))
  val () = api_case ("intmax", jsonval_int (2147483647))
  val () = api_case ("intmin", jsonval_int (~2147483647 - 1))
  val () = api_case ("intinf0", jsonval_intinf ($INTINF.intinf_make_int (0)))
  val () = api_case ("intinf-", jsonval_intinf ($INTINF.intinf_make_int (~42)))
  val () = api_case ("intinfbig", jsonval_intinf ($INTINF.intinf_make_string ("123456789012345678901234567890")))
  val () = api_case ("intinfneg", jsonval_intinf ($INTINF.intinf_make_string ("-99999999999999999999")))
  val () = api_case ("true", jsonval_bool (true))
  val () = api_case ("false", jsonval_bool (false))
  val () = api_doubles (0)
  val () = api_case ("str-empty", jsonval_string (""))
  val () = api_case ("str-simple", jsonval_string ("hello world"))
  val () = api_case ("str-escapes", jsonval_string ("a\"b\\c\nd\re\tf/g"))
  val () = api_case ("str-bf", jsonval_string ("\b\f"))
  val () = api_strings (1, 255, 17)
  val () = api_case ("str-utf8", jsonval_string ("caf\303\251 \342\202\254"))
  val () = api_case ("null", jz_null ())
  val () = api_case ("location-dummy", jsonize_location ($LOC.location_dummy))
  val () = api_case ("filename-dummy", jsonize_filename ($FIL.filename_dummy))
  val () = api_case ("filename-stdin", jsonize_filename ($FIL.filename_stdin))
  val () = api_case ("filename-make", jsonize_filename ($FIL.filename_make ("given.sats", "part/given.sats", "/full/part/given.sats")))
  val () = api_case ("sing", jsonval_sing (jsonval_int (1)))
  val () = api_case ("pair", jsonval_pair (jsonval_int (1), jsonval_string ("two")))
  val () = api_case ("labval1", jsonval_labval1 ("a", jsonval_int (1)))
  val () = api_case ("labval2", jsonval_labval2 ("a", jsonval_int (1), "b", jsonval_int (2)))
  val () = api_case ("labval3", jsonval_labval3 ("a", jsonval_int (1), "b", jsonval_int (2), "c", jsonval_int (3)))
  val () = api_case ("labval4", jsonval_labval4 ("a", jsonval_int (1), "b", jsonval_int (2), "c", jsonval_int (3), "d", jsonval_int (4)))
  val () = api_case ("labval5", jsonval_labval5 ("a", jsonval_int (1), "b", jsonval_int (2), "c", jsonval_int (3), "d", jsonval_int (4), "e", jsonval_int (5)))
  val () = api_case ("labval6", jsonval_labval6 ("a", jsonval_int (1), "b", jsonval_int (2), "c", jsonval_int (3), "d", jsonval_int (4), "e", jsonval_int (5), "f", jsonval_int (6)))
  val () = api_case ("labval7", jsonval_labval7 ("a", jsonval_int (1), "b", jsonval_int (2), "c", jsonval_int (3), "d", jsonval_int (4), "e", jsonval_int (5), "f", jsonval_int (6), "g", jsonval_int (7)))
  val () = api_case ("labval8", jsonval_labval8 ("a", jsonval_int (1), "b", jsonval_int (2), "c", jsonval_int (3), "d", jsonval_int (4), "e", jsonval_int (5), "f", jsonval_int (6), "g", jsonval_int (7), "h", jsonval_int (8)))
  val () = api_case ("conarg0", jsonval_conarg0 ("C0"))
  val () = api_case ("conarg1", jsonval_conarg1 ("C1", jsonval_int (1)))
  val () = api_case ("conarg2", jsonval_conarg2 ("C2", jsonval_int (1), jsonval_int (2)))
  val () = api_case ("conarg3", jsonval_conarg3 ("C3", jsonval_int (1), jsonval_int (2), jsonval_int (3)))
  val () = api_case ("conarg4", jsonval_conarg4 ("C4", jsonval_int (1), jsonval_int (2), jsonval_int (3), jsonval_int (4)))
  val () = api_case ("conarglst", jsonval_conarglst ("CL", jz_cons (jsonval_int (1), jz_cons (jsonval_string ("x"), jz_nil ()))))
  val () = api_case ("conarglst0", jsonval_conarglst ("CL", jz_nil ()))
  val () = api_case ("none", jsonval_none ())
  val () = api_case ("some", jsonval_some (jsonval_int (5)))
  val () = api_case ("some-some", jsonval_some (jsonval_some (jsonval_none ())))
  val () = api_case ("list_fun", jsonize_list_fun<int> (jz_ints (), jz_int))
  val () = api_case ("list_fun0", jsonize_list_fun<int> (jz_nil_ints (), jz_int))
  val () = api_case ("option_fun-some", jsonize_option_fun<int> (jz_some7 (), jz_int))
  val () = api_case ("option_fun-none", jsonize_option_fun<int> (jz_none7 (), jz_int))
  val () = api_case ("ignored", jz_ignored3 ())
  val () = api_case ("symbol", jsonize_symbol ($SYM.symbol_make_string ("a symbol")))
  val () = api_case ("symbolopt-none", jsonize_symbolopt (jz_symopt_none ()))
  val () = api_case ("symbolopt-some", jsonize_symbolopt (jz_symopt_some ($SYM.symbol_make_string ("s"))))
  val () = api_case ("label-int", jsonize_label ($LAB.label_make_int (3)))
  val () = api_case ("label-sym", jsonize_label ($LAB.label_make_string ("lab")))
  val () = api_case ("stamp1", jsonize_stamp ($STA.d2var_stamp_make ()))
  val () = api_case ("stamp2", jsonize_stamp ($STA.d2var_stamp_make ()))
  val () = api_case ("enums", jz_enums ())
  val () = api_case ("nested", jsonval_labval2 ("l", jsonize_list_fun<int> (jz_ints (), jz_int), "o", jsonval_some (jsonval_labval1 ("k", jsonval_string ("v")))))
}
