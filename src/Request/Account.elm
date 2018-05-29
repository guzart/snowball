module Request.Account exposing (list)

import Data.Account as Account exposing (Account)
import Data.AccessToken exposing (AccessToken, withAuthorization)
import Http
import HttpBuilder exposing (withExpect)
import Json.Decode as Decode


list : String -> Maybe AccessToken -> String -> Http.Request (List Account)
list apiUrl maybeToken budgetId =
    let
        expect =
            Http.expectJson (Decode.at [ "data", "accounts" ] (Decode.list Account.decoder))
    in
        apiUrl
            ++ ("/budgets/" ++ budgetId ++ "/accounts")
            |> HttpBuilder.get
            |> HttpBuilder.withExpect expect
            |> withAuthorization maybeToken
            |> HttpBuilder.toRequest
