module Data.Account exposing (Account, decoder, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)
import Util exposing ((=>))


type alias Account =
    { id : String
    }



-- SERIALIZATION --


decoder : Decoder Account
decoder =
    decode Account
        |> required "id" Decode.string


encode : Account -> Value
encode account =
    Encode.object
        [ "id" => Encode.string account.id
        ]
