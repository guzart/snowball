module Data.DebtDetail exposing (DebtDetail, decoder, encode, init)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)
import Util exposing ((=>))


type alias DebtDetail =
    { accountId : String
    , balance : Int
    , rate : Int
    , minPayment : Int
    }


init : String -> Int -> DebtDetail
init accountId balance =
    { accountId = accountId
    , balance = balance
    , rate = 0
    , minPayment = 0
    }



-- SERIALIZATION --


decoder : Decoder DebtDetail
decoder =
    decode DebtDetail
        |> required "accountId" Decode.string
        |> required "balance" Decode.int
        |> required "rate" Decode.int
        |> required "minPayment" Decode.int


encode : DebtDetail -> Value
encode debtDetail =
    Encode.object
        [ "accountId" => Encode.string debtDetail.accountId
        , "balance" => Encode.int debtDetail.balance
        , "rate" => Encode.int debtDetail.rate
        , "minPayment" => Encode.int debtDetail.minPayment
        ]
