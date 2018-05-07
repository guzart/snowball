module Main exposing (Model, Msg, update, view, subscriptions, init)

import Data.AccessToken as AccessToken exposing (AccessToken(..), decoder)
import Data.Account exposing (Account)
import Data.Budget exposing (Budget)
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Encode as Encode
import Json.Decode as Decode exposing (Value)
import Ports
import Regex
import Request.Account as AccountRequest
import Request.Budget as BudgetRequest
import Views.Assets exposing (assets)
import Views.Footer as Footer


-- INIT


main : Program Value Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : Value -> ( Model, Cmd Msg )
init val =
    let
        maybeApiUrl =
            decodeApiUrlFromJson val

        session =
            decodeSessionFromJson val
    in
        case maybeApiUrl of
            Nothing ->
                ( { modelInitialValue | currentScreen = ErrorScreen }, Cmd.none )

            Just apiUrl ->
                let
                    ( newModel, newCmd ) =
                        loadScreenData
                            { modelInitialValue
                                | apiUrl = apiUrl
                                , session = session
                                , currentScreen = screenFromSession session
                            }
                in
                    ( newModel, Cmd.batch [ saveSession session, newCmd ] )


decodeApiUrlFromJson : Value -> Maybe String
decodeApiUrlFromJson json =
    json
        |> Decode.decodeValue Decode.string
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString (Decode.field "apiUrl" Decode.string) >> Result.toMaybe)


decodeSessionFromJson : Value -> Session
decodeSessionFromJson json =
    json
        |> Decode.decodeValue Decode.string
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString (Decode.field "session" Session.decoder) >> Result.toMaybe)
        |> Maybe.withDefault Session.empty



-- MODEL


type alias Model =
    { apiUrl : String
    , errorMessage : Maybe String
    , isRequestingAccessToken : Bool
    , isLoadingScreenData : Bool
    , currentScreen : Screen
    , session : Session
    , budgets : Maybe (List Budget)
    , accounts : Maybe (List Account)
    }


modelInitialValue : Model
modelInitialValue =
    { apiUrl = ""
    , errorMessage = Nothing
    , isRequestingAccessToken = False
    , isLoadingScreenData = False
    , currentScreen = WelcomeScreen
    , session = Session.empty
    , budgets = Nothing
    , accounts = Nothing
    }


type Screen
    = WelcomeScreen
    | ChooseBudgetScreen
    | ChooseAccountsScreen
    | DebtDetailsScreen
    | PaymentCategoryScreen
    | DebtStrategiesScreen
    | DebtStrategyScreen
    | ErrorScreen


screenFromSession : Session -> Screen
screenFromSession session =
    case session.token of
        Nothing ->
            WelcomeScreen

        Just _ ->
            case session.budget of
                Nothing ->
                    ChooseBudgetScreen

                Just _ ->
                    case session.accounts of
                        Nothing ->
                            ChooseAccountsScreen

                        Just _ ->
                            DebtDetailsScreen



-- UPDATE


type Msg
    = RequestAccessToken
    | UpdateAccessToken (Maybe AccessToken)
    | Disconnect
    | HandleBudgetsResponse (Result Http.Error (List Budget))
    | HandleAccountsResponse (Result Http.Error (List Account))
    | SelectBudget (Maybe Budget)
    | ToggleAccount Account
    | GoToChooseBudget
    | GoToChooseAccounts
    | GoToDebtDetails


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestAccessToken ->
            ( { model | isRequestingAccessToken = True }
            , Ports.requestAccessToken ()
            )

        -- Logic here and init is very similar. May be generalized
        UpdateAccessToken maybeToken ->
            let
                newSession =
                    model.session
                        |> Session.setToken maybeToken

                ( newModel, newCmd ) =
                    loadScreenData
                        { model
                            | session = newSession
                            , currentScreen = screenFromSession newSession
                        }
            in
                ( newModel, Cmd.batch [ saveSession newSession, newCmd ] )

        Disconnect ->
            let
                newSession =
                    model.session
                        |> Session.setToken Nothing
            in
                ( { model | session = newSession, currentScreen = WelcomeScreen }
                , saveSession newSession
                )

        HandleBudgetsResponse result ->
            case result of
                Ok budgets ->
                    ( { model
                        | budgets = Just budgets
                        , isLoadingScreenData = False
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model
                        | budgets = Nothing
                        , isLoadingScreenData = False
                        , errorMessage = defaultErrorMessage
                      }
                    , Cmd.none
                    )

        HandleAccountsResponse result ->
            case result of
                Ok accounts ->
                    ( { model
                        | accounts = Just accounts
                        , isLoadingScreenData = False
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model
                        | accounts = Nothing
                        , isLoadingScreenData = False
                        , errorMessage = defaultErrorMessage
                      }
                    , Cmd.none
                    )

        SelectBudget maybeBudget ->
            ( { model | session = model.session |> Session.setBudget maybeBudget }, Cmd.none )

        ToggleAccount account ->
            ( { model | session = model.session |> Session.toggleAccount account }, Cmd.none )

        GoToChooseBudget ->
            loadScreenData { model | currentScreen = ChooseBudgetScreen }

        GoToChooseAccounts ->
            let
                hasBudget =
                    model.session.budget /= Nothing

                nextScreen =
                    if hasBudget then
                        ChooseAccountsScreen
                    else
                        model.currentScreen

                ( newModel, newCmd ) =
                    loadScreenData { model | currentScreen = nextScreen }
            in
                ( newModel, Cmd.batch [ saveSession model.session, newCmd ] )

        GoToDebtDetails ->
            ( { model | currentScreen = DebtDetailsScreen }, Cmd.none )


saveSession : Session -> Cmd msg
saveSession session =
    session
        |> Session.encode
        |> Encode.encode 0
        |> Ports.saveSession


loadScreenData : Model -> ( Model, Cmd Msg )
loadScreenData model =
    case model.currentScreen of
        ChooseBudgetScreen ->
            ( { model | isLoadingScreenData = True }
            , BudgetRequest.list model.apiUrl model.session.token
                |> Http.send HandleBudgetsResponse
            )

        ChooseAccountsScreen ->
            case model.session.budget of
                Nothing ->
                    ( { model | errorMessage = Just "Something went wrong, we couldn't find your selected budget." }, Cmd.none )

                Just budget ->
                    ( { model | isLoadingScreenData = True }
                    , AccountRequest.list model.apiUrl model.session.token budget
                        |> Http.send HandleAccountsResponse
                    )

        _ ->
            ( model, Cmd.none )


defaultErrorMessage : Maybe String
defaultErrorMessage =
    Just "There was an unexpected error connecting to YNAB."



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Ports.onAccessTokenChange
        (Decode.decodeValue AccessToken.decoder
            >> Result.toMaybe
            >> UpdateAccessToken
        )



-- VIEW


view : Model -> Html Msg
view model =
    case model.currentScreen of
        WelcomeScreen ->
            viewWelcome model

        ChooseBudgetScreen ->
            viewChooseBudget model

        ChooseAccountsScreen ->
            viewChooseAccounts model

        DebtDetailsScreen ->
            viewDebtDetails model

        _ ->
            viewError model


viewDebtDetails : Model -> Html Msg
viewDebtDetails model =
    viewScreen viewDebtDetailsContent model


viewDebtDetailsContent : Model -> Html Msg
viewDebtDetailsContent model =
    let
        -- Is disabeld if form has error messages
        isNextDisabled =
            False

        accounts =
            Maybe.withDefault [] model.session.accounts
    in
        section [ class "o-debt-details" ]
            [ header [ class "text-center" ] [ h1 [] [ text "Debt Details" ] ]
            , section [ class "py-4" ]
                [ div [] (accounts |> List.map (viewDebtDetailCard model))
                , div [ class "d-flex mt-4" ]
                    [ button
                        [ class "btn btn-outline-dark mr-auto"
                        , onClick GoToChooseAccounts
                        ]
                        [ text "Back" ]
                    , button
                        [ class "btn"
                        , classList [ ( "btn-outline-primary", isNextDisabled ), ( "btn-primary", not isNextDisabled ) ]
                        , disabled isNextDisabled
                        ]
                        [ text "Next Step" ]
                    ]
                ]
            ]


viewDebtDetailCard : Model -> Account -> Html Msg
viewDebtDetailCard model account =
    div [ class "card shadow-sm my-3" ]
        [ div [ class "card-body" ]
            [ div [ class "card-title d-flex" ]
                [ div
                    [ class "mr-auto" ]
                    [ h5 [ class "my-0" ] [ text account.name ]
                    , small [ class "text-muted text-uppercase" ] [ text account.accountType ]
                    ]
                , div [ class "font-weight-bold" ] [ text (toCurrency account.balance) ]
                ]
            , div []
                [ Html.form []
                    [ div [ class "form-group row text-danger" ]
                        [ label [ class "col-sm-8 col-form-label", for ("rate-" ++ account.id) ]
                            [ text "Interest Rate"
                            ]
                        , div [ class "col-sm-4 input-group" ]
                            [ input [ class "form-control text-right border-danger", id ("rate-" ++ account.id), type_ "number", Html.Attributes.min "0", step "0.1" ] []
                            , div [ class "input-group-append border-danger" ]
                                [ span [ class "input-group-text text-light border-danger bg-danger" ] [ text "%" ]
                                ]
                            ]
                        , small [ class "form-text font-weight-bold pl-3" ]
                            [ text "Need an interest rate to calculate your payment strategies." ]
                        ]
                    , div [ class "form-group row" ]
                        [ label [ class "col-sm-7 col-form-label", for ("min-payment-" ++ account.id) ] [ text "Minimum Payment" ]
                        , div [ class "col-sm-5 input-group" ]
                            [ div [ class "input-group-prepend" ]
                                [ span [ class "input-group-text" ] [ text "$" ]
                                ]
                            , input [ class "form-control text-right", id ("min-payment-" ++ account.id), type_ "number", Html.Attributes.min "0", step "10" ] []
                            ]
                        ]
                    ]
                ]
            ]
        ]


viewChooseAccounts : Model -> Html Msg
viewChooseAccounts model =
    viewScreen viewChooseAccountsContent model


viewChooseAccountsContent : Model -> Html Msg
viewChooseAccountsContent model =
    let
        isNextDisabled =
            Maybe.withDefault [] model.session.accounts
                |> List.isEmpty

        content =
            loadingContent
                "Loading accounts..."
                (div []
                    [ (viewAccountsList model.accounts model.session.accounts)
                    , div [ class "d-flex mt-4" ]
                        [ button
                            [ class "btn btn-outline-dark mr-auto"
                            , onClick GoToChooseBudget
                            ]
                            [ text "Back" ]
                        , button
                            [ class "btn"
                            , classList [ ( "btn-outline-primary", isNextDisabled ), ( "btn-primary", not isNextDisabled ) ]
                            , disabled isNextDisabled
                            , onClick GoToDebtDetails
                            ]
                            [ text "Next Step" ]
                        ]
                    ]
                )
                model.isLoadingScreenData
    in
        section [ class "o-choose-accounts" ]
            [ header [ class "text-center" ] [ h1 [] [ text "Choose Debt Accounts" ] ]
            , section [ class "py-4" ] [ content ]
            ]


viewAccountsList : Maybe (List Account) -> Maybe (List Account) -> Html Msg
viewAccountsList maybeAccounts maybeSelectedAccounts =
    case maybeAccounts of
        Nothing ->
            p [ class "text-center" ] [ text "No accounts in the budget." ]

        Just accounts ->
            div [ class "list-group" ]
                (List.map
                    (\account ->
                        div
                            [ class "list-group-item d-flex"
                            , classList [ ( "selected", isAccountSelected maybeSelectedAccounts account ) ]
                            , onClick (ToggleAccount account)
                            ]
                            [ div [ class "mr-auto" ]
                                [ h5 [ class "mb-0" ] [ text account.name ]
                                , small [ class "text-uppercase text-muted font-weight-light" ]
                                    [ text account.accountType ]
                                ]
                            , div
                                [ class "align-self-center"
                                , classList
                                    [ ( "text-danger", account.balance < 0 )
                                    , ( "font-weight-bold", account.balance < 0 )
                                    ]
                                ]
                                [ text (toCurrency account.balance) ]
                            ]
                    )
                    accounts
                )


isAccountSelected : Maybe (List Account) -> Account -> Bool
isAccountSelected maybeAccounts account =
    case maybeAccounts of
        Nothing ->
            False

        Just accounts ->
            accounts |> List.filter (\a -> a.id == account.id) |> List.isEmpty |> not


toCurrency : Int -> String
toCurrency amount =
    let
        cents =
            toString (rem amount 1000)

        centsFormatted =
            if (String.length cents) == 1 then
                "0" ++ cents
            else
                cents

        dollarsFormatted =
            (toString (abs (amount // 1000)))
                |> String.reverse
                |> Regex.find Regex.All (Regex.regex "\\d\\d\\d|\\d\\d|\\d")
                |> List.reverse
                |> List.map (.match >> String.reverse)
                |> String.join ","

        negativeSymbol =
            if amount < 0 then
                "-"
            else
                ""
    in
        negativeSymbol ++ "$" ++ dollarsFormatted ++ "." ++ centsFormatted


viewChooseBudget : Model -> Html Msg
viewChooseBudget model =
    viewScreen viewChooseBudgetContent model


viewChooseBudgetContent : Model -> Html Msg
viewChooseBudgetContent model =
    let
        isNextDisabled =
            model.session.budget == Nothing

        content =
            loadingContent
                "Loading budgets..."
                (div []
                    [ (viewBudgetList model.budgets model.session.budget)
                    , div [ class "d-flex justify-content-end mt-4" ]
                        [ button
                            [ class "btn"
                            , classList [ ( "btn-outline-primary", isNextDisabled ), ( "btn-primary", not isNextDisabled ) ]
                            , disabled isNextDisabled
                            , onClick GoToChooseAccounts
                            ]
                            [ text "Next Step" ]
                        ]
                    ]
                )
                model.isLoadingScreenData
    in
        section [ class "o-choose-budget" ]
            [ header [ class "text-center" ] [ h1 [] [ text "Choose a Budget" ] ]
            , section [ class "py-4" ] [ content ]
            ]


viewBudgetList : Maybe (List Budget) -> Maybe Budget -> Html Msg
viewBudgetList maybeBudgets selectedBudget =
    case maybeBudgets of
        Nothing ->
            p [ class "text-center" ] [ text "No budgets" ]

        Just budgets ->
            div [ class "list-group" ]
                (List.map
                    (\budget ->
                        div
                            [ class "list-group-item"
                            , classList [ ( "selected", budget.id == Maybe.withDefault "" (Maybe.map .id selectedBudget) ) ]
                            , onClick (SelectBudget (Just budget))
                            ]
                            [ h5 [ class "mb-0" ] [ text budget.name ]
                            , small [ class "text-muted font-weight-light" ]
                                [ text ("Last updated on " ++ (Maybe.withDefault "" budget.lastModifiedOn)) ]
                            ]
                    )
                    budgets
                )


viewWelcome : Model -> Html Msg
viewWelcome model =
    viewScreen viewWelcomeContent model


viewWelcomeContent : Model -> Html Msg
viewWelcomeContent model =
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
            [ loaderButton "Connecting to YNAB..." "Connect to YNAB" model.isRequestingAccessToken [ class "btn btn-primary btn-lg", onClick RequestAccessToken ]
            ]
        ]


viewError : Model -> Html Msg
viewError model =
    viewScreen viewErrorContent model


viewErrorContent : Model -> Html Msg
viewErrorContent model =
    section [ class "o-error-content" ]
        [ header [ class "text-center" ]
            [ h1
                [ class "display-4"
                , property "innerHTML" (Encode.string """
                    &ldquo;Unlike some politicians, I can admin to a mistake.
                    <small>– Nelson Mandela</small>
                """)
                ]
                []
            ]
        ]


viewScreen : (Model -> Html Msg) -> Model -> Html Msg
viewScreen content model =
    div [ class "container" ]
        [ viewErrorAlert model.errorMessage
        , viewToolbar model
        , content model
        , Footer.view
        ]


viewErrorAlert : Maybe String -> Html msg
viewErrorAlert maybeErrorMessage =
    case maybeErrorMessage of
        Nothing ->
            viewEmpty

        Just errorMessage ->
            div [ class "alert alert-danger" ]
                [ strong [] [ text "Oh no! " ]
                , text errorMessage
                ]


viewToolbar : Model -> Html Msg
viewToolbar model =
    case model.session.token of
        Nothing ->
            viewEmpty

        Just _ ->
            div []
                [ ul [ class "nav justify-content-end" ]
                    [ li [ class "nav-item" ] [ button [ class "nav-link btn btn-link btn-sm", onClick Disconnect ] [ text "Disconnect" ] ]
                    ]
                ]


viewEmpty : Html msg
viewEmpty =
    span [ style [ ( "display", "none" ) ] ] []


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


loadingContent : String -> Html msg -> Bool -> Html msg
loadingContent label content isLoading =
    if isLoading then
        loadingMessage label
    else
        content


loadingMessage : String -> Html msg
loadingMessage label =
    div [ class "text-center text-info" ]
        [ p [ class "d-block" ] [ i [ class "far fa-snowflake fa-spin fa-2x" ] [] ]
        , p [ class "font-weight-light" ] [ text label ]
        ]
