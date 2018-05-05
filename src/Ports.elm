port module Ports exposing (onAccessTokenChange, requestAccessToken, saveSession)

import Json.Encode exposing (Value)


port requestAccessToken : () -> Cmd msg


port saveSession : String -> Cmd msg


port onAccessTokenChange : (Value -> msg) -> Sub msg
