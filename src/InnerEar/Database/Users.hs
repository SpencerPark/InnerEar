{-# LANGUAGE OverloadedStrings #-}

module InnerEar.Database.Users where

import Data.Char
import Data.Either
import Data.Maybe
import Control.Monad.Except
import Database.SQLite.Simple
import Database.SQLite.Simple.FromRow
import Database.SQLite.Simple.ToRow
import Database.SQLite.Simple.FromField
import Database.SQLite.Simple.ToField
import Database.SQLite.Simple.Ok

import InnerEar.Types.Handle
import InnerEar.Types.Password
import InnerEar.Types.User

-- definitions pertaining to users and their permissions

createUsersTable :: Connection -> IO ()
createUsersTable c =
  execute_ c "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, handle TEXT, password TEXT, role TEXT)"

instance FromField Role where
  fromField f | fieldData f == SQLText "NormalUser" = Ok NormalUser
  fromField f | fieldData f == SQLText "Manager" = Ok Manager
  fromField f | fieldData f == SQLText "Administrator" = Ok Administrator
      -- Field -> Ok Role

instance ToField Role where
  toField NormalUser = SQLText "NormalUser"
  toField Manager = SQLText "Manager"
  toField Administrator = SQLText "Administrator"

instance FromRow User where
  fromRow = User <$> field <*> field <*> field

instance ToRow User where
  toRow (User h pwd cmu) = toRow (fmap toLower h,pwd,cmu)

addUser :: Connection -> User -> ExceptT String IO Handle
addUser c u = do
  let h = fmap toLower (handle u)
  u' <- liftIO $ findUser c h
  if isNothing u' then do
    let u'' = u { handle = h }
    liftIO $ execute c "INSERT INTO users (handle,password,role) VALUES (?,?,?)" u''
    return $ handle u''
  else throwError $ "user handle " ++ h ++ " already exists"

findUser :: Connection -> Handle -> IO (Maybe User)
findUser conn h = do
  r <- query conn "SELECT handle,password,role FROM users WHERE handle = ?" (Only (fmap toLower h))
  return $ f r
  where
    f [] = Nothing
    f (x:_) = Just x

userExists :: Connection -> Handle -> IO Bool
userExists db h = maybe False (const True) <$> findUser db h

getPassword :: Connection -> Handle -> IO (Maybe String)
getPassword db h = fmap password <$> findUser db h

findAllUsers :: Connection -> IO [User]
findAllUsers c = query_ c "SELECT handle,password,role FROM users"
