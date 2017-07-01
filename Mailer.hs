module Mailer (sendmail) where

import Import
import Network.HaskellNet.SMTP.SSL as SMTP
import Network.HaskellNet.Auth (AuthType(LOGIN))
import Data.Text.Internal.Lazy

sendmail :: App -> String -> String -> Data.Text.Internal.Lazy.Text -> IO ()
sendmail app recipient subject body = doSMTPSTARTTLSWithSettings mailserver smtpsettings $ \c -> do
    authSucceed <- SMTP.authenticate LOGIN username password c
    if authSucceed
      then sendPlainTextMail recipient username subject body c
      else print "Auth error"
   where smtpsettings = defaultSettingsSMTPSTARTTLS { sslPort = sslport, sslLogToConsole = True}
         s = appSettings app
         username = emailUsername $ appEmailConf s
         password = emailPassword $ appEmailConf s
         mailserver = emailServer $ appEmailConf s
         sslport =    fromInteger $ emailPort $ appEmailConf s
