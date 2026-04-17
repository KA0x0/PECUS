;;; GNU Guix --- Functional package management for GNU
;;;
;;; This file is NOT part of GNU Guix.
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation, either version 3 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Code:

(define-module (packages pecus-emacs)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix utils)
  #:use-module (guix build utils)
  #:use-module (gnu packages autotools)
  #:use-module (gnu packages base)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages xorg)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1)
  #:use-module (srfi srfi-26))

(define-public pecus-emacs-next
    (package
      (inherit emacs-next)
      (snippet
          '(begin
            (with-directory-excursion "emacs/lisp"
              (for-each delete-file-recursively
                '("emulation"
                  "erc"
                  "which-key.el" ;; use transient
                  "mh-e"
                  "net/dig.el"
                  "obsolete"
                  "play")))))))

(define-public pecus-emacs-next-no-x
    (package
      (inherit pecus-emacs-next)
    (build-system gnu-build-system)
    (inputs (fold alist-delete
                  (package-inputs emacs)
                  '("libx11" "gtk+" "libxft" "libtiff" "giflib" "libjpeg"
                    "imagemagick" "libpng" "librsvg" "libxpm" "libice"
                    "libsm" "cairo" "pango" "harfbuzz"
                    ;; These depend on libx11, so remove them as well.
                    "libotf" "m17n-lib" "dbus")))
      (arguments
       (substitute-keyword-arguments (package-arguments pecus-emacs-next-no-x)
         ((#:configure-flags flags ''())
          `(delete "--with-cairo" ,flags))
       ((#:phases phases)
        `(modify-phases ,phases
           (delete 'restore-emacs-pdmp)
           (delete 'strip-double-wrap)))))))

(define-public pecus-emacs-guix-shell
  (package
    (name "emacs-guix-shell")
    (version "0.1")
    (source 
      (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://git.dthompson.us/emacs-guix-shell.git")
             (commit (string-append "v" version))))
              (file-name (git-file-name name version))
       (sha256
        (base32 "6f8d6dd0e3afe8f129c362281b1b63dd70632a4f"))))
    (build-system emacs-build-system)
   (home-page "https://git.dthompson.us/emacs-guix-shell")
    (synopsis "Support for 'guix shell'")
    (description
    "This Emacs extension integrates 'guix shell' to set per-buffer
     environment variables appropriately.")
    (license gpl3+)))

(define-public pecus-emacs-jwt
  (package
    (name "emacs-jwt")
    (version "0.2.0")
    (source 
      (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/joshbax189/jwt-el.git")
             (commit (string-append "v" version))))
              (file-name (git-file-name name version))
       (sha256
        (base32 "d6754f8fab6ff4041a7bece1963495e99ad9fe68"))))
    (build-system emacs-build-system)
   (home-page "https://github.com/joshbax189/jwt-el")
    (synopsis "Interact with JSON Web Tokens from Emacs")
    (description
    "Decode and verify JSON Web Tokens in Emacs.")
    (license gpl3+)))

;;; emacs.scm ends here
