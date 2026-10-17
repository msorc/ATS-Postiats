#!/usr/bin/env python3
#
# mutate.py: deliberate bugs in atsdoc and libatsdoc: every one must be detected by
# the md5 suite (suite.py). Usage (from utils/atsdoc/TEST, with the programs built):
#
#   python3 mutate.py          # all the mutations
#   python3 mutate.py 3 7      # only the mutations 3 and 7
#
# Each mutation changes one source file, rebuilds (make test), and restores the file
# (the files are compared with the originals at the end).
#
# HX-2026-10
#
import sys, os, subprocess
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '../../..'))
T = ROOT + '/utils/atsdoc/DATS/atsdoc_translate.dats'
I = ROOT + '/utils/atsdoc/DATS/atsdoc_translate_item.dats'
E = ROOT + '/utils/atsdoc/DATS/atsdoc_translate_error.dats'
M = ROOT + '/utils/atsdoc/DATS/atsdoc_main.dats'
A = ROOT + '/libatsdoc/DATS/libatsdoc_atext.dats'
S = ROOT + '/libatsdoc/DATS/libatsdoc_symbol.dats'
B = ROOT + '/libatsdoc/CATS/libatsdoc_sbuf.cats'

MUTATIONS = [
 (T, "  | _ when c = '\\'' => true\n  | _ => false\n// end of [IDENTRST_test]", "  | _ when c = '\\'' => false\n  | _ => false\n// end of [IDENTRST_test]", "the quote is not an identifier char"),
 (T, "  | '%' => let\n      val () = posincby1 (pos); val err = fputc_ref (c, out)", "  | '@' => let\n      val () = posincby1 (pos); val err = fputc_ref (c, out)", "\\% is not an escape"),
 (T, "$LOC.position_get_ncol (pos) = 1 => let", "$LOC.position_get_ncol (pos) = 2 => let", "%{ at the wrong column"),
 (I, "$LOC.position_get_ncol (pos) = 0 => let", "$LOC.position_get_ncol (pos) = 1 => let", "%} at the wrong column"),
 (I, "if c = ',' then let", "if c = ';' then let", "the separator of the arguments"),
 (I, "case+ c of '\\(' => ')' | '\\{' => '}' | _ => c", "case+ c of '\\(' => ')' | '\\{' => ')' | _ => c", "the closing brace"),
 (I, "      val () = sbuf_add_char (out, SLASH)\n      val () = sbuf_add_char (out, DQUOTE)\n    in", "      val () = sbuf_add_char (out, DQUOTE)\n    in", "a double quote is not escaped"),
 (E, "#define MAXLEN 100", "#define MAXLEN 99", "the number of errors kept"),
 (E, "the funarg list is not properly closed.", "the funarg list is not properly closed", "an error message"),
 (T, 'fprint_string (out, "$lst")', 'fprint_string (out, "$ls")', "the suffix of the list arguments"),
 (M, "val () = nif := nif + 1 // HX: cutting a corner!\n        val () = atsdoc_usage () // print out usage\n      }\n    else comarg_warning (key)\n  ) : void // end of [val]\nin\n  process_cmdline (argc, argv, i+1, wk, nif)\nend // end of [process_cmdline2_COMARGkey1]", "val () = atsdoc_usage () // print out usage\n      }\n    else comarg_warning (key)\n  ) : void // end of [val]\nin\n  process_cmdline (argc, argv, i+1, wk, nif)\nend // end of [process_cmdline2_COMARGkey1]", "-h does not count as an input"),
 (M, 'else if streq (key, "-oc") then {\n        val () = nif := 0', 'else if streq (key, "-oc") then {\n        val () = nif := nif', "-oc does not reset the input count"),
 (M, 'prerr_string "waring(ATSDOC)"', 'prerr_string "warning(ATSDOC)"', "the typo of the warning is kept"),
 (T, 'val () = $UN.ptr0_set<int> (p, 1)\nin p end\n\nfun funres_get_count', 'val () = $UN.ptr0_set<int> (p, 0)\nin p end\n\nfun funres_get_count', "the first token number"),
 (T, "DIGIT_test (c) = ('0' <= c andalso c <= '9')", "DIGIT_test (c) = ('0' <= c andalso c <= '8')", "the digits"),
 (T, "c = '\\t' orelse c = '\\n' orelse c = '\\v'", "c = '\\t' orelse c = '\\n'", "the vertical tab is not a space"),
 (B, "if (memchr (b->ptr, 0, b->len)) {", "if (0) {", "NUL in a string is accepted"),
 (T, "else ($UN.ptr0_get<char> ($UN.cast{ptr}(basename)) != '/')", "else ($UN.ptr0_get<char> ($UN.cast{ptr}(basename)) != '.')", "relative or absolute file name"),
 (A, "    | '#' => let\n        val _ = fputc_err ('#', out) in aux (out, inp, cur)\n      end // end of ['#']", "    | '#' => let\n        val _ = fputc_err ('\\\\', out); val _ = fputc_err ('#', out) in aux (out, inp, cur)\n      end // end of ['#']", "\\# keeps the backslash"),
 (A, 'fprint_string (out, "#"); fprint_string (out, id1); fprint_string (out, "$")', 'fprint_string (out, "#"); fprint_string (out, id1)', "an unknown token loses its $"),
 (A, "val () = if i > 0 then fprint_atext (out, sep)", "val () = if i > 1 then fprint_atext (out, sep)", "the separator of concatxtsep"),
 (A, 'implement atext_newline () = atext_strcst ("\\n")', 'implement atext_newline () = atext_strcst ("\\r\\n")', "the newline"),
 (A, "if n > 0 then fprsub_ident (out, cs) // valid identifier", "if n > 1 then fprsub_ident (out, cs) // valid identifier", "one-letter tokens"),
 (A, "return (int)(signed char)*p ;", "return (int)(unsigned char)*p ;", "a char of a string is unsigned"),
 (A, "theAtextMap_insert (s, x) = symbol_set_value (s, x)", "theAtextMap_insert (s, x) = if $UN.cast{lint}(symbol_get_value (s)) = 0L then symbol_set_value (s, x)", "insertion does not replace"),
 (A, 'fprint_string (stderr_ref, "] cannot be opened!\\n")', 'fprint_string (stderr_ref, "] cannot be opened.\\n")', "the message of fprint_filsub"),
]
MUTATIONS = [m for m in MUTATIONS if m[3]]

def main():
    sel = [int(x) for x in sys.argv[1:]]
    orig = {}
    for f in {m[0] for m in MUTATIONS}: orig[f] = open(f).read()
    nok = 0; nbad = 0
    for k, (f, old, new, what) in enumerate(MUTATIONS):
        if sel and k not in sel: continue
        s = orig[f]
        if s.count(old) != 1:
            print('%2d  SKIPPED (the pattern occurs %d times): %s' % (k, s.count(old), what)); nbad += 1; continue
        open(f, 'w').write(s.replace(old, new))
        try:
            r = subprocess.run(['make', '-C', HERE, 'test'], capture_output=True, text=True)
            out = r.stdout + r.stderr
            if 'error(' in out or 'Error' in out and 'cases,' not in out:
                verdict = 'BUILD FAILED'; nbad += 1
            elif r.returncode != 0:
                nfail = [l for l in out.splitlines() if 'cases,' in l]
                verdict = 'detected (%s)' % (nfail[0] if nfail else 'failure'); nok += 1
            else:
                verdict = 'NOT DETECTED'; nbad += 1
        finally:
            open(f, 'w').write(s)
        print('%2d  %s: %s' % (k, verdict, what)); sys.stdout.flush()
    # rebuild with the originals
    subprocess.run(['make', '-C', HERE, 'test'], capture_output=True)
    for f in orig: assert open(f).read() == orig[f]
    print('%d detected, %d problems' % (nok, nbad))
    return 1 if nbad else 0

if __name__ == '__main__':
    sys.exit(main())
