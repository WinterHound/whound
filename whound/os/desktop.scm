(define-module (whound os desktop)
  #:use-module (gnu packages linux)
  #:use-module (gnu system nss)
  #:use-module (guix channels)
  #:use-module (guix inferior)
  #:use-module (srfi srfi-1)
  #:use-module (gnu))

(use-service-modules shepherd
                     sound
                     pm
                     xorg
                     virtualization
                     nix
                     base
                     desktop)

(use-package-modules pulseaudio
                     audio
                     gnome
                     freedesktop
                     file-systems
                     version-control
                     shells
                     display-managers
                     package-management
                     bootloaders
                     certs
                     wm
                     xdisorg
                     xorg)

;; ------------------------------------------------------------------------------------------
;; NIX 
;; nix-channel --add https://nixos.org/channels/nixpkgs-unstable
;; nix-channel --update
;; ln -s "/nix/var/nix/profiles/per-user/dust/profile" ~/.nix-profile
;; source /run/current-system/profile/etc/profile.d/nix.sh

;; ------------------------------------------------------------------------------------------
;; Configs
;; ------------------------------------------------------------------------------------------

(define-public %xorg-libinput-config
  "Section \"InputClass\"
  Identifier \"Touchpads\"
  Driver \"libinput\"
  MatchDevicePath \"/dev/input/event*\"
  MatchIsTouchpad \"on\"

  Option \"Tapping\" \"on\"
  Option \"TappingDrag\" \"on\"
  Option \"DisableWhileTyping\" \"on\"
  Option \"MiddleEmulation\" \"on\"
  Option \"ScrollMethod\" \"twofinger\"
EndSection

Section \"InputClass\"
  Identifier \"Keyboards\"
  Driver \"libinput\"
  MatchDevicePath \"/dev/input/event*\"
  MatchIsKeyboard \"on\"
EndSection")

(define-public %backlight-udev-rule
  (udev-rule "90-backlight.rules"
             (string-append "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
                            "RUN+=\"/run/current-system/profile/bin/chgrp video /sys/class/backlight/%k/brightness\""
                            "\n"
                            "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
                            "RUN+=\"/run/current-system/profile/bin/chmod g+w /sys/class/backlight/%k/brightness\"")))



;; ------------------------------------------------------------------------------------------
;; Services
;; ------------------------------------------------------------------------------------------

(define-public %whound-desktop-services
  (modify-services %desktop-services
    (elogind-service-type config =>
                          (elogind-configuration
                           (inherit config)
                           ;; Handle events
                           (handle-power-key 'suspend)
                           (handle-suspend-key 'suspend)
                           (handle-hibernate-key 'hibernate)
                           (handle-lid-switch 'suspend)
                           (handle-lid-switch-docked 'ignore)
                           ;; Allow programs to prevent actions
                           (power-key-ignore-inhibited? #f)
                           (suspend-key-ignore-inhibited? #f)
                           (hibernate-key-ignore-inhibited? #f)
                           (lid-switch-ignore-inhibited? #f)
                           ;; Do nothing if idle
                           (idle-action 'ignore)))
    (udev-service-type config =>
                       (udev-configuration
                        (inherit config)
                        (rules (cons %backlight-udev-rule
                                     (udev-configuration-rules config)))))
    (delete pulseaudio-service-type)
    (delete alsa-service-type)
    ))



(define-public %whound-mics-services
  (list
   (pam-limits-service ;; This enables JACK to enter realtime mode
    (list
     (pam-limits-entry "@audio" 'both 'rtprio 99)
     (pam-limits-entry "@audio" 'both 'memlock 'unlimited)))
   ;; (udev-rules-service
   ;; 'pipewire-add-udev-rules
   ;; pipewire)
   (set-xorg-configuration
    (xorg-configuration
     (extra-config (list %xorg-libinput-config))))
   ;; (service slim-service-type
   ;; (slim-configuration     
   ;; (theme "chili")
   ;; (numlock "off")))
   (service thermald-service-type)
   (service tlp-service-type
            (tlp-configuration
             ;; (cpu-boost-on-ac? #t)
             (wifi-pwr-on-bat? #t)))                         
   (service nix-service-type
            (nix-configuration
             (extra-config '("trusted-users = root dust"))))
   ;; (screen-locker-service xlockmore "xlock") ;; Already present in desktop-services
   (bluetooth-service #:bluez bluez #:auto-enable? #t)))

(define-public %whound-services
  (append
   %whound-mics-services   
   %whound-desktop-services))


;; ------------------------------------------------------------------------------------------
;; Users
;; ------------------------------------------------------------------------------------------

(define-public %whound-user-accounts
  (list
   (user-account
    (name "dust")
    (comment "-- dust pc --")
    (group "users")
    (supplementary-groups '("wheel"
                            "netdev"
                            "audio"
                            "video"
                            "lp"
                            "input")))))

;; ------------------------------------------------------------------------------------------
;; Packages
;; ------------------------------------------------------------------------------------------

(define-public %whound-packages
  (list
   ;; pipewire
   ;; wireplumber
   ;; wst
   ;; pulseaudio
   ;; jack-1
   ;; thermald
   ntfs-3g
   exfat-utils
   git
   udisks
   gvfs
   tlp
   ;; git:sendmail
   ;; pinentry
   ;; chili-sddm-theme
   bluez
   bluez-alsa
   ;; nix
   xf86-input-libinput
   bspwm
   sxhkd
   dash
   nss-certs
   ))

;; ------------------------------------------------------------------------------------------
;; Partitions
;; ------------------------------------------------------------------------------------------

(define-public %whound-partitions
  (list

   ;; System Partitions

   (file-system
     (device "/dev/sda1")
     ;; (device (uuid "F6F7-E750" 'fat))
     (mount-point "/boot/efi")
     (type "vfat"))
   (file-system
     (device (file-system-label "gRoot"))
     (mount-point "/")
     (type "ext4"))
   (file-system
     (device (file-system-label "gHome"))
     (mount-point "/home")
     (type "ext4"))
   (file-system
     (device (file-system-label "gPool"))
     (mount-point "/gnu")
     (type "ext4"))
   (file-system
     (device (file-system-label "gNix"))
     (mount-point "/nix")
     (type "ext4"))

   ;; My Partitions        
   
   (file-system
     (create-mount-point? #t)
     (device (file-system-label "Halo"))
     (mount-point "/parts/Halo")
     (type "btrfs"))
   (file-system
     (create-mount-point? #t)
     (device (file-system-label "dust_one"))
     (mount-point "/parts/dust_one")
     (type "ext4"))
   (file-system
     (create-mount-point? #t)
     (device (file-system-label "Carnage"))
     (mount-point "/parts/Carnage")
     (type "ext4"))
   (file-system
     (create-mount-point? #t)
     (device (file-system-label "Phobos"))
     (mount-point "/parts/Phobos")
     (type "ext4"))))


;; ------------------------------------------------------------------------------------------
;; Swap & Kernel Parameters
;; ------------------------------------------------------------------------------------------


(define-public %whound-swap-devices
  (list (swap-space
         (target (file-system-label "gSwap")))))

(define-public %whound-kernel-arguments
  (list "resume=/dev/sda4"))



;; ------------------------------------------------------------------------------------------
;; Free OS
;; ------------------------------------------------------------------------------------------


(define-public (free-os)
  (operating-system
    (host-name "dust")
    (timezone "Asia/Kolkata")
    (locale "en_US.utf8")
    (bootloader (bootloader-configuration
                 (bootloader grub-efi-bootloader)
                 (targets (list "/boot/efi"))))
    (kernel linux-libre)
    (kernel-arguments
     (append %default-kernel-arguments %whound-kernel-arguments))
    (file-systems
     (append %dust-partitions
             %base-file-systems))
    (swap-devices %whound-swap-devices)  
    (users (append
            %dust-user-accounts
            %base-user-accounts))
    (packages
     (append %dust-packages
             %base-packages))
    (services %dust-services)
    ;; Allow resolution of '.local' host names with mDNS.
    (name-service-switch %mdns-host-lookup-nss)))



;; ------------------------------------------------------------------------------------------
;; Non Free
;; ------------------------------------------------------------------------------------------

(define-public (non-free-os)
  (use-modules
   (nongnu packages linux)
   (nongnu system linux-initrd))
  (define %non-free-kernel
    (let*
        ((%guix-commit "b2f6b6f6b9df6bcc24794238e7e97357470af95d")
         (%nonguix-commit "4c0b9a86521a6d06c895b41e62c254da83feff7a")
         (%linux-version "5.10")
         (channels
          (list (channel
                 (name 'guix)
                 (url "https://git.savannah.gnu.org/git/guix.git")
                 (commit %guix-commit))
                (channel
                 (name 'nonguix)
                 (url "https://gitlab.com/nonguix/nonguix.git")
                 (commit %nonguix-commit))))
         (inferior
          (inferior-for-channels channels)))
      (first
       (lookup-inferior-packages inferior "linux" %linux-version))))

  (operating-system
    (inherit (free-os))
    (kernel %non-free-kernel)
    (firmware
     (cons* iwlwifi-firmware
            %base-firmware))
    (initrd microcode-initrd)))
