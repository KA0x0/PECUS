;;; init.el --- Initial configuration -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(use-package compat)

(treesit-enabled-modes 1)

(setopt guix-geiser-connection-timeout (* 1000 60 30)) ;; 30 mins

(provide 'init)

;;; init.el ends here
