{-# LANGUAGE ScopedTypeVariables #-}

module Main where

import Prelude     (IO)
import Import hiding (on, (==.))
import Application (db)

import Database.Esqueleto

testPair :: Guest -> Host -> Bool
testPair g h = not (not (hostAllowSmoking h) && (guestSmokes g))

getEntityUserName :: Entity User -> Text
getEntityUserName (Entity _ u) = userName u

main :: IO ()
main = do
    hosts <- db $ select $ from $ \(user `InnerJoin` host) ->
        do on $ user ^. UserId ==. host ^. HostUserId
           return  (user, host)
    
    let names = map (getEntityUserName . fst) hosts
    mapM_ putStrLn names
    
