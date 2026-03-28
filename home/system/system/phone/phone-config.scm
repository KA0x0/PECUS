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

(operating-system
  (host-name "phone")
  (users (cons* (user-account
                  (name "mobile")
                  (comment "Mobile")
                  (group "users")
                  (shell (file-append bash "/bin/bash"))
                  (home-directory "/home/mobile"))
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
        bluez
        dbus
        emacs-with-native-comp-no-x
        iwd
        picom
        pipewire
        xorg-server-xwayland)
      %pecus-base-packages))
  (services
    (append
      (list 
        (service autofs-service-type
         (autofs-configuration
          (mounts
           (list
            (autofs-mount-configuration ;; mount -t fuse and autofs
              (target "/mnt/storage/kaox")
              (source ":sshfs\\#node.home.arpa\\:/mnt/storage/kaox"))))))
             (extra-special-file "/bin/sshfs"
                (file-append sshfs "/bin/sshfs"))
              (extra-special-file "/bin/ssh"
                (file-append openssh "/bin/ssh"))
        (service elogind-service-type)
        (service libvirt-service-type)
      %base-services
      %pecus-base-services))))

;;; phone-config.scm ends here
