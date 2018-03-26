module Main where

import Internal.Config (Config(..), readConfigFromDisk)

main :: IO ()
main = do
    conf <- readConfigFromDisk Nothing
    print conf
