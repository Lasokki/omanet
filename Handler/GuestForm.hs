module Handler.GuestForm where

import Import

data GuestFormData = GuestFormData {guestName :: Text, guestEmail :: Text, doesGuestSmoke :: Bool}
    deriving (Show)

guestForm :: Form GuestFormData
guestForm = renderBootstrap3 BootstrapBasicForm $ GuestFormData
    <$> areq textField (bfs ("Nimi" :: Text)) Nothing
    <*> areq emailField (bfs ("Sähköpostiosoite" :: Text)) Nothing
    <*> areq boolField smokingSettings Nothing
    where smokingSettings = (bfs ("Tupakoitko" :: Text, "LOLLERSKATES" :: Text))

getGuestFormR :: Handler Html
getGuestFormR = do
    (widget, enctype) <- generateFormPost guestForm
    defaultLayout $(widgetFile "guestForm")

storeGuest :: GuestFormData -> Handler Html
storeGuest formData = do
    userId <- runDB $ insert $ User (guestName formData) (guestEmail formData)
    let guest = Guesting userId (doesGuestSmoke formData)
    _ <- runDB $ insert $ guest
    defaultLayout [whamlet|<p>#{show guest}|]
        
postGuestFormR :: Handler Html
postGuestFormR = do
    ((result, _), _) <- runFormPost guestForm
    case result of
        FormSuccess formData -> storeGuest formData
        _ -> defaultLayout [whamlet|<p>oh noe|]
         
