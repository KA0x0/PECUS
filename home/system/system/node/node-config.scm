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
  (host-name "node")
  (users (cons* (user-account
                  (name "virtualizer")
                  (comment "I virtualize stuff")
                  (group "users")
                  (home-directory "/home/virtualizer")
                  (supplementary-groups
                    '("cgroup"
                      "kvm"
                      "netdev")))
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
        physical)
    %pecus-base-packages))
  (services
    (append
      (list (service static-networking-service-type
              (list (static-networking
                     (addresses
                      (list (network-address
                             (device "eno1")
                             (value "10.0.0.50/8"))))
                     (routes
                      (list (network-route
                             (destination "default")
                             (gateway "10.10.10.10"))))
                     (name-servers '("10.10.10.10")))))
            (simple-service 'oci-provisioning
                oci-service-type
                (oci-extension
                  (networks
                    (list
                      (oci-network-configuration 
                        (name "macvlan-internal")
                        (driver "macvlan"))))
                  (containers
                    (list
                      (oci-container-configuration
                        (name "archisteamfarm")
                        (network "macvlan-internal")
                        (image "docker.io/justarchi/archisteamfarm:released")
                        (volumes
                         '((/mnt/storage/config/archisteamfarm/config:/app/config))))
                      (oci-container-configuration
                        (name "twitch-miner")
                        (network "private")
                        (image "docker.io/mrcraftcod/channel-points-miner:main")
                        (volumes
                         '((/mnt/storage/config/twitch-miner/authentication:/usr/src/app/authentication)
                           (/mnt/storage/config/twitch-miner/channel:/usr/src/app/channel:ro)
                           (/mnt/storage/config/twitch-miner/config.json:/usr/src/app/config.json:ro))))))))
        %base-services
        %pecus-base-services))))

;;; node-config.scm ends here
