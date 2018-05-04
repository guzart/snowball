module Data.Budget exposing (Budget, decoder)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)


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
