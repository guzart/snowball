module Util exposing ((=>), milliDollarToFloat, toCurrency, toDuration, toMilliDollars)

import Regex


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


milliDollarToFloat : Int -> Float
milliDollarToFloat milliDollar =
    (toFloat milliDollar) / 1000.0


toCurrency : Int -> String
toCurrency amount =
    let
        cents =
            toString (rem (abs amount) 1000)

        centsFormatted =
            if (String.length cents) == 1 then
                "0" ++ cents
            else
                String.slice 0 2 cents

        dollarsFormatted =
            (toString (abs (amount // 1000)))
                |> String.reverse
                |> Regex.find Regex.All (Regex.regex "\\d\\d\\d|\\d\\d|\\d")
                |> List.reverse
                |> List.map (.match >> String.reverse)
                |> String.join ","

        negativeSymbol =
            if amount < 0 then
                "-"
            else
                ""
    in
        negativeSymbol ++ "$" ++ dollarsFormatted ++ "." ++ centsFormatted


toDuration : Int -> String
toDuration totalMonths =
    let
        years =
            totalMonths // 12

        months =
            totalMonths % 12
    in
        (toString years) ++ " years " ++ (toString months) ++ " months"


toMilliDollars : Float -> Int
toMilliDollars milliDollars =
    floor (milliDollars * 1000)
