module Request.CategoryGroup exposing (list)

import Data.AccessToken exposing (AccessToken, withAuthorization)
import Data.CategoryGroup as CategoryGroup exposing (CategoryGroup)
import Http
import HttpBuilder exposing (withExpect)
import Json.Decode as Decode


-- SINGLE --
-- LIST --


list : String -> Maybe AccessToken -> String -> Http.Request (List CategoryGroup)
list apiUrl maybeToken budgetId =
    let
        expect =
            Http.expectJson (Decode.at [ "data", "category_groups" ] (Decode.list CategoryGroup.decoder))
    in
        apiUrl
            ++ ("/budgets/" ++ budgetId ++ "/categories")
            |> HttpBuilder.get
            |> HttpBuilder.withExpect expect
            |> withAuthorization maybeToken
            |> HttpBuilder.toRequest
