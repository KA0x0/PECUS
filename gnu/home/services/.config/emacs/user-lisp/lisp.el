;;; lisp.el --- Provide Lisp related features -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(use-package eglot)
(use-package geiser)

(use-package lispy
  :hook (emacs-lisp-mode . lispy-mode))


(provide 'pecus-lisp)

;;; lisp.el ends here
