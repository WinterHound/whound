(define-module (whound packages haskell)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu artwork)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system haskell)
  #:use-module (gnu packages admin)
  #:use-module (gnu packages aidc)
  #:use-module (gnu packages aspell)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages audio)
  #:use-module (gnu packages haskell-apps)
  #:use-module (gnu packages haskell-check)
  #:use-module (gnu packages haskell-crypto)
  #:use-module (gnu packages haskell-web)
  #:use-module (gnu packages haskell-xyz)
  )


(define-public ghc-data-binary-ieee754
  (package
    (name "ghc-data-binary-ieee754")
    (version "0.4.4")
    (source
     (origin
       (method url-fetch)
       (uri (hackage-uri "data-binary-ieee754" version))
       (sha256
        (base32 "02nzg1barhqhpf4x26mpzvk7jd29nali033qy01adjplv2z5m5sr"))))
    (build-system haskell-build-system)
    (home-page "https://john-millikin.com/software/data-binary-ieee754/")
    (synopsis "Parser/Serialiser for IEEE-754 floating-point values")
    (description "Convert Float and Decimal values to/from raw octets.")
    (license license:expat)))


(define-public ghc-hosc
  (package
    (name "ghc-hosc")
    (version "0.19.1")
    (source
     (origin
       (method url-fetch)
       (uri (hackage-uri "hosc" version))
       (sha256
        (base32 "08q218p1skqxwa7f55nsgmv9z8digf1c0f1wi6p562q6d4i044z7"))))
    (build-system haskell-build-system)
    (inputs (list ghc-blaze-builder
                  ghc-network
                  ghc-data-binary-ieee754))
    (home-page "http://rohandrape.net/?t=hosc")
    (synopsis "Haskell Open Sound Control")
    (description "hosc implements a subset of the Open Sound Control byte protocol")
    (license license:gpl3)))


(define-public ghc-microspec
  (package
    (name "ghc-microspec")
    (version "0.2.1.3")
    (source
     (origin
       (method url-fetch)
       (uri (hackage-uri "microspec" version))
       (sha256
        (base32 "0615gdbsk7i3w71adjp69zabw4mli965wffm2h846hp6pjj31xcb"))))
    (build-system haskell-build-system)
    (inputs (list ghc-quickcheck))
    (home-page "http://hackage.haskell.org/package/microspec")
    (synopsis "Tiny QuickCheck test library with minimal dependencies")
    (description
     "This package provides a tiny (1 module, <500 lines) property-based
(and unit) testing library with minimal dependencies.")
    (license license:bsd-3)))


(define-public ghc-hint
  (package
    (name "ghc-hint")
    (version "0.9.0.5")
    (source
     (origin
       (method url-fetch)
       (uri (hackage-uri "hint" version))
       (sha256
        (base32 "1qjasjbilvrfwk8lxfw0pa0hwpsr7nn0n9yd95lwjgfnqnigzcb8"))))
    (build-system haskell-build-system)
    (inputs (list ghc-paths ghc-random ghc-temporary))
    (native-inputs (list ghc-hunit))
    (home-page "https://github.com/haskell-hint/hint")
    (synopsis "Runtime Haskell interpreter (GHC API wrapper)")
    (description
     "This library defines an Interpreter monad.  It allows to load Haskell modules,
browse them, type-check and evaluate strings with Haskell expressions and even
coerce them into values.  The library is thread-safe and type-safe (even the
coercion of expressions to values).  It is, essentially, a huge subset of the
GHC API wrapped in a simpler API.")
    (license license:bsd-3)))


(define-public tidal
  (package
    (name "tidal")
    (version "1.7.10")
    (source
     (origin
       (method url-fetch)
       (uri (hackage-uri "tidal" version))
       (sha256
        (base32 "0vfymixr66sj6zsadkbcx0yx722f2d3q6cic4c91cswxssfqfrhc"))))
    (build-system haskell-build-system)
    (inputs
     (list ghc-colour
           ghc-hosc
           ghc-network
           ghc-bifunctors
           ghc-clock
           ghc-primitive
           ghc-random
           ghc-hint
           ghc-async))
    (native-inputs (list ghc-microspec))
    (home-page "http://tidalcycles.org/")
    (synopsis "Pattern language for improvised music")
    (description "Tidal is a domain specific language for live coding patterns.")
    (license license:gpl3)))


