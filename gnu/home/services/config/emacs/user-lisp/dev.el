;;; dev.el --- Provide development related features -*- lexical-binding: t; -*-

;;; Commentary: Small development related packages that do not belong in a file

;;; Code:

(use-package polymode)

(use-package helpful
 :config
 ;; Note that the built-in `describe-function' includes both functions
 ;; and macros. `helpful-function' is functions only, so we provide
 ;; `helpful-callable' as a drop-in replacement.
 (global-set-key (kbd "C-h f") #'helpful-callable)
 
 (global-set-key (kbd "C-h v") #'helpful-variable)
 (global-set-key (kbd "C-h k") #'helpful-key)
 (global-set-key (kbd "C-h x") #'helpful-command)
 
 ;; Lookup the current symbol at point. C-c C-d is a common keybinding
 ;; for this in lisp modes.
 (global-set-key (kbd "C-c C-d") #'helpful-at-point)
 
 ;; Look up *F*unctions (excludes macros).
 ;;
 ;; By default, C-h F is bound to `Info-goto-emacs-command-node'. Helpful
 ;; already links to the manual, if a function is referenced there.
 (global-set-key (kbd "C-h F") #'helpful-function))

(setopt explicit-shell-file-name "pwsh")
(setopt explicit-pwsh-args '("-NoLogo"))

(use-package graphviz-dot-mode)


(provide 'pecus-dev)

;;; dev.el ends here
