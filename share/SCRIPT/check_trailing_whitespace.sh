#!/bin/sh
#
# SPDX-FileCopyrightText: 2026 Mikhail Sorochan
# SPDX-License-Identifier: MIT
#
# The CI gate for trailing whitespace: lists the (tracked) hand-written source
# files that have a line ending in a space or a tab and exits 1 if there is one.
#
#   sh share/SCRIPT/check_trailing_whitespace.sh         # check
#   sh share/SCRIPT/check_trailing_whitespace.sh --fix   # remove it
#
# The file set is the one of the cleanup (see .editorconfig): source files
# (.dats .sats .hats .cats .c .h .py .sh .mk .yml, Makefiles) but not
#
#   - the generated files: SRCGEN, *_gen*, src/CBOOT, the Makefile that
#     has a Makefile.atxt, any file that says "generated" in its first lines;
#   - the files whose bytes are hashed by the tests: prelude/, libats/, share/,
#     src/test/, utils/atsdoc/TEST, utils/libatsynmark/TEST, *.atxt,
#     *.expected, *.md5, contrib/atscntrb/atscntrb-hx-cstream (printed by a
#     template of genall.md5);
#   - Markdown (the two trailing spaces are a line break) and binary files.
#
# A line that continues a string with a backslash is not touched either way.
#
# PATSHOME is the root of the repository (the default is the parent of share/).
#
######

cd "$(dirname "$0")/../.." || exit 2

fix=0
[ "$1" = "--fix" ] && fix=1

exec python3 - "$fix" <<'PYEOF'
import os, re, subprocess, sys

fix = sys.argv[1] == "1"

EXT = (".dats", ".sats", ".hats", ".cats", ".c", ".h", ".py", ".sh", ".mk", ".yml")
SKIP_PREFIX = (
    "prelude/", "libats/", "share/", "src/CBOOT/", "src/test/",
    "utils/atsdoc/TEST/", "utils/libatsynmark/TEST/",
    # DOCUGEN/cstream.atxt prints these files, its md5 in utils/atsdoc/TEST/genall.md5 hashes them
    "contrib/atscntrb/atscntrb-hx-cstream/",
)
SKIP_PART = ("SRCGEN/", "/BUILD/", "/cc_tmp")

def skipped(f):
    if f.startswith(SKIP_PREFIX) or any(p in f for p in SKIP_PART):
        return True
    b = os.path.basename(f)
    if "_gen" in b or b.endswith((".atxt", ".expected", ".md5", ".md")):
        return True
    if not (b.endswith(EXT) or b.startswith("Makefile") or b == "Makefile"):
        return True
    d = os.path.dirname(f)
    if os.path.exists(os.path.join(d, b + ".atxt")):   # a Makefile made from Makefile.atxt
        return True
    return False

files = subprocess.check_output(["git", "ls-files", "-z"]).decode().split("\0")
bad = []
nfiles = 0
for f in files:
    if not f or skipped(f) or os.path.islink(f) or not os.path.isfile(f):
        continue
    data = open(f, "rb").read()
    if b"\0" in data:
        continue
    head = b"\n".join(data.split(b"\n")[:10]).lower()
    if b"generated" in head or b"do not edit" in head:
        continue
    nfiles += 1
    lines = data.split(b"\n")
    out = []
    changed = False
    prev = b""
    for i, l in enumerate(lines):
        core = l[:-1] if l.endswith(b"\r") else l
        m = re.search(rb"[ \t]+$", core)
        keep = prev.rstrip(b"\r").endswith(b"\\") or re.search(rb"\\[ \t]+$", core)
        if m and not keep:
            bad.append("%s:%d" % (f, i + 1))
            changed = True
            core = core[: m.start()]
            l = core + (b"\r" if l.endswith(b"\r") else b"")
        out.append(l)
        prev = lines[i]
    if fix and changed:
        open(f, "wb").write(b"\n".join(out))

if fix:
    print("fixed %d lines (%d files checked)" % (len(bad), nfiles))
    sys.exit(0)
if bad:
    print("trailing whitespace in %d lines, for example:" % len(bad))
    for x in bad[:30]:
        print("  " + x)
    print("fix with: sh share/SCRIPT/check_trailing_whitespace.sh --fix")
    sys.exit(1)
print("no trailing whitespace (%d files checked)" % nfiles)
PYEOF
