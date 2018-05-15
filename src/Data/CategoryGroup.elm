module Data.CategoryGroup exposing (CategoryGroup, Category, decoder, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)
import Json.Encode.Extra as EncodeExtra
import Util exposing ((=>))


type alias CategoryGroup =
    { id : String
    , name : String
    , hidden : Bool
    , categories : List Category
    }


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


decoder : Decoder CategoryGroup
decoder =
    decode CategoryGroup
        |> required "id" Decode.string
        |> required "name" Decode.string
        |> required "hidden" Decode.bool
        |> required "categories" (Decode.list categoryDecoder)


categoryDecoder : Decoder Category
categoryDecoder =
    decode Category
        |> required "id" Decode.string
        |> required "categoryGroupId" Decode.string
        |> required "name" Decode.string
        |> required "hidden" Decode.bool
        |> required "note" (Decode.nullable Decode.string)
        |> required "budgeted" Decode.int
        |> required "activity" Decode.int
        |> required "balance" Decode.int


encode : CategoryGroup -> Value
encode categoryGroup =
    Encode.object
        [ "id" => Encode.string categoryGroup.id
        , "name" => Encode.string categoryGroup.name
        , "hidden" => Encode.bool categoryGroup.hidden
        , "categories" => Encode.list (List.map encodeCategory categoryGroup.categories)
        ]


encodeCategory : Category -> Value
encodeCategory category =
    Encode.object
        [ "id" => Encode.string category.id
        , "categoryGroupId" => Encode.string category.categoryGroupId
        , "name" => Encode.string category.name
        , "hidden" => Encode.bool category.hidden
        , "note" => EncodeExtra.maybe Encode.string category.note
        , "budgeted" => Encode.int category.budgeted
        , "activity" => Encode.int category.activity
        , "balance" => Encode.int category.balance
        ]
