module Handler.HostFormSpec (spec) where

import TestImport

spec :: Spec
spec = withApp $ do
    describe "get guest form page" $ do
        it "loads the guest form page and checks that it contains a form" $ do
            get HostFormR
            statusIs 200
            htmlAnyContain "form" "Lähetä"

    -- describe "postHostFormR" $ do
    --     error "Spec not implemented: postHostFormR"

