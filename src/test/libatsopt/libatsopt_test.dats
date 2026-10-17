(* libatsopt_test: calls the API of libatsopt (src/libatsopt_ext.c, src/libatsopt_ext.dats).
   usage: libatsopt_test ARGS...  runs [libatsopt_patsopt_main_opt] on the arguments (like the patsopt of utils/libatsopt/TEST)
          libatsopt_test -r FILE   compiles FILE (dynamic) with [libatsopt_patsoptres_main_arglst] and prints the captured stdout
          libatsopt_test -i        compiles the strings of the program itself with a [strinp] and a prefil/postfil *)
#include "share/atspre_staload.hats"
(* ****** ****** *)
abstype comarg = ptr
abstype comarglst = ptr
abstype patsoptres = ptr
extern fun libatsopt_dynloadall (): void = "ext#libatsopt_dynloadall"
extern fun patsopt_main_opt (argc: int, argv: ptr): bool = "ext#libatsopt_patsopt_main_opt"
extern fun comarg_strlit (x: string): comarg = "ext#libatsopt_comarg_strlit"
extern fun comarg_strinp (x: string): comarg = "ext#libatsopt_comarg_strinp"
extern fun comarg_prefil (x: string): comarg = "ext#libatsopt_comarg_prefil"
extern fun comarg_postfil (x: string): comarg = "ext#libatsopt_comarg_postfil"
extern fun comarglst_nil (): comarglst = "ext#libatsopt_comarglst_nil"
extern fun comarglst_cons (x: comarg, xs: comarglst): comarglst = "ext#libatsopt_comarglst_cons"
extern fun patsopt_main_arglst (args: comarglst): int = "ext#libatsopt_patsopt_main_arglst"
extern fun patsoptres_main_arglst (args: comarglst): patsoptres = "ext#libatsopt_patsoptres_main_arglst"
extern fun patsoptres_get_nerr (res: patsoptres): int = "ext#libatsopt_patsoptres_get_nerr"
extern fun patsoptres_get_stdout (res: patsoptres): string = "ext#libatsopt_patsoptres_get_stdout"
extern fun patsoptres_get_stderr (res: patsoptres): string = "ext#libatsopt_patsoptres_get_stderr"
(* ****** ****** *)
#define HELLO "implement main0 () = println! (\"Hello, world!\")\n"
(* ****** ****** *)
fn argv_get (argv: ptr, i: int): string = $UNSAFE.ptr0_get<string> (ptr0_add_guint<string> (argv, g0int2uint_int_size(i)))
fun run (argc: int, argv: ptr): int = let
  val () = libatsopt_dynloadall ()
in
  if argc >= 2 then let
    val a1 = argv_get (argv, 1)
  in
    if a1 = "-r" then let
      // the file name is read from the command line: -r FILE is [--dynamic FILE]
      val args = comarglst_cons (comarg_strlit ("--dynamic"), comarglst_cons (comarg_strlit (argv_get (argv, 2)), comarglst_nil ()))
      val res = patsoptres_main_arglst (args)
      val () = fprint_string (stdout_ref, patsoptres_get_stdout (res))
      val () = fprint_string (stderr_ref, patsoptres_get_stderr (res))
      val () = fprint_string (stderr_ref, "nerr=") val () = fprint_int (stderr_ref, patsoptres_get_nerr (res))
      val () = fprint_newline (stderr_ref)
    in 0 end
    else if a1 = "-i" then let
      val args =
        comarglst_cons (comarg_strlit ("--dynamic"),
        comarglst_cons (comarg_prefil ("// PRE\n"),
        comarglst_cons (comarg_postfil ("// POST\n"),
        comarglst_cons (comarg_strinp (HELLO), comarglst_nil ()))))
      val nerr = patsopt_main_arglst (args)
      val () = if nerr > 0 then prerr_string ("[patsopt_main_arglst] encountered errors!\n")
    in 0 end
    else let
      val ok = patsopt_main_opt (argc, argv)
      val () = if ok then prerr_string ("[patsopt] exited normally!\n") else prerr_string ("[patsopt] exited abnormally!\n")
    in 0 end
  end else (prerr_string ("Hello from ATS2(ATS/Postiats)!\n"); 1)
end // end of [run]
implement
main0 (argc, argv) = let
  val (pf, fpf | p) = argv_takeout_strarr (argv)
  val _ = run (argc, $UNSAFE.cast{ptr}(p))
  prval () = minus_addback (fpf, pf | argv)
in end

