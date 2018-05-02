port module Main exposing (Model, Msg, update, view, subscriptions, init)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Assets.Main exposing (assets)


-- PORTS


port readAccessToken : () -> Cmd msg


port requestAccessToken : () -> Cmd msg


port updateAccessToken : (Maybe AccessToken -> msg) -> Sub msg



-- MODEL


type alias Model =
    { accessToken : Maybe AccessToken
    , isLoading : Bool
    , isRequesting : Bool
    }


type alias AccessToken =
    String


modelInitialValue : Model
modelInitialValue =
    { accessToken = Nothing
    , isLoading = True
    , isRequesting = False
    }



-- UPDATE


type Msg
    = RequestAccessToken
    | UpdateAccessToken (Maybe AccessToken)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestAccessToken ->
            ( { model | isRequesting = True }, requestAccessToken () )

        UpdateAccessToken token ->
            case token of
                Nothing ->
                    ( { model | isLoading = False }, Cmd.none )

                Just _ ->
                    ( { model | accessToken = token, isLoading = False }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    updateAccessToken (\accessToken -> UpdateAccessToken accessToken)



-- COMMANDS
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
                    [ button [ disabled model.isRequesting, onClick RequestAccessToken ]
                        [ text
                            (if model.isRequesting then
                                "Connecting to YNAB..."
                             else
                                "Connect to YNAB"
                            )
                        ]
                    ]

            Just token ->
                div []
                    [ img [ src assets.logo ] []
                    , text "New Html Program"
                    ]



-- INIT


init : ( Model, Cmd Msg )
init =
    ( modelInitialValue, readAccessToken () )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
