module InnerEar.Types.Server where

import qualified Network.WebSockets as WS
import Data.Map
import Control.Concurrent.MVar
import Data.List ((\\))
import Data.Maybe (fromMaybe)

import InnerEar.Types.Handle
import InnerEar.Types.Password
import InnerEar.Types.User

type ConnectionIndex = Int

data Server = Server {
  connections :: Map ConnectionIndex (WS.Connection, Maybe Handle),
  users :: Map Handle User
}

newServer :: Server
newServer = Server { connections = empty, users = empty }

addConnection :: WS.Connection -> Server -> (ConnectionIndex,Server)
addConnection c s = (i,s { connections = newMap })
  where i = head ([0..] Data.List.\\ (keys (connections s)))
        newMap = insert i (c,Nothing) (connections s)

deleteConnection :: ConnectionIndex -> Server -> Server
deleteConnection i s = s { connections = delete i (connections s)}

userExists :: Handle -> Server -> Bool
userExists h s = member h (users s)

-- | adds a user with the specified handle and password to a server, only if that user doesn't exist already
createUser :: ConnectionIndex -> Handle -> Password -> Server -> Server
createUser i h p s = if (userExists h s) then s else s { connections = newConnections, users = newUsers }
  where
    newConnections = adjust (\(ws,_) -> (ws,Just h)) i (connections s)
    newUsers = insert h (newUser h p) (users s)

getPassword :: Handle -> Server -> Password
getPassword h s = password $ (users s) ! h

authenticateUser :: Handle -> Server -> Server
authenticateUser h s = if (userExists h s) then s { users = newUsers } else s
  where newUsers = adjust authenticate h (users s)

deauthenticateUser :: Handle -> Server -> Server
deauthenticateUser h s = if (userExists h s) then s { users = newUsers } else s
  where newUsers = adjust deauthenticate h (users s)

updateServer :: MVar Server -> (Server -> Server) -> IO (MVar Server)
updateServer s f = do
  s' <- takeMVar s
  putMVar s (f s')
  return s
