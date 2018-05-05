module Data.AccessToken exposing (AccessToken(..), decoder, encode, withAuthorization)

import HttpBuilder exposing (RequestBuilder, withHeader)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)


type AccessToken
    = AccessToken String


decoder : Decoder AccessToken
decoder =
    Decode.map (\str -> AccessToken str) Decode.string


encode : AccessToken -> Value
encode (AccessToken token) =
    Encode.string token


withAuthorization : Maybe AccessToken -> RequestBuilder a -> RequestBuilder a
withAuthorization maybeToken builder =
    case maybeToken of
        Just (AccessToken token) ->
            builder
                |> withHeader "authorization" ("Bearer " ++ token)

        Nothing ->
            builder
