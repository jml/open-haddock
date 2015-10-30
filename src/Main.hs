{-| Command-line tool to open local haddock documentation.
-}

module Main (main) where

import BasicPrelude hiding (FilePath, empty, (</>), (<.>))
import qualified Data.Text as Text
import System.Info (os)
import Turtle


-- TODO:
-- * return non-zero exit code if package not found
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


getPackageName :: Text -> Shell Text
getPackageName moduleName =
  inproc "ghc-pkg" ["find-module", "--simple-output", moduleName] empty


haddockRoot :: FilePath -> FilePath
haddockRoot rootDir = rootDir </> "index.html"


haddockModule :: FilePath -> Text -> FilePath
haddockModule rootDir moduleName =
  rootDir </> fromText (Text.replace "." "-" moduleName) <.> "html"


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
  let moduleName = userPackage config
  sh $ do
    package <- getPackageName moduleName
    path <- getHaddockPath package
    echo $ format fp path
    openFile (haddockModule path moduleName)
