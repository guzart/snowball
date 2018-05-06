module Request.Budget exposing (list)

import Data.AccessToken exposing (AccessToken, withAuthorization)
import Data.Budget as Budget exposing (Budget)
import Http
import HttpBuilder exposing (RequestBuilder, withBody, withExpect, withQueryParams)
import Json.Decode as Decode


-- SINGLE --
-- LIST --


list : String -> Maybe AccessToken -> Http.Request (List Budget)
list apiUrl maybeToken =
    let
        expect =
            Http.expectJson (Decode.at [ "data", "budgets" ] (Decode.list Budget.decoder))
    in
        apiUrl
            ++ "/budgets/"
            |> HttpBuilder.get
            |> HttpBuilder.withExpect expect
            |> withAuthorization maybeToken
            |> HttpBuilder.toRequest
