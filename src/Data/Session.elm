module Data.Session exposing (Session, decoder, empty, encode, setToken)

import Data.AccessToken as AccessToken exposing (AccessToken(..))
import Data.Account as Account exposing (Account)
import Data.Budget as Budget exposing (Budget)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)
import Json.Encode.Extra as EncodeExtra
import Util exposing ((=>))


type alias Session =
    { token : Maybe AccessToken
    , budget : Maybe Budget
    , accounts : Maybe (List Account)
    }


empty : Session
empty =
    { token = Nothing
    , budget = Nothing
    , accounts = Nothing
    }


setToken : Maybe AccessToken -> Session -> Session
setToken token session =
    { session | token = token }



-- SERIALIZATION --


decoder : Decoder Session
decoder =
    decode Session
        |> required "token" (Decode.maybe AccessToken.decoder)
        |> required "budget" (Decode.maybe Budget.decoder)
        |> required "accounts" (Decode.maybe (Decode.list Account.decoder))


encode : Session -> Value
encode session =
    Encode.object
        [ "token" => EncodeExtra.maybe AccessToken.encode session.token
        , "budget" => EncodeExtra.maybe Budget.encode session.budget
        , "accounts" => EncodeExtra.maybe (\accounts -> Encode.list (List.map Account.encode accounts)) session.accounts
        ]



-- attempt : String -> (AccessToken -> Cmd msg) -> Session -> ( List String, Cmd msg )
-- attempt attemptedAction toCmd session =
--     case session.token of
--         Nothing ->
--             [ "You have been signed out. Please sign back in to " ++ attemptedAction ++ "." ] => Cmd.none
--         Just token ->
--             [] => toCmd token