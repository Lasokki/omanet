{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Prelude     (IO)
import Import hiding (on, (==.))
import Application (db)

import Database.Esqueleto

-- Test wether user and host are compatible
testPair :: Guesting -> Hosting -> Bool
testPair g h = and subCriteria
    where smokingOk = not (not (hostingAllowSmoking h) && (guestingSmokes g))
          subCriteria = [smokingOk]

getEntityUserName :: Entity User -> Text
getEntityUserName (Entity _ u) = userName u

availableHostingsQuery :: IO [(Entity User, Entity Hosting)]
availableHostingsQuery =
    db $
    select $
    from $ \(user `InnerJoin` hosting) -> do
    on $ user ^. UserId ==. hosting ^. HostingUserId
--    where_ (hosting ^. HostingGuesting ==. val Nothing)
    return  (user, hosting)

-- needyGuestsQuery =
--     db $
--     select $
--     from $ \(user `InnerJoin` guesting) -> do
--     on $ user ^. UserId ==. host ^. HostUserId
--     where_ (host ^. HostGuest ==. val Nothing)
--     return  (user, host)

main :: IO ()
main = do
    hostings <- availableHostingsQuery
    let names = map (getEntityUserName . fst) hostings
    mapM_ putStrLn names
    
