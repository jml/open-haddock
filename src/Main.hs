{-| Command-line tool to open local haddock documentation.
-}

module Main (main) where

import BasicPrelude hiding (FilePath, empty, (</>), (<.>))
import qualified Control.Applicative as A
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


getHaddockPath :: Alternative m => Text -> Shell (m FilePath)
getHaddockPath package = do
  (code, result) <- procStrict "ghc-pkg" ["field", "--simple-output", package, "haddock-html"] empty
  return $ case code of
    ExitSuccess -> pure . fromText . Text.strip $ result
    ExitFailure 1 -> A.empty
    ExitFailure n -> terror $ "ghc-pkg failed unexpectedly: " ++ show n


getPackageName :: Alternative m => Text -> Shell (m Text)
getPackageName moduleName = do
  (_code, result) <- procStrict "ghc-pkg" ["find-module", "--simple-output", moduleName] empty
  return $ case result of
    "" -> A.empty
    path -> pure . Text.strip $ path


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
    case package of
      Nothing -> do
        path <- getHaddockPath moduleName
        case path of
          Nothing -> terror "XXX: Real error handling: Could not find path or module"
          Just path' -> do
            echo $ format fp path'
            openFile (haddockRoot path')
      Just package' -> do
        path <- getHaddockPath package'
        case path of
          Nothing -> terror "XXX: Real error handling: Could not find path or module"
          Just path' -> openFile (haddockModule path' moduleName)
