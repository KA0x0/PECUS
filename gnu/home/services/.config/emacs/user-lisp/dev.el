;;; dev.el --- Provide development related features -*- lexical-binding: t; -*-

;;; Commentary: Small development related packages that do not belong in a file

;;; Code:

(use-package polymode)

(setopt explicit-shell-file-name "pwsh")
(setopt explicit-pwsh-args '("-NoLogo"))

(use-package protobuf-mode)

(use-package graphviz-dot-mode)


(provide 'pecus-dev)

;;; dev.el ends here
