{ mkDerivation, base, basic-prelude, stdenv, text, turtle }:
mkDerivation {
  pname = "open-haddock";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  buildDepends = [ base basic-prelude text turtle ];
  description = "Open haddock HTML documentation";
  license = stdenv.lib.licenses.gpl3;
}
