# utils/emacs

The Emacs mode of ATS2: `ats2-mode.el` (the major mode), `flycheck-ats2.el`
(the integration with flycheck) and `flymake-ats2.el` (the integration
with flymake).

Put `ats2-mode.el` in your load path and add

    (require 'ats2-mode)
    (add-to-list 'auto-mode-alist '("\\.\\(dats\\|sats\\|hats\\|cats\\)$" . ats2-mode))

to your init file.

The directory is part of the release tarball (`doc/DISTRIB`).
