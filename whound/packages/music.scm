(define-module (whound packages music)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages algebra)
  #:use-module (gnu packages glib)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages)
  #:use-module (guix build utils)
  #:use-module (guix build-system cmake)
  #:use-module (guix build-system haskell)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (ice-9 match)
  #:use-module (ice-9 regex)
  #:use-module (srfi srfi-1)
  )


(define-public sc3-plugins
  (package
    (name "sc3-plugins")
    (version "3.11.1")
    (source
     (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/supercollider/sc3-plugins")
             (commit (string-append "Version-" version))
             (recursive? #t)
             ))
       (file-name (git-file-name name version))
       (sha256
        (base32 "1cy7g2mvmikml4dg6v4fzw6qr2yv9c94531iwxp501fr9j6z5jh8"))))
    (build-system cmake-build-system)
    (arguments
     (list
      #:tests? #f
      #:configure-flags
      #~(list
         (string-append "-DSC_PATH=" #$supercollider "/include/SuperCollider")
         "-DQUARKS=ON"
         "-DSUPERNOVA=ON"
         "-DCMAKE_BUILD_TYPE=Release"
         )
      ;; I dont think this is necessary. I currently created a softlink from system
      ;; to user Externsions dir. 
      #:phases 
      '(modify-phases %standard-phases
         (add-after 'install 'move-to-extensions
           (lambda* (#:key outputs #:allow-other-keys)
             (let ((out (assoc-ref outputs "out"))
                   (sc3 (string-append (assoc-ref outputs "out") "/share/SuperCollider/SC3plugins"))
                   (extensions (string-append (assoc-ref outputs "out") "/share/SuperCollider/Extensions")))
               (mkdir-p extensions)
               (invoke "mv" sc3 extensions)))))))
    ;; Some may not need
    (native-inputs (list pkg-config))
    (inputs (list fftw
                  fftwf
                  supercollider))
    (home-page #f)
    (synopsis #f)
    (description #f)
    (license #f)))
