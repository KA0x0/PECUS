;;; spellcheck.el --- Provide Spell Checking -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(setopt flymake-show-diagnostic-at-end-of-line fancy)

(use-package jinx
  :hook (emacs-startup . global-jinx-mode))


(provide 'pecus-spellcheck)

;; spellcheck.el ends here
