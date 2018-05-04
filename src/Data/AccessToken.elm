module Data.AccessToken exposing (AccessToken(..), decoder, withAuthorization)

import HttpBuilder exposing (RequestBuilder, withHeader)
import Json.Decode as Decode exposing (Decoder)


type AccessToken
    = AccessToken String


decoder : Decoder AccessToken
decoder =
    Decode.map (\str -> AccessToken str) Decode.string


withAuthorization : Maybe AccessToken -> RequestBuilder a -> RequestBuilder a
withAuthorization maybeToken builder =
    case maybeToken of
        Just (AccessToken token) ->
            builder
                |> withHeader "authorization" ("Bearer " ++ token)

        Nothing ->
            builder
