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
                welcomePage model

            Just token ->
                chooseBudgetPage model


chooseBudgetPage : Model -> Html Msg
chooseBudgetPage model =
    sitePage (chooseBudgetContent model)


chooseBudgetContent : Model -> Html Msg
chooseBudgetContent model =
    section []
        [ header []
            [ h1 [] [ text "Choose a Budget" ]
            ]
        ]


welcomePage : Model -> Html Msg
welcomePage model =
    sitePage (welcomeContent model)


welcomeContent : Model -> Html Msg
welcomeContent model =
    section [ class "o-welcome-content" ]
        [ header [ class "text-center" ]
            [ h1 [ class "display-3" ]
                [ img [ src assets.logo ] []
                , text "Snowball"
                , em [ class "mx-2" ] [ text " for " ]
                , strong [] [ text "YNAB" ]
                ]
            , p [ class "lead" ] [ text "Debt payment strategies for your YNAB budget." ]
            ]
        , div [ class "text-center py-4" ]
            [ loaderButton "Connecting to YNAB..." "Connect to YNAB" model.isRequesting [ class "btn btn-primary btn-lg", onClick RequestAccessToken ]
            ]
        ]


loaderButton : String -> String -> Bool -> List (Html.Attribute msg) -> Html msg
loaderButton loadingLabel label isLoading attrs =
    button (List.concat [ attrs, [ disabled isLoading ] ])
        (if isLoading then
            [ span [ class "far fa-snowflake fa-spin" ] []
            , text (" " ++ loadingLabel)
            ]
         else
            [ text label ]
        )


sitePage : Html msg -> Html msg
sitePage content =
    div [ class "container" ]
        [ content
        , siteFooter
        ]


siteFooter : Html msg
siteFooter =
    footer [ class "o-site-footer mt-4" ]
        [ ul [ class "nav justify-content-center" ]
            [ li [ class "nav-item" ] [ button [ class "nav-link btn btn-link" ] [ text "Disclaimer" ] ]
            , li [ class "nav-item" ] [ button [ class "nav-link btn btn-link" ] [ text "Privacy Policy" ] ]
            , li [ class "nav-item" ] [ a [ class "nav-link", href "https://github.com/guzart/snowball" ] [ text "Source Code" ] ]
            ]
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
