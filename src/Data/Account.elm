module Data.Account exposing (Account, decoder, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode exposing (Value)
import Json.Encode.Extra as EncodeExtra
import Util exposing ((=>))


type alias Account =
    { id : String
    , name : String
    , accountType : String
    , onBudget : Bool
    , closed : Bool
    , note : Maybe String
    , balance : Int
    , clearedBalance : Int
    , unclearedBalance : Int
    }


type AccountType
    = Checking
    | Savings
    | CreditCard
    | Cash
    | LineOfCredit
    | Paypal
    | MerchantAccount
    | InvestmentAccount
    | Mortgage
    | OtherAsset
    | OtherLiability



-- SERIALIZATION --


decoder : Decoder Account
decoder =
    decode Account
        |> required "id" Decode.string
        |> required "name" Decode.string
        |> required "type" Decode.string
        |> required "on_budget" Decode.bool
        |> required "closed" Decode.bool
        |> required "note" (Decode.maybe Decode.string)
        |> required "balance" Decode.int
        |> required "cleared_balance" Decode.int
        |> required "uncleared_balance" Decode.int


encode : Account -> Value
encode account =
    Encode.object
        [ "id" => Encode.string account.id
        , "name" => Encode.string account.name
        , "type" => Encode.string account.accountType
        , "on_budget" => Encode.bool account.onBudget
        , "closed" => Encode.bool account.closed
        , "note" => EncodeExtra.maybe Encode.string account.note
        , "balance" => Encode.int account.balance
        , "cleared_balance" => Encode.int account.clearedBalance
        , "uncleared_balance" => Encode.int account.unclearedBalance
        ]
