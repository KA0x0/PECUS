;; This "manifest" file can be passed to 'guix package -m' to reproduce
;; the content of your profile.  This is "symbolic": it only specifies
;; package names.  To reproduce the exact same profile, you also need to
;; capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

;;; Code:

(packages->manifest
      (list adb
            ascii
            binutils
            binwalk
            buildah
            clojure emacs-clojure-ts-mode
            diffoscope
            difftastic emacs-difftastic
            duckdb
            pecus-emacs-next
            pecus-emacs-jwt
            guile-emacs
            emacs-autocrypt
            emacs-bluetooth
            emacs-calfw
            emacs-cider
            emacs-citar emacs-citar-denote
            emacs-dape
            emacs-denote emacs-consult-denote emacs-denote-org emacs-denote-sequence
            emacs-dirvish
            emacs-disproject
            emacs-ednc
            emacs-ement
            emacs-emms opus-tools
            emacs-filechooser
            emacs-forge
            emacs-helpful
            emacs-inheritenv
            emacs-jarchive
            emacs-jinx
            emacs-jq-mode ;; for ob-jq.el
            emacs-ligature
            emacs-lpy
            emacs-magit
            emacs-mentor
            emacs-nerd-icons emacs-nerd-icons-completion emacs-nerd-icons-corfu emacs-nerd-icons-ibuffer
            emacs-nov
            emacs-org-caldav
            emacs-org-contacts
            emacs-org-vcard
            emacs-osm
            emacs-ox-pandoc
            emacs-polymode emacs-polymode-org
            emacs-tempel emacs-eglot-tempel
            emacs-verb
            emacs-x509-mode
            file
            flac
            flashrom
            font-google-noto-emoji
            font-iosevka-term-slab
            font-liberation
            font-wqy-zenhei
            freerdp
            gcc-toolchain
            gdb
            glibc
            gnuradio
            go
            gopls
            delve ;; go debugger
            graphviz emacs-graphviz-dot-mode
            grim
            guile-aws
            inkscape
            imagemagick
            iw
            java-eclipse-jdt-core
            libfaketime
            llvm
            clang
            lldb
            lua lua-language-server
            man-pages
            mariadb
            mit-krb5
            mpv ;; ffmpeg propagated by mpv
            mu emacs-consult-mu
            mysql
            nix
            openjdk
            openocd
            openssh
            openssl
            openvpn
            pandoc emacs-pandoc-mode
            patch
            patchelf
            php
            pinentry-emacs
            poke emacs-poke-mode
            pwntools
            python-angr
            python-debugpy
            python-ipython
            python-pycryptodomex
            python-requests
            python-scapy
            qemu
            rassumfrassum
            retroarch libretro-dolphin-emu libretro-mupen64plus-nx
            rizin
            rr
            rust
            rust-analyzer ;; rust-clippy
            sage emacs-sage-shell-mode
            samba
            scdoc
            sigrok-cli
            slurp
            socat
            sqlite
            squashfs-tools
            sshfs
            steam-client
            syncplay
            tiled
            tree-sitter-asm
            tree-sitter-c
            tree-sitter-cpp
            tree-sitter-clojure
            tree-sitter-csv
            tree-sitter-comment
            tree-sitter-dockerfile
            tree-sitter-gitcommit
            tree-sitter-go
            tree-sitter-gomod
            tree-sitter-graphql
            tree-sitter-haskell
            tree-sitter-javascript
            tree-sitter-lua
            tree-sitter-make
            tree-sitter-markdown
            tree-sitter-org
            tree-sitter-php
            tree-sitter-powershell
            tree-sitter-rust
            tree-sitter-sql
            tree-sitter-xml
            tree-sitter-zig
            unrar-free
            upx
            valkey
            wget
            wine64-staging
            wireguard-tools
            wireshark
            yt-dlp
            zbar
            zig
            zls))

;;; dev-phone-manifest.scm ends here
