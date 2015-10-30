module Main (main) where

import BasicPrelude


-- 1. Get documentation for package:
--
-- $ ghc-pkg field --simple-output turtle haddock-html
-- /nix/store/n3rgkskgjdph4ykqi845z5ayspzqbfqr-turtle-1.2.2/share/doc/x86_64-osx-ghc-7.10.2/turtle-1.2.2/html

-- 2. Get documentation for module
--
-- $ ghc-pkg find-module --simple-output Turtle
-- turtle-1.2.2

-- 3. Open documentation
-- $ open $PATH/index.html
-- $ xdg-open $PATH/index.html


main :: IO ()
main = putStrLn "Hello world!"
