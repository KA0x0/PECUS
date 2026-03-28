;;; Code:

(use-modules
  gnu
  guix
  guix packages
  srfi srfi-1)
(use-service-modules
  mcron
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
   (host-name "kracken")
   (bootloader
    (bootloader-configuration
     (bootloader dummy-bootloader)))
   (kernel dummy-kernel)
   (initrd dummy-initrd)
   (initrd-modules '())
   (firmware '())
   (file-systems '())
   (users (cons* (user-account
                  (name "ai")
                  (comment "Aissitant Kracken")
                  (group "users")
                  (supplementary-groups
                    '("audio" "kvm" "video" "wheel"))
                  (shell (file-append bash "/bin/bash")))
                 (user-account
                  (inherit %root-account)
                  (shell (wsl-boot-program "guest")))
                 %base-user-accounts))
   (packages
    (append
      (list
        xf86-video-amdgpu
        sshfs
        xorg-server-xwayland)
      %pecus-base-packages))
   (services
    (append
      (list
        (service guix-service-type)
        (service special-files-service-type
          `(("/bin/sh" ,(file-append bash "/bin/bash"))
            ("/bin/mount" ,(file-append util-linux "/bin/mount"))
            ("/usr/bin/env" ,(file-append coreutils "/bin/env"))
      %base-services
      %pecus-base-services))))))

;;; wsl-config.scm ends here

