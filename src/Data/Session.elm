module Data.Session exposing (Session, decoder, empty, encode, setBudget, setCategory, setToken, toggleAccount, updateDebtDetails)

import Data.AccessToken as AccessToken exposing (AccessToken(..))
import Data.Account as Account exposing (Account)
import Data.Budget as Budget exposing (Budget)
import Data.DebtDetail as DebtDetail exposing (DebtDetail)
import Data.Category as Category exposing (Category)
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
    , category : Maybe Category
    }


empty : Session
empty =
    { token = Nothing
    , budget = Nothing
    , accounts = Nothing
    , debtDetails = Nothing
    , category = Nothing
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
        , category = Nothing
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
                            (\a -> ( a.id, Maybe.withDefault (DebtDetail.init a.id) (Dict.get a.id debtDetails) ))
                        |> Dict.fromList
            in
                { session
                    | accounts = Just nextAccounts
                    , debtDetails = Just nextDebtDetails
                }


updateDebtDetails : Session -> Session
updateDebtDetails session =
    case session.accounts of
        Nothing ->
            { session | debtDetails = Nothing }

        Just accounts ->
            let
                newDebtDetails =
                    accounts
                        |> List.map (\a -> ( a.id, findOrInitDebtDetail session.debtDetails a ))
                        |> Dict.fromList
            in
                { session | debtDetails = Just newDebtDetails }


findOrInitDebtDetail : Maybe (Dict String DebtDetail) -> Account -> DebtDetail
findOrInitDebtDetail maybeDebtDetails account =
    case maybeDebtDetails of
        Nothing ->
            DebtDetail.init account.id

        Just debtDetails ->
            Maybe.withDefault (DebtDetail.init account.id) (Dict.get account.id debtDetails)


setCategory : Maybe Category -> Session -> Session
setCategory category session =
    { session | category = category }



-- SERIALIZATION --


decoder : Decoder Session
decoder =
    decode Session
        |> required "token" (Decode.maybe AccessToken.decoder)
        |> optional "budget" (Decode.maybe Budget.decoder) Nothing
        |> optional "accounts" (Decode.maybe (Decode.list Account.decoder)) Nothing
        |> optional "debtDetails" (Decode.maybe (Decode.dict DebtDetail.decoder)) Nothing
        |> optional "category" (Decode.maybe Category.decoder) Nothing


encode : Session -> Value
encode session =
    Encode.object
        [ "token" => EncodeExtra.maybe AccessToken.encode session.token
        , "budget" => EncodeExtra.maybe Budget.encode session.budget
        , "accounts" => EncodeExtra.maybe (\accounts -> Encode.list (List.map Account.encode accounts)) session.accounts
        , "debtDetails" => EncodeExtra.maybe (\debtDetails -> Encode.object (List.map (Tuple.mapSecond DebtDetail.encode) (Dict.toList debtDetails))) session.debtDetails
        , "category" => EncodeExtra.maybe Category.encode session.category
        ]



-- attempt : String -> (AccessToken -> Cmd msg) -> Session -> ( List String, Cmd msg )
-- attempt attemptedAction toCmd session =
--     case session.token of
--         Nothing ->
--             [ "You have been signed out. Please sign back in to " ++ attemptedAction ++ "." ] => Cmd.none
--         Just token ->
--             [] => toCmd token
