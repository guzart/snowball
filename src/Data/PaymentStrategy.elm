module Data.PaymentStrategy exposing (PaymentStrategy, initHighestBalanceFirst, initHighInterestFirst, initLowestBalanceFirst, initLowestInterestFirst)

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
    , totalInterest : Int
    , totalMonths : Int
    , payments : List Payment
    }


type alias Payment =
    { amount : Int
    , principal : Int
    , interest : Int
    , balance : Int
    }


initHighestBalanceFirst : List DebtDetail -> Int -> PaymentStrategy
initHighestBalanceFirst debtDetails monthlyAmount =
    let
        sortedDetails =
            debtDetails
                |> List.sortBy .balance
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
                , balance = dd.balance
                , rate = dd.rate
                , minPayment = dd.minPayment
                , totalInterest = 0
                , totalMonths = 0
                , payments = []
                }
            )



-- Schedule
-- {
-- , accountId : String
-- , rate : Float
-- , minPayment : Float
-- , totalInterest : Float
-- , months : Int
-- , balance : Int
--     payments: [
--         amount: 0, # How much was paid
--         principal: 0, # How much went to principal
--         interest: 0, # How much was interest
--         balance: 0, # Whats the remaining balance
--     ]
-- }


generateSchedules : Int -> List Schedule -> Int -> List Schedule
generateSchedules monthlyAmount schedules count =
    let
        maybeNextScheduleForExtra =
            schedules
                |> List.filter (\s -> s.balance < 0)
                |> List.head
    in
        case maybeNextScheduleForExtra of
            Nothing ->
                schedules

            Just nextScheduleForExtra ->
                if count > 420 then
                    schedules
                else
                    let
                        minPayments =
                            schedules
                                |> List.map (\s -> min (abs s.balance) s.minPayment)
                                |> List.sum

                        -- Extra after payin minimums
                        extra =
                            monthlyAmount - minPayments

                        newDebtSchedules =
                            schedules
                                |> List.map
                                    (\s ->
                                        let
                                            minPayment =
                                                min (abs s.balance) s.minPayment

                                            extraPayment =
                                                if s.accountId == nextScheduleForExtra.accountId then
                                                    extra
                                                else
                                                    0

                                            paymentAmount =
                                                (minPayment + extraPayment)
                                        in
                                            if paymentAmount > 0 then
                                                applyPaymentToSchedule paymentAmount s
                                            else
                                                s
                                    )
                    in
                        generateSchedules monthlyAmount newDebtSchedules (count + 1)


applyPaymentToSchedule : Int -> Schedule -> Schedule
applyPaymentToSchedule amount schedule =
    let
        periodRate =
            round (schedule.rate * 1000 / 12)

        interest =
            round (toFloat ((abs schedule.balance) * periodRate) / 100000)

        payment =
            { amount = amount
            , principal = amount + interest
            , interest = interest
            , balance = min 0 (schedule.balance + amount)
            }
    in
        { schedule
            | balance = payment.balance
            , totalInterest = schedule.totalInterest + payment.interest
            , totalMonths = schedule.totalMonths + 1
            , payments = List.append schedule.payments [ payment ]
        }
