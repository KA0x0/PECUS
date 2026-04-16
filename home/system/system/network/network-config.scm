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
(use-package-modules
  admin
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

;;; Code:

(operating-system
  (host-name "network")
  (users (cons* (user-account
                  (name "route")
                  (comment "Routing")
                  (group "users")
                  (home-directory "/home/route"))
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
      (list
        ppp)
        %pecus-base-packages))
  (services
    (append
      (list
        (service static-networking-service-type
          (list
            (static-networking
              (addresses
                (list
                 (network-address
                  (device "eno1")
                  (value "10.0.0.1/24"))))
              (routes
                (list
                  (network-route
                   (destination "default")
                   (gateway "10.10.10.10"))))
              (name-servers '("10.10.10.10")))))
        %base-services
        %pecus-base-services))))

;;; network-config.scm ends here
