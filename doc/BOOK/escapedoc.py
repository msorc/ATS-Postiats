#!/usr/bin/env python3
"""Escape the text nodes of the DocBook files of a book.

The books are written in the .atxt format and atsdoc turns the chapters
into DocBook files (CHAP_*/main.db) that main.db includes with general
entities.  The text of a code block is copied verbatim, so it may
contain a raw '<' (as in "(1 < 2)") or a raw '&' (as in "&&"); such a
file is not well-formed XML and no XML tool (xsltproc, for instance)
can read it.  This script rewrites the files that are given on the
command line, escaping the text nodes and leaving the markup alone.

Usage: escapedoc.py FILE ...
"""

import re
import sys

REF = re.compile(r'&(?:[A-Za-z_][A-Za-z0-9_.-]*|#[0-9]+|#x[0-9A-Fa-f]+);')
NAME_START = re.compile(r'[A-Za-z]')


def escape_text(text):
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


def main():
    for path in sys.argv[1:]:
        with open(path, encoding='utf-8') as f:
            text = f.read()
        with open(path, 'w', encoding='utf-8') as f:
            f.write(escape_text(text))


main()
