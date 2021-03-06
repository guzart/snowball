module Data.PaymentStrategy exposing (PaymentStrategy, Payment, initHighestBalanceFirst, initHighInterestFirst, initLowestBalanceFirst, initLowestInterestFirst)

import Data.DebtDetail exposing (DebtDetail)


type alias PaymentStrategy =
    { name : String
    , months : Int
    , interest : Int
    , schedules : List Schedule
    }


type alias Schedule =
    { accountId : String
    , balance : Int
    , rate : Float
    , minPayment : Int
    , initialBalance : Int
    , totalInterest : Int
    , totalMonths : Int
    , payments : List Payment
    }


type alias Payment =
    { amount : Int
    , principal : Int
    , interest : Int
    , balance : Int
    , number : Int
    }


initHighestBalanceFirst : List DebtDetail -> Int -> PaymentStrategy
initHighestBalanceFirst debtDetails monthlyAmount =
    let
        sortedDetails =
            debtDetails
                |> List.sortBy (.balance >> abs)
                |> List.reverse
    in
        initPaymentStrategy "Highest Balance First" sortedDetails monthlyAmount


initHighInterestFirst : List DebtDetail -> Int -> PaymentStrategy
initHighInterestFirst debtDetails monthlyAmount =
    let
        sortedDetails =
            debtDetails
                |> List.sortBy .rate
                |> List.reverse
    in
        initPaymentStrategy "Highest Interest First" sortedDetails monthlyAmount


initLowestBalanceFirst : List DebtDetail -> Int -> PaymentStrategy
initLowestBalanceFirst debtDetails monthlyAmount =
    let
        sortedDetails =
            debtDetails
                |> List.sortBy .balance
                |> List.reverse
    in
        initPaymentStrategy "Lowest Balance First" sortedDetails monthlyAmount


initLowestInterestFirst : List DebtDetail -> Int -> PaymentStrategy
initLowestInterestFirst debtDetails monthlyAmount =
    let
        sortedDetails =
            debtDetails
                |> List.sortBy .rate
    in
        initPaymentStrategy "Lowest Interest First" sortedDetails monthlyAmount


initPaymentStrategy : String -> List DebtDetail -> Int -> PaymentStrategy
initPaymentStrategy name debtDetails monthlyAmount =
    let
        schedules =
            generateSchedules monthlyAmount (initSchedules debtDetails) 0
    in
        { name = name
        , months = List.maximum (List.map .totalMonths schedules) |> Maybe.withDefault 0
        , interest = List.maximum (List.map .totalInterest schedules) |> Maybe.withDefault 0
        , schedules = schedules
        }


initSchedules : List DebtDetail -> List Schedule
initSchedules debtDetails =
    debtDetails
        |> List.map
            (\dd ->
                { accountId = dd.accountId
                , balance = abs dd.balance
                , rate = dd.rate
                , minPayment = dd.minPayment
                , initialBalance = abs dd.balance
                , totalInterest = 0
                , totalMonths = 0
                , payments = []
                }
            )


generateSchedules : Int -> List Schedule -> Int -> List Schedule
generateSchedules monthlyAmount schedules count =
    if (List.isEmpty (List.filter (\s -> s.balance > 0) schedules)) || count > 420 then
        -- All debts are paid or it's been too long
        schedules
    else
        let
            minPayments =
                schedules
                    |> List.map (\s -> min s.balance s.minPayment)
                    |> List.sum

            -- Budget remaining after minimum payments
            extra =
                monthlyAmount - minPayments

            newSchedules =
                schedules
                    |> List.foldl
                        (\schedule ( outSchedules, remainingExtra ) ->
                            let
                                minPayment =
                                    min schedule.balance schedule.minPayment

                                extraPayment =
                                    -- If there's a balance after the min payment
                                    if schedule.balance > minPayment then
                                        -- Then the extra payment is either whatever there's left in the extra, or
                                        -- whatever balance is left
                                        min remainingExtra schedule.balance
                                    else
                                        0

                                paymentAmount =
                                    minPayment + extraPayment

                                newSchedule =
                                    if paymentAmount > 0 then
                                        applyPaymentToSchedule paymentAmount schedule
                                    else
                                        schedule

                                newRemainingExtra =
                                    remainingExtra - extraPayment
                            in
                                ( outSchedules ++ [ newSchedule ], newRemainingExtra )
                        )
                        ( [], extra )
                    |> Tuple.first
        in
            generateSchedules monthlyAmount newSchedules (count + 1)


applyPaymentToSchedule : Int -> Schedule -> Schedule
applyPaymentToSchedule amount schedule =
    let
        periodRate =
            schedule.rate / 100 / 12

        interest =
            (round ((toFloat schedule.balance) / 10 * periodRate))
                * 10

        payment =
            { amount = amount
            , principal = amount - interest
            , interest = interest
            , balance = max 0 (schedule.balance - amount + interest)
            , number = (List.length schedule.payments) + 1
            }
    in
        { schedule
            | balance = payment.balance
            , totalInterest = schedule.totalInterest + payment.interest
            , totalMonths = payment.number
            , payments = List.append schedule.payments [ payment ]
        }
