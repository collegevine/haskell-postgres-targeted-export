module Import.Database (
    searchDatabase
) where

import Internal.Rep
import Data.Text.Encoding as T
import Control.Exception (bracket)
import Control.Monad.Trans (liftIO)
import Control.Monad.Reader (ReaderT(..), ask)
import Database.PostgreSQL.Simple (connectPostgreSQL, close, Connection, query)
import Database.PostgreSQL.Simple.FromRow (FromRow(..), field)
import Database.PostgreSQL.Simple.FromField (FromField(..))

searchDatabase ::
    Database
    -> IO [FKey]
searchDatabase DB {connStr} =
    bracket (connectPostgreSQL $ T.encodeUtf8 connStr)
            close
            (runReaderT loadForeignKeys)


loadForeignKeys ::
    ReaderT Connection IO [FKey]
loadForeignKeys = do
    conn <- ask
    liftIO $ query conn selectFKeys ()
    where
        selectFKeys = "select                                                   \
               \ cl.relname as \"parent_table\",                                \
               \ att.attname as \"parent_column\",                              \
               \ att2.attname as \"child_column\",                              \
               \ ctbl as \"child_table\"                                        \
               \ from                                                           \
               \ (select                                                        \
               \         unnest(con1.conkey) as \"parent\",                     \
               \         unnest(con1.confkey) as \"child\",                     \
               \         cl.relname as \"ctbl\",                                \
               \         con1.confrelid,                                        \
               \         con1.conrelid,                                         \
               \         con1.conname                                           \
               \     from                                                       \
               \         pg_class cl                                            \
               \         join pg_namespace ns on cl.relnamespace = ns.oid       \
               \         join pg_constraint con1 on con1.conrelid = cl.oid      \
               \     where                                                      \
               \         ns.nspname = 'public'                                  \
               \         and con1.contype = 'f'                                 \
               \ ) con                                                          \
               \ join pg_attribute att on                                       \
               \     att.attrelid = con.confrelid and att.attnum = con.child    \
               \ join pg_class cl on                                            \
               \     cl.oid = con.confrelid                                     \
               \ join pg_attribute att2 on                                      \
               \     att2.attrelid = con.conrelid and att2.attnum = con.parent;"


instance FromField TblName where
    fromField f bs = TblName <$> fromField f bs
instance FromField ColName where
    fromField f bs = ColName <$> fromField f bs

instance FromRow FKey where
    fromRow = FKey <$> field <*> field <*> field <*> field
