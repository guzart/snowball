module PaymentStrategyTests exposing (..)

import Data.DebtDetail as DebtDetail exposing (DebtDetail)
import Data.PaymentStrategy as PaymentStrategy exposing (PaymentStrategy, Payment)
import Expect
import Test exposing (..)


paymentBalance : Int
paymentBalance =
    212960


debtDetails : List DebtDetail
debtDetails =
    [ { accountId = "account_1"
      , balance = -6749880
      , rate = 14.98
      , minPayment = 84320
      }
    , { accountId = "account_2"
      , balance = -4216370
      , rate = 10.63
      , minPayment = 42160
      }
    , { accountId = "account_3"
      , balance = -4388640
      , rate = 9.72
      , minPayment = 43890
      }
    ]


highestBalanceFirstStrategy : PaymentStrategy
highestBalanceFirstStrategy =
    PaymentStrategy.initHighestBalanceFirst debtDetails paymentBalance


suite : Test
suite =
    describe "Data.PaymentStrategy module"
        [ describe "initHighestBalanceFirst"
            [ test "account with the highest balance account is the first" <|
                \_ ->
                    let
                        accountId =
                            List.head highestBalanceFirstStrategy.schedules
                                |> Maybe.map .accountId
                                |> Maybe.withDefault ""
                    in
                        Expect.equal accountId "account_1"
            , test "first balance is paid in 88 months" <|
                \_ ->
                    let
                        totalMonths =
                            List.head highestBalanceFirstStrategy.schedules
                                |> Maybe.map .totalMonths
                                |> Maybe.withDefault 0
                    in
                        Expect.equal totalMonths 88
            , test "first account balance after first payment is $6,707.23" <|
                \_ ->
                    let
                        firstPaymentBalance =
                            List.head highestBalanceFirstStrategy.schedules
                                |> Maybe.map .payments
                                |> Maybe.withDefault []
                                |> List.head
                                |> Maybe.map .balance
                                |> Maybe.withDefault 0
                    in
                        Expect.equal firstPaymentBalance 6707230
            , test "first account first payment amount is $126.91" <|
                \_ ->
                    let
                        firstPaymentAmount =
                            List.head highestBalanceFirstStrategy.schedules
                                |> Maybe.map .payments
                                |> Maybe.withDefault []
                                |> List.head
                                |> Maybe.map .amount
                                |> Maybe.withDefault 0
                    in
                        Expect.equal firstPaymentAmount 126910
            , test "first account first payment interest is $84.26" <|
                \_ ->
                    let
                        firstPaymentInterest =
                            List.head highestBalanceFirstStrategy.schedules
                                |> Maybe.map .payments
                                |> Maybe.withDefault []
                                |> List.head
                                |> Maybe.map .interest
                                |> Maybe.withDefault 0
                    in
                        Expect.equal firstPaymentInterest 84260
            ]
        ]
