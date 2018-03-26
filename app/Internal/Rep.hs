module Internal.Rep (
    DbName(..),
    Database(..),
    TblName(..),
    Table(..),
    FKey(..),
    Column(..),
    ColName(..),
    ColType(..),
    Result(..),
    ResultRows(..)
) where

import qualified Data.Text as T
import Data.Aeson (FromJSON, ToJSON)
import Data.Time.Clock (UTCTime)
import GHC.Generics (Generic)

data Database = DB {
    name :: DbName,
    connStr :: T.Text
    } deriving (Show, Generic, FromJSON, ToJSON)

newtype DbName = DbName T.Text
    deriving (Show, Eq, Ord, Generic, FromJSON, ToJSON)

newtype TblName = TblName T.Text
    deriving (Show, Eq, Ord, Generic, FromJSON, ToJSON)

newtype ColName = ColName T.Text
    deriving (Show, Eq, Ord, Generic, FromJSON, ToJSON)

data FKey = FKey {
    parentTable :: TblName,
    parentColumns :: ColName,
    childTable :: TblName,
    childColumns :: ColName
    } deriving (Show, Eq, Generic, FromJSON, ToJSON)

data Table = Table {
    name :: TblName,
    cols :: [Column]
    } deriving (Show, Eq, Generic, FromJSON, ToJSON)

data Column = Col {
    name :: ColName,
    colType :: ColType
    } deriving (Show, Eq, Generic, FromJSON, ToJSON)

data ColType
    = Txt
    | Int
    | Decimal
    | Timestamp
    | Bit
    deriving (Show, Eq, Generic, FromJSON, ToJSON)

data Result
    = TxtVal T.Text
    | IntVal Integer
    | DecimalVal Double
    | TsVal UTCTime
    | BitVal Bool
    deriving (Eq, Show, Generic, FromJSON, ToJSON)

data ResultRows = ResRows {
    columns :: [Column],
    results :: [[Result]],
    num :: Int
    } deriving (Show)


