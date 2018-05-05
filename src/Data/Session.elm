module Data.Session exposing (Session, decoder)

import Data.AccessToken as AccessToken exposing (AccessToken(..))
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)


type alias Session =
    { apiUrl : String
    , token : Maybe AccessToken
    }



-- SERIALIZATION --


decoder : Decoder Session
decoder =
    decode Session
        |> required "apiUrl" Decode.string
        |> required "token" (Decode.maybe AccessToken.decoder)



-- attempt : String -> (AccessToken -> Cmd msg) -> Session -> ( List String, Cmd msg )
-- attempt attemptedAction toCmd session =
--     case session.token of
--         Nothing ->
--             [ "You have been signed out. Please sign back in to " ++ attemptedAction ++ "." ] => Cmd.none
--         Just token ->
--             [] => toCmd token
