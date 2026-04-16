;;; Code:

(use-modules
  gnu
  guix
  guix packages
  srfi srfi-1)
(use-service-modules 
  mcron
  networking
  shepherd
  ssh
  virtualization)
(use-package-modules admin
  bash
  certs
  compression
  emacs
  emacs-xyz
  file-systems
  gawk
  guile
  guile-xyz
  gnupg
  less
  linux
  man
  ncurses
  polkit
  rsync
  python
  python-web
  texinfo
  tree-sitter
  version-control
  virtualization
  wget)

(operating-system
  (host-name "matrix")
  (users (cons* (user-account
                  (name "neo")
                  (comment "The One")
                  (group "users")
                  (home-directory "/home/neo"))
                %base-user-accounts))
  (bootloader
    (bootloader-configuration
      (bootloader grub-efi-bootloader)
      (targets "/boot/efi")
      (keyboard-layout keyboard-layout)))
  (mapped-devices
    (list (mapped-device
            (source
              (uuid ""))
            (targets '("cryptroot"))
            (type luks-device-mapping))))
  (file-systems
    (cons* (file-system
             (mount-point "/")
             (device "/dev/mapper/cryptroot")
             (type "bcachefs")
             (dependencies mapped-devices))
           (file-system
             (mount-point "/boot/efi")
             (device (uuid "" 'fat32))
             (type "vfat"))
           %base-file-systems))
  (packages
    (append
      %pecus-base-packages))
  (services
    (append
      (list
      %base-services
      %pecus-base-services))))

;;; matrix-config.scm ends here
