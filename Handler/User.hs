module Handler.User where

import Import

userForm :: Form User
userForm = renderDivs $ User
    <$> areq textField "Nimi" Nothing
    <*> areq emailField "Sähköpostiosoite" Nothing

getUserR :: Handler Html
getUserR = do
    -- Generate the form to be displayed
    (widget, enctype) <- generateFormPost userForm
    defaultLayout $(widgetFile "user")
