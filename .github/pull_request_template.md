## What and why

<!-- What does this change, and why? Link the issue it closes: "Closes #123". -->

## How it was tested

<!-- The commands you ran and their result. For the compiler: `make -C src check`
and `make -C src test`; for the libraries and examples: `make -C doc -f Makefile_test testall`;
for the tools: `make -C utils/atsdoc test`, `make -C utils/libatsynmark test`. -->

## Checklist

- [ ] The change is small and focused; formatting changes are separate commits.
- [ ] New code follows the no-GC rules (linear heap only; see CONTRIBUTING.md).
- [ ] The tests that the change can affect pass (listed above).
- [ ] The documentation is updated, and `CHANGES-ats2` has a note if the change is visible to users.
- [ ] New files have an SPDX license header that matches their directory (LICENSES.md); no license text was changed.
- [ ] Generated files (`prelude/*/SRCGEN`, `src/CBOOT`, `pats_*_gen*.hats`) were regenerated, not edited by hand.
