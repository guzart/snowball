module Data.Session exposing (Session, decoder, empty, encode, minPaymentsTotal, setAmount, setBudget, setToken, toggleAccount, updateDebtDetails)

import Data.AccessToken as AccessToken exposing (AccessToken(..))
import Data.Account as Account exposing (Account)
import Data.Budget as Budget exposing (Budget)
import Data.DebtDetail as DebtDetail exposing (DebtDetail)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, optional, required)
import Json.Encode as Encode exposing (Value)
import Json.Encode.Extra as EncodeExtra
import Util exposing ((=>))


type alias Session =
    -- TODO: Use IDs instead of storing the full object
    { token : Maybe AccessToken
    , budget : Maybe Budget
    , accounts : Maybe (List Account)
    , debtDetails : Maybe (Dict String DebtDetail)
    , amount : Maybe Int
    }


empty : Session
empty =
    { token = Nothing
    , budget = Nothing
    , accounts = Nothing
    , debtDetails = Nothing
    , amount = Nothing
    }


setToken : Maybe AccessToken -> Session -> Session
setToken token session =
    { session | token = token }


setBudget : Maybe Budget -> Session -> Session
setBudget budget session =
    { session
        | budget = budget
        , accounts = Nothing
        , debtDetails = Nothing
        , amount = Nothing
    }


toggleAccount : Account -> Session -> Session
toggleAccount account session =
    case session.accounts of
        Nothing ->
            { session
                | accounts = Just [ account ]
                , debtDetails = Nothing
            }

        Just sessionAccounts ->
            let
                isSelected =
                    sessionAccounts
                        |> List.filter (\a -> a.id == account.id)
                        |> List.isEmpty
                        |> not

                nextAccounts =
                    if isSelected then
                        sessionAccounts |> List.filter (\a -> a.id /= account.id)
                    else
                        sessionAccounts ++ [ account ]

                debtDetails =
                    Maybe.withDefault Dict.empty session.debtDetails

                nextDebtDetails =
                    nextAccounts
                        |> List.map
                            (\a -> ( a.id, Maybe.withDefault (DebtDetail.init a.id a.balance) (Dict.get a.id debtDetails) ))
                        |> Dict.fromList
            in
                { session
                    | accounts = Just nextAccounts
                    , debtDetails = Just nextDebtDetails
                }


updateDebtDetails : Dict String DebtDetail -> Session -> Session
updateDebtDetails debtDetails session =
    { session | debtDetails = Just debtDetails }


findOrInitDebtDetail : Maybe (Dict String DebtDetail) -> Account -> DebtDetail
findOrInitDebtDetail maybeDebtDetails account =
    case maybeDebtDetails of
        Nothing ->
            DebtDetail.init account.id 0

        Just debtDetails ->
            Maybe.withDefault (DebtDetail.init account.id account.balance) (Dict.get account.id debtDetails)


setAmount : Maybe Int -> Session -> Session
setAmount amount session =
    { session | amount = amount }


minPaymentsTotal : Session -> Int
minPaymentsTotal session =
    case session.debtDetails of
        Nothing ->
            0

        Just debtDetails ->
            debtDetails
                |> Dict.values
                |> List.map .minPayment
                |> List.sum



-- SERIALIZATION --


decoder : Decoder Session
decoder =
    decode Session
        |> required "token" (Decode.maybe AccessToken.decoder)
        |> optional "budget" (Decode.maybe Budget.decoder) Nothing
        |> optional "accounts" (Decode.maybe (Decode.list Account.decoder)) Nothing
        |> optional "debtDetails" (Decode.maybe (Decode.dict DebtDetail.decoder)) Nothing
        |> optional "amount" (Decode.maybe Decode.int) Nothing


encode : Session -> Value
encode session =
    Encode.object
        [ "token" => EncodeExtra.maybe AccessToken.encode session.token
        , "budget" => EncodeExtra.maybe Budget.encode session.budget
        , "accounts" => EncodeExtra.maybe (\accounts -> Encode.list (List.map Account.encode accounts)) session.accounts
        , "debtDetails" => EncodeExtra.maybe (\debtDetails -> Encode.object (List.map (Tuple.mapSecond DebtDetail.encode) (Dict.toList debtDetails))) session.debtDetails
        , "amount" => EncodeExtra.maybe Encode.int session.amount
        ]
