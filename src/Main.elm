port module Main exposing (Model, Msg, update, view, subscriptions, init)

import Html exposing (..)


-- PORTS


port checkAccessToken : () -> Cmd msg


port receiveAccessToken : (Maybe String -> msg) -> Sub msg



-- MODEL


type alias Model =
    { accessToken : Maybe String
    }


modelInitialValue : Model
modelInitialValue =
    { accessToken = Nothing }



-- UPDATE


type Msg
    = CheckAccessToken
    | RequestAccessToken
    | UpdateAccessToken


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CheckAccessToken ->
            ( model, Cmd.none )

        RequestAccessToken ->
            ( model, Cmd.none )

        UpdateAccessToken ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.accessToken of
        Nothing ->
            div []
                [ text "Request token" ]

        Just token ->
            div []
                [ text "New Html Program" ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- INIT


init : ( Model, Cmd Msg )
init =
    ( modelInitialValue, Cmd.none )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
