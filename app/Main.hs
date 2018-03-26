module Main where

import Internal.Config (Config(..), readConfigFromDisk)
import Internal.Rep
import Import.Database

import Control.Monad (mapM_, (<=<))

main :: IO ()
main = do
    mConf <- readConfigFromDisk Nothing
    case mConf of
        Left e -> print $ show e
        Right conf -> do
            let sdb = [startDatabase conf]
            print conf
            print "\r"
            printAllForeignKeys sdb

printAllForeignKeys ::
    [Database]
    -> IO ()
printAllForeignKeys =
    mapM_ (print <=< searchDatabase)
