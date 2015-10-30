{ mkDerivation, base, basic-prelude, optparse-applicative_0_12_0_0, stdenv
, turtle
}:
mkDerivation {
  pname = "open-haddock";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  buildDepends = [ base basic-prelude optparse-applicative_0_12_0_0 turtle ];
  description = "Open haddock HTML documentation";
  license = stdenv.lib.licenses.gpl3;
}
