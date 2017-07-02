{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Prelude     (IO)
import Import hiding (on, (==.), isNothing)
import Application (db)

import Database.Esqueleto

-- Test wether user and host are compatible
testPair :: Guesting -> Hosting -> Bool
testPair g h = and subCriteria
    where smokingOk = not (not (hostingAllowSmoking h) && (guestingSmokes g))
          subCriteria = [smokingOk]

getEntityUserName :: Entity User -> Text
getEntityUserName (Entity _ u) = userName u

availableHostings :: IO [(Entity User, Entity Hosting)]
availableHostings =
    db $
    select $
    from $ \(user `InnerJoin` hosting `LeftOuterJoin` pairing) -> do
    on (just (hosting ^. HostingId) ==. pairing ?. PairingsHosting)
    on (user ^. UserId ==. hosting ^. HostingUserId)
    where_ (isNothing $ pairing ?. PairingsHosting)
    return (user, hosting)

main :: IO ()
main = do
    hosts <- availableHostings
    let names = map (getEntityUserName . fst) hosts
    mapM_ print names
