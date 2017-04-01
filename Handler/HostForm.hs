module Handler.HostForm where

import Import

data HostFormData = HostFormData {hostName :: Text, hostEmail :: Text, allowsSmoking :: Bool}

hostForm :: Form HostFormData
hostForm = renderDivs $ HostFormData
    <$> areq textField "Nimi" Nothing
    <*> areq emailField "Sähköpostiosoite" Nothing
    <*> areq boolField "Saako taloudessasi polttaa" Nothing

getHostFormR :: Handler Html
getHostFormR = do
    (widget, enctype) <- generateFormPost hostForm
    defaultLayout $(widgetFile "hostForm")

storeHost :: HostFormData -> Handler Html
storeHost formData = do
    userId <- runDB $ insert $ User (hostName formData) (hostEmail formData)
    let host = Host userId (allowsSmoking formData)
    _ <- runDB $ insert $ host
    defaultLayout [whamlet|<p>#{show host}|]

postHostFormR :: Handler Html
postHostFormR = do
    ((result, _), _) <- runFormPost hostForm
    case result of
        FormSuccess formData -> storeHost formData
        _ -> defaultLayout [whamlet|<p>oh noe|]
