port module Ports exposing (disconnect, readAccessToken, requestAccessToken, updateAccessToken)

import Json.Encode exposing (Value)


port disconnect : () -> Cmd msg


port readAccessToken : () -> Cmd msg


port requestAccessToken : () -> Cmd msg


port updateAccessToken : (Value -> msg) -> Sub msg
