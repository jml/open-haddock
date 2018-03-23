{-| Command-line tool to open local haddock documentation.

$ open-haddock Data.Text
$ open-haddock text
-}

module Main (main) where

import BasicPrelude hiding (FilePath, empty, (</>), (<.>))
import qualified Control.Applicative as A
import qualified Data.Text as Text
import System.Info (os)
import Turtle


data Config = Config
  { openInBrowser :: Bool
  , userPackage :: Text
  }


commandLine :: Parser Config
commandLine =
  Config <$> (not <$> switch "dry-run" 'n' "Don't open browser, just print location")
         <*> argText "MODULE" "Package or module that you want to read the documentation for"


getHaddockPath :: Alternative m => Text -> Shell (m FilePath)
getHaddockPath package = do
  (code, result) <- procStrict "ghc-pkg" ["field", "--simple-output", package, "haddock-html"] empty
  case code of
    ExitSuccess -> return . pure . fromText . Text.strip $ result
    ExitFailure 1 -> return A.empty
    ExitFailure n -> do
      mapM_ err $ textToLines $ "ghc-pkg failed unexpectedly: " <> Text.pack (show n)
      exit (ExitFailure n)


getPackageName :: Alternative m => Text -> Shell (m Text)
getPackageName moduleName = do
  (_code, result) <- procStrict "ghc-pkg" ["find-module", "--simple-output", moduleName] empty
  return $ case result of
    "" -> A.empty
    path -> pure . Text.strip $ path


dwimPath :: Alternative m => Text -> Shell (m FilePath)
dwimPath packageOrModule = do
  packageName <- getPackageName packageOrModule
  case packageName of
    Just package ->
      fmap (flip haddockModule packageOrModule) <$> getHaddockPath package
    Nothing -> do
      fmap haddockRoot <$> getHaddockPath packageOrModule


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
  config <- options "Open haddock documentation in the browser" commandLine
  let packageOrModule = userPackage config
  sh $ do
    path <- dwimPath packageOrModule
    case path of
      Just path' ->
        if openInBrowser config
        then openFile path'
        else do
          mapM_ echo $ textToLines $ format fp path'
          exit ExitSuccess
      Nothing -> do
        mapM_ err $ textToLines $ "Could not find documentation for " <> packageOrModule
        exit (ExitFailure 1)
