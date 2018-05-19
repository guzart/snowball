module Data.CategoryGroup exposing (CategoryGroup, decoder, encode)

import Data.Category as Category exposing (Category)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)
import Util exposing ((=>))


type alias CategoryGroup =
    { id : String
    , name : String
    , hidden : Bool
    , categories : List Category
    }



-- SERIALIZATION --


decoder : Decoder CategoryGroup
decoder =
    decode CategoryGroup
        |> required "id" Decode.string
        |> required "name" Decode.string
        |> required "hidden" Decode.bool
        |> required "categories" (Decode.list Category.decoder)


encode : CategoryGroup -> Value
encode categoryGroup =
    Encode.object
        [ "id" => Encode.string categoryGroup.id
        , "name" => Encode.string categoryGroup.name
        , "hidden" => Encode.bool categoryGroup.hidden
        , "categories" => Encode.list (List.map Category.encode categoryGroup.categories)
        ]
