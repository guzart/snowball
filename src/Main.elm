port module Main exposing (Model, Msg, update, view, subscriptions, init)

import Html exposing (..)


-- PORTS


port checkAccessToken : () -> Cmd msg


port requestAccessToken : () -> Cmd msg


port updateAccessToken : (Maybe AccessToken -> msg) -> Sub msg



-- MODEL


type alias AccessToken =
    String


type alias Model =
    { accessToken : Maybe AccessToken
    , isLoading : Bool
    }


modelInitialValue : Model
modelInitialValue =
    { accessToken = Nothing
    , isLoading = True
    }



-- UPDATE


type Msg
    = CheckAccessToken
    | RequestAccessToken
    | UpdateAccessToken (Maybe AccessToken)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CheckAccessToken ->
            ( model, Cmd.none )

        RequestAccessToken ->
            ( model, Cmd.none )

        UpdateAccessToken token ->
            ( { model | accessToken = token, isLoading = False }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    if model.isLoading then
        div []
            [ text "Loading..." ]
    else
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
    updateAccessToken (\accessToken -> UpdateAccessToken accessToken)



-- COMMANDS
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
