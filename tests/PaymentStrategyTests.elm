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


highestBalanceFirstStrategy : Int -> PaymentStrategy
highestBalanceFirstStrategy balance =
    PaymentStrategy.initHighestBalanceFirst debtDetails balance


suite : Test
suite =
    describe "Data.PaymentStrategy module"
        [ describe "initHighestBalanceFirst"
            [ test "account with the highest balance account is the first" <|
                \_ ->
                    let
                        strategy =
                            highestBalanceFirstStrategy paymentBalance

                        accountId =
                            List.head strategy.schedules
                                |> Maybe.map .accountId
                                |> Maybe.withDefault ""
                    in
                        Expect.equal accountId "account_1"
            , test "first balance is paid in 88 months" <|
                \_ ->
                    let
                        strategy =
                            highestBalanceFirstStrategy paymentBalance

                        totalMonths =
                            List.head strategy.schedules
                                |> Maybe.map .totalMonths
                                |> Maybe.withDefault 0
                    in
                        Expect.equal totalMonths 88
            , test "first account balance after first payment is $6,707.23" <|
                \_ ->
                    let
                        strategy =
                            highestBalanceFirstStrategy paymentBalance

                        firstPaymentBalance =
                            List.head strategy.schedules
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
                        strategy =
                            highestBalanceFirstStrategy paymentBalance

                        firstPaymentAmount =
                            List.head strategy.schedules
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
                        strategy =
                            highestBalanceFirstStrategy paymentBalance

                        firstPaymentInterest =
                            List.head strategy.schedules
                                |> Maybe.map .payments
                                |> Maybe.withDefault []
                                |> List.head
                                |> Maybe.map .interest
                                |> Maybe.withDefault 0
                    in
                        Expect.equal firstPaymentInterest 84260
            , test "extra payment spills to next debt" <|
                \_ ->
                    let
                        strategy =
                            highestBalanceFirstStrategy 15520450

                        lastScheduleFirstPaymentBalance =
                            List.reverse strategy.schedules
                                |> List.head
                                |> Maybe.map .payments
                                |> Maybe.withDefault []
                                |> List.head
                                |> Maybe.map .balance
                                |> Maybe.withDefault 499
                    in
                        Expect.equal lastScheduleFirstPaymentBalance 0
            ]
        ]
