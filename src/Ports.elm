port module Ports exposing (AccessToken, readAccessToken, requestAccessToken, updateAccessToken)


port readAccessToken : () -> Cmd msg


port requestAccessToken : () -> Cmd msg


port updateAccessToken : (Maybe AccessToken -> msg) -> Sub msg


type alias AccessToken =
    String
