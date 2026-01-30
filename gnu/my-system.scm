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

(define-module (gnu pecus-system)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages certs)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages file-systems)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages guile)
  #:use-module (gnu packages guile-xyz)
  #:use-module (gnu packages gnupg)
  #:use-module (gnu packages less)
  #:use-module (gnu packages man)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages polkit)
  #:use-module (gnu packages rsync)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages texinfo)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages version-control)
  #:use-module (gnu packages virtualization)
  #:use-module (gnu packages wget)
  #:use-module (shepherd service system-log)
  #:use-module (shepherd service timer)
  #:export (%pecus-base-operating-system)
  #:export (%pecus-base-packages)
  #:export (%pecus-base-services))

(define-public %pecus-base-operating-system
  (operating-system
   (locale "en_US.utf8")
   (timezone "Etc/UTC")
   (keyboard-layout (keyboard-layout "us" "ru"))))

(define-public %pecus-base-packages
  (map specification->package
  '("awscli-2"
    "bash"
    "bcachefs-linux-module"
    "bcachefs-tools"
    "blesh"
    "bridge-utils"
    "bzip2"
    "coreutils"
    "curl"
    "diffutils"
    "pecus-emacs-next-no-x"
    "pecus-emacs-guix-shell"
    "emacs-ace-window"
    "emacs-arei"
    "emacs-avy"
    "emacs-casual-avy"
    "emacs-cape"
    "emacs-casual"
    "emacs-combobulate"
    "emacs-consult" "emacs-consult-eglot"
    "emacs-corfu"
    "emacs-denote"
    "emacs-consult-denote"
    "emacs-embark"
    "emacs-eshell-syntax-highlighting"
    "emacs-exec-path-from-shell"
    "emacs-gptel"
    "emacs-guix"
    "emacs-inheritenv"
    "emacs-lispy"
    "emacs-logview"
    "emacs-marginalia"
    "emacs-mcp"
    "emacs-orderless"
    "emacs-prism"
    "emacs-vertico"
    "emacs-vundo"
    "emacs-with-editor"
    "emacs-yaml-pro"
    "eudev"
    "findutils"
    "gawk"
    "git"
    "gnupg"
    "grep"
    "emacs-flymake-guile"
    "guile-next"
    "guile-ares-rs"
    "guile-bytestructures"
    "guile-colorized"
    "guile-fibers-next"
    "guile-gcrypt"
    "guile-git"
    "guile-json"
    "guile-lsp-server"
    "guile-readline"
    "guile-ssh"
    "gzip"
    "iproute"
    "jq"
    "kmod"
    "less"
    "libselinux"
    "lzip"
    "lzop"
    "man-db"
    "ncurses-with-gpm"
    "nftables"
    "nmap"
    "nss-certs"
    "openssh-sans-x"
    "procps"
    "polkit"
    "python-debug-sans-pip-wrapper"
    "rsync"
    "sed"
    "shadow"
    "sudo"
    "tar"
    "texinfo"
    "tree-sitter-bash"
    "tree-sitter-elisp"
    "tree-sitter-json"
    "tree-sitter-python"
    "tree-sitter-yaml"
    "util-linux+udev"
    "which"
    "xz"
    "zstd")))

(define pecus-motd
     (service login-service-type
               (login-configuration
                (motd (plain-file "motd" "\
                  UNAUTHORIZED ACCESS TO THIS DEVICE IS PROHIBITED.\n
                  You must have explicit, authorized permission to access this device.\n
                  Unauthorized attempts and actions to access or use this system may result in civil and/or criminal penalties.\n
                  All activities performed on this device are logged and monitored.\n\n")))))

(define (hardcoded-editor))

(define-public %pecus-base-services
  (append
      (list (service pecus-dns)
            (service login-service-type pecus-motd)
            (service nftables-service-type)
            (service ntp-service-type)
            (service openssh-service-type
              (openssh-configuration
                (authorized-keys
                  ("ka0x" ,(local-file "/etc/ssh/authorized_keys.d/ka0x.pub")))))
            (service system-log-service))))

;;; pecus-system.scm ends here
