;;; Code:

(use-modules
  gnu
  guix
  guix packages
  srfi srfi-1)
(use-service-modules 
  desktop
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

(operating-system
  (host-name "laptop")
  (users (cons* (user-account
                  (name "mobile")
                  (comment "Mobile")
                  (group "users")
                  (home-directory "/home/mobile")
                  (supplementary-groups
                    '("audio"
                      "kvm"
                      "netdev"
                      "video")))
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
        dbus
        pecus-emacs-next
        emacs-exwm
        lm-sensors
        xorg-server-xwayland)
      %pecus-base-packages))
  (services
    (append
      (list
        (service elogind-service-type)
        (service libvirt-service-type)
        %base-services
        %pecus-base-services))))

;;; laptop-config.scm ends here
