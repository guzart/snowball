port module Ports exposing (AccessToken, disconnect, readAccessToken, requestAccessToken, updateAccessToken)


port disconnect : () -> Cmd msg


port readAccessToken : () -> Cmd msg


port requestAccessToken : () -> Cmd msg


port updateAccessToken : (Maybe AccessToken -> msg) -> Sub msg


type alias AccessToken =
    String
