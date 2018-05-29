module Data.Budget exposing (Budget, decoder, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)
import Json.Encode.Extra as EncodeExtra
import Util exposing ((=>))


type alias Budget =
    { id : String
    , name : String
    , lastModifiedOn : Maybe String
    }



-- SERIALIZATION --


decoder : Decoder Budget
decoder =
    decode Budget
        |> required "id" Decode.string
        |> required "name" Decode.string
        |> required "last_modified_on" (Decode.nullable Decode.string)


encode : Budget -> Value
encode budget =
    Encode.object
        [ "id" => Encode.string budget.id
        , "name" => Encode.string budget.name
        , "last_modified_on" => EncodeExtra.maybe Encode.string budget.lastModifiedOn
        ]
