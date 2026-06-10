;;; python.el --- Provide Python related features -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

(use-package eglot)

(use-package python-ts-mode
  :hook
  (python-mode . eglot-ensure))  ; connect to language server when py-file is opened


(provide 'pecus-python)

;;; python.el ends here
