(define-module (whound packages suckless)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages cups)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages fontutils)
  #:use-module (gnu packages gawk)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages image)
  #:use-module (gnu packages libbsd)
  #:use-module (gnu packages linux)
  #:use-module (gnu packages mpd)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages xorg)
  #:use-module (guix build-system glib-or-gtk)
  #:use-module (guix build-system gnu)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix utils)
  #:use-module (guix packages))

(define-public wst
  (let ((commit "3740bd9719c5804b96266571d05450a6f7a42faf")
        (revision "1"))
    (package
      (name "wst")
      (version (git-version "0.8.4" revision commit))
      (source
       (origin
         (method git-fetch)
         (uri (git-reference
               (url "https://gitlab.com/winterhound/st")
               (commit commit)))
         (file-name (git-file-name name version))
         (sha256
          (base32 "1ddbnh5bq5771pgssw2qqm80r841ckdzzihigxi776kh1p17q6a2"))))
      (build-system gnu-build-system)
      (arguments
       `(#:tests? #f                      ; no tests
         #:make-flags
         (list (string-append "CC=" ,(cc-for-target))
               (string-append "PREFIX=" %output))
         #:phases
         (modify-phases %standard-phases
           (delete 'configure)
           (add-after 'unpack 'inhibit-terminfo-install
             (lambda _
               (substitute* "Makefile"
                 (("\ttic .*") ""))
               #t)))))
      (inputs
       `(("libx11" ,libx11)
         ("libxft" ,libxft)
         ("fontconfig" ,fontconfig)
         ("freetype" ,freetype)))
      (native-inputs
       `(("pkg-config" ,pkg-config)))
      (home-page "https://gitlab.com/winterhound")
      (synopsis "Winter Hound's forked Simple terminal emulator")
      (description
       "St implements a simple and lightweight terminal emulator.  It
 implements 256 colors, most VT10X escape sequences, utf8, X11 copy/paste,
 antialiased fonts (using fontconfig), fallback fonts, resizing, and line
 drawing.")
      (license license:x11))))
