module Util exposing ((=>), toCurrency)

import Regex


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


toCurrency : Int -> String
toCurrency amount =
    let
        cents =
            toString (rem amount 1000)

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
