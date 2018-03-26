module Internal.Config (
    readConfigFromDisk,
    Config(..)
) where

import Internal.Rep

import qualified Data.Text as T
import Data.Aeson (FromJSON, ToJSON)
import Data.Maybe (fromMaybe)
import Data.Yaml (decodeFileEither, ParseException)
import GHC.Generics (Generic)

data Config = Config {
    startDatabase :: Database,
    databases :: [Database],
    startTable :: TblName,
    startColumn :: Column,
    startValues :: [Result],
    possibleIdColumns :: [ColName] -- ^ Cross database key columns to search in. Its assumed to be the same type as the startColumn
    } deriving (Show, Generic, FromJSON, ToJSON)

-- | Loads a list of target databases and the starting point for the
-- data extract. The "starting point" is a set of rows in a particular table that you'd like to search
-- for across the entire system
readConfigFromDisk ::
    Maybe T.Text -- ^ Full path to the export.yaml file
    -> IO (Either ParseException Config)
readConfigFromDisk perhapsPath =
    decodeFileEither . T.unpack $ fromMaybe "export.yaml" perhapsPath


