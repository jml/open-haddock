{-| Command-line tool to open local haddock documentation.
-}

module Main (main) where

import BasicPrelude hiding (FilePath, empty, (</>))
import System.Info (os)
import Turtle


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


-- TODO:
-- * return non-zero exit code if package not found
-- * allow modules to be specified
--   * try to open actual module page
-- * what if haddock-html field not present?
-- * what if directory doesn't exist?
-- * DWIM
--   * look up the module first
--   * look up the package doc for the module
--   * look up the package

data Config = Config
  { userPackage :: Text
  }


commandLine :: Parser Config
commandLine = Config <$> argText "PACKAGE" "Package to read documentation for"


getHaddockPath :: Text -> Shell FilePath
getHaddockPath package = do
  fromText <$> inproc "ghc-pkg" ["field", "--simple-output", package, "haddock-html"] empty


haddockRoot :: FilePath -> FilePath
haddockRoot xs = xs </> "index.html"


openCommand :: Text
openCommand
  | os == "darwin"  = "open"
  | os == "mingw32" = "start"
  | otherwise       = "xdg-open"


openFile :: MonadIO m => FilePath -> m ExitCode
openFile path = proc openCommand [format fp path] empty


main :: IO ()
main = do
  config <- options "Documentation" commandLine
  sh $ do
    path <- getHaddockPath (userPackage config)
    echo $ format fp path
    openFile (haddockRoot path)
