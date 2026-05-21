;;; wm.el --- Provide features usefull on a full display -*- lexical-binding: t; -*-

;;; Commentary:

;;; Code:

;; Theme
(load-theme 'modus-vivendi)

;; Fonts
(set-frame-font "iosevka 12" nil t)

(require 'reka)
(reka-enable)

(provide 'pecus-wm)

;;; wm.el ends here
