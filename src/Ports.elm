port module Ports exposing (disconnect, onAccessTokenChange, readAccessToken, requestAccessToken)

import Json.Encode exposing (Value)


port disconnect : () -> Cmd msg


port readAccessToken : () -> Cmd msg


port requestAccessToken : () -> Cmd msg


port onAccessTokenChange : (Value -> msg) -> Sub msg
