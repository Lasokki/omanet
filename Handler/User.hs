module Handler.User where

import Import

userForm :: Form User
userForm = renderBootstrap3 BootstrapBasicForm $ User
    <$> areq textField "Nimi" Nothing
    <*> areq emailField "Sähköpostiosoite" Nothing

getUserR :: Handler Html
getUserR = do
    -- Generate the form to be displayed
    (widget, enctype) <- generateFormPost userForm
    defaultLayout $(widgetFile "user")

postUserR :: Handler Html
postUserR = do
    ((result, widget), enctype) <- runFormPost userForm
    case result of
        FormSuccess user -> do
            _ <- runDB $ insert user
            defaultLayout [whamlet|<p>Syöttö onnistui!<p>#{show user}|]
        _ -> defaultLayout
            [whamlet|
                <p>Invalid input, let's try again.
                <form method=post action=@{UserR} enctype=#{enctype}>
                    ^{widget}
                    <button>Submit
            |]
