(use-modules
  (gnu)
  (guix)
  (guix packages)
  (srfi
  srfi-1))
(use-service-modules
  desktop
  mcron
  networking
  shepherd
  spice
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
  (host-name "dev")
  (users (cons* (user-account
                  (name "ka0x")
                  (comment "We are legion")
                  (group "users")
                  (shell (file-append bash "/bin/bash"))
                  (home-directory "/home/ka0x")
                  (supplementary-groups
                    '("adbusers" "audio" "kvm" "netdev" "video" "wheel")))
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
        pecus-emacs-next
        emacs-exwm
        emacs-xdg-launcher
        fontconfig
        iwd
        mailutils
        pipewire
        spice-vdagent
        xf86-video-amdgpu)
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
        (service bluetooth-service-type)
        (service elogind-service-type)
        (service libvirt-service-type)
        (service spice-vdagent-service-type) ;; Add support for the SPICE protocol, which enables dynamic resizing of the guest screen resolution, clipboard integration with the host, etc.
       %base-services
       %pecus-base-services))))

;;; dev-config.scm ends here
