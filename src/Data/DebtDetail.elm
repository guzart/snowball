module Data.DebtDetail exposing (DebtDetail, decoder, encode, init)

import Data.Account exposing (Account)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)
import Util exposing ((=>))


type alias DebtDetail =
    { accountId : String
    , rate : Int
    , minPayment : Int
    }


init : Account -> DebtDetail
init account =
    { accountId = account.id
    , rate = 0
    , minPayment = 0
    }



-- SERIALIZATION --


decoder : Decoder DebtDetail
decoder =
    decode DebtDetail
        |> required "accountId" Decode.string
        |> required "rate" Decode.int
        |> required "minPayment" Decode.int


encode : DebtDetail -> Value
encode debtDetail =
    Encode.object
        [ "accountId" => Encode.string debtDetail.accountId
        , "rate" => Encode.int debtDetail.rate
        , "minPayment" => Encode.int debtDetail.minPayment
        ]
