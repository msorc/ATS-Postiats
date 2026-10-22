#!/usr/bin/env python3
"""Highlight the ATS code of the HTML files of a book.

The code blocks of the DocBook source of a book are marked with
"############dats2xhtml_docbook(\"\"\" ... \"\"\")" (the marker is made
by atsdoc) and the tool mytexting (of the MYTEXT directory of the book)
replaces them with HTML that is highlighted by libatsynmark.

The code of a block is escaped in the HTML (as "&lt;" and "&gt;"), so it
is unescaped before mytexting reads it (the ATS parser needs the code
as it is) and escaped again afterwards.

Usage: hilite.py MYTEXTING FILE.html ...
"""

import os
import re
import subprocess
import sys
import tempfile

BLOCK = re.compile(r'(#+\w*_docbook\(""")(.*?)("""\))', re.S)
REF = re.compile(r'&(?:[A-Za-z_][A-Za-z0-9_.-]*|#[0-9]+|#x[0-9A-Fa-f]+);')
NAME_START = re.compile(r'[A-Za-z]')


def unescape(text):
    return text.replace('&lt;', '<').replace('&gt;', '>').replace('&amp;', '&')


def escape_text(text):
    """escape the '&' and the '<' of the text nodes of an HTML file"""
    out = []
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        if c == '<':
            if i + 1 < n and (NAME_START.match(text[i + 1]) or text[i + 1] in '/!?'):
                # a tag: copy it as it is
                k = i + 1
                quote = ''
                while k < n:
                    ch = text[k]
                    if quote:
                        if ch == quote:
                            quote = ''
                    elif ch in '"\'':
                        quote = ch
                    elif ch == '>':
                        break
                    k += 1
                out.append(text[i:k + 1])
                i = k + 1
                continue
            out.append('&lt;')
            i += 1
            continue
        if c == '&':
            m = REF.match(text, i)
            if m:
                out.append(m.group(0))
                i = m.end()
                continue
            out.append('&amp;')
            i += 1
            continue
        out.append(c)
        i += 1
    return ''.join(out)


def unescape_blocks(text):
    return BLOCK.sub(lambda m: m.group(1) + unescape(m.group(2)) + m.group(3), text)


def hilite_one(mytexting, path):
    with open(path, 'rb') as f:
        raw = f.read()
    try:
        text = raw.decode('utf-8')
    except UnicodeDecodeError:
        sys.stderr.write('hilite: %s is not encoded in UTF-8: it is skipped\n' % path)
        return True
    if '_docbook("""' not in text:
        return True
    tmpdir = tempfile.mkdtemp(prefix='hilite-')
    src = os.path.join(tmpdir, 'in.html')
    dst = os.path.join(tmpdir, 'out.html')
    with open(src, 'w', encoding='utf-8') as f:
        f.write(unescape_blocks(text))
    cmd = [mytexting, '-ns', '12', '--output', dst, '--input', src]
    if subprocess.call(cmd) != 0:
        sys.stderr.write('hilite: the code of %s could not be parsed\n' % path)
        return False
    with open(dst, encoding='utf-8') as f:
        out = f.read()
    with open(path, 'w', encoding='utf-8') as f:
        f.write(escape_text(out))
    return True


def main():
    if len(sys.argv) < 3:
        sys.stderr.write('usage: hilite.py MYTEXTING FILE.html ...\n')
        return 1
    mytexting = sys.argv[1]
    failed = 0
    for path in sys.argv[2:]:
        if not hilite_one(mytexting, path):
            failed += failed + 1
    return 1 if failed else 0


main()
