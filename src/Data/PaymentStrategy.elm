module Data.PaymentStrategy exposing (PaymentStrategy, initHighInterestFirst)

import Data.DebtDetail exposing (DebtDetail)


type alias PaymentStrategy =
    { name : String
    }


initHighInterestFirst : List DebtDetail -> PaymentStrategy
initHighInterestFirst debtDetails =
    { name = "High Interest First"
    }
