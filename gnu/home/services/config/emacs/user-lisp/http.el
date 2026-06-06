;;; http.el --- Hyper Text Transfer Protocol -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(use-package org
  :mode ("\\.org\\'" . org-mode)
  :config (define-key org-mode-map (kbd "C-c C-r") verb-command-map))

(use-package graphql-ts-mode)

(use-package swagg)


(provide 'pecus-http)

;;; http.el ends here
