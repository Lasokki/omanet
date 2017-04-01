module Handler.HostFormSpec (spec) where

import TestImport

spec :: Spec
spec = withApp $ do
    describe "get host form page" $ do
        it "loads the host form page and checks that it contains a form" $ do
            get HostFormR
            statusIs 200
            htmlAnyContain "form" "Lähetä"

    -- describe "postHostFormR" $ do
    --     error "Spec not implemented: postHostFormR"

