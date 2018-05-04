module Main exposing (Model, Msg, update, view, subscriptions, init)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Ports
import Views.Assets exposing (assets)
import Views.Modal as Modal


-- MODEL


type alias Model =
    { accessToken : Maybe Ports.AccessToken
    , isLoading : Bool
    , isRequesting : Bool
    , isDisclaimerOpen : Bool
    }


modelInitialValue : Model
modelInitialValue =
    { accessToken = Nothing
    , isLoading = True
    , isRequesting = False
    , isDisclaimerOpen = False
    }



-- UPDATE


type Msg
    = RequestAccessToken
    | UpdateAccessToken (Maybe Ports.AccessToken)
    | ToggleDisclaimer


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestAccessToken ->
            ( { model | isRequesting = True }, Ports.requestAccessToken () )

        UpdateAccessToken token ->
            case token of
                Nothing ->
                    ( { model | isLoading = False }, Cmd.none )

                Just _ ->
                    ( { model | accessToken = token, isLoading = False }, Cmd.none )

        ToggleDisclaimer ->
            ( { model | isDisclaimerOpen = not model.isDisclaimerOpen }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.updateAccessToken (\accessToken -> UpdateAccessToken accessToken)



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
    viewPage chooseBudgetContent model


chooseBudgetContent : Model -> Html Msg
chooseBudgetContent model =
    section []
        [ header []
            [ h1 [] [ text "Choose a Budget" ]
            ]
        ]


welcomePage : Model -> Html Msg
welcomePage model =
    viewPage welcomeContent model


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


viewPage : (Model -> Html Msg) -> Model -> Html Msg
viewPage content model =
    div [ class "container" ]
        [ content model
        , viewFooter model
        ]


viewFooter : Model -> Html Msg
viewFooter model =
    footer [ class "o-site-footer mt-4" ]
        [ ul [ class "nav justify-content-center" ]
            [ li [ class "nav-item" ] [ button [ class "nav-link btn btn-link", onClick ToggleDisclaimer ] [ text "Disclaimer" ] ]
            , li [ class "nav-item" ] [ button [ class "nav-link btn btn-link" ] [ text "Privacy Policy" ] ]
            , li [ class "nav-item" ] [ a [ class "nav-link", href "https://github.com/guzart/snowball" ] [ text "Source Code" ] ]
            ]
        , viewDisclaimerModal model.isDisclaimerOpen
        , Modal.viewBackdrop ToggleDisclaimer (showModalBackdrop model)
        ]


showModalBackdrop : Model -> Bool
showModalBackdrop model =
    model.isDisclaimerOpen


viewDisclaimerModal : Bool -> Html Msg
viewDisclaimerModal =
    Modal.view
        { closeMessage = ToggleDisclaimer
        , title = Just (h5 [] [ text "Disclaimer" ])
        , body = Just (text "Content")
        , footer = Nothing
        }



-- INIT


init : ( Model, Cmd Msg )
init =
    ( modelInitialValue, Ports.readAccessToken () )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
