module Data.Category exposing (Category, decoder, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)
import Json.Encode.Extra as EncodeExtra
import Util exposing ((=>))


type alias Category =
    { id : String
    , categoryGroupId : String
    , name : String
    , hidden : Bool
    , note : Maybe String
    , budgeted : Int
    , activity : Int
    , balance : Int
    }



-- SERIALIZATION --


decoder : Decoder Category
decoder =
    decode Category
        |> required "id" Decode.string
        |> required "category_group_id" Decode.string
        |> required "name" Decode.string
        |> required "hidden" Decode.bool
        |> required "note" (Decode.nullable Decode.string)
        |> required "budgeted" Decode.int
        |> required "activity" Decode.int
        |> required "balance" Decode.int


encode : Category -> Value
encode category =
    Encode.object
        [ "id" => Encode.string category.id
        , "category_group_id" => Encode.string category.categoryGroupId
        , "name" => Encode.string category.name
        , "hidden" => Encode.bool category.hidden
        , "note" => EncodeExtra.maybe Encode.string category.note
        , "budgeted" => Encode.int category.budgeted
        , "activity" => Encode.int category.activity
        , "balance" => Encode.int category.balance
        ]
