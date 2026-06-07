;;; lisp.el --- Provide Lisp related features -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(use-package eglot)
(use-package geiser)
(use-package prism)

(use-package lispy
  :hook (emacs-lisp-mode . lispy-mode))

(use-package flymake-guile
  :hook (scheme-mode-hook . flymake-guile))


(provide 'pecus-lisp)

;;; lisp.el ends here
