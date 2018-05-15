module Main exposing (Model, Msg, update, view, subscriptions, init)

import Data.AccessToken as AccessToken exposing (AccessToken(..), decoder)
import Data.Account exposing (Account)
import Data.Budget exposing (Budget)
import Data.CategoryGroup exposing (CategoryGroup)
import Data.Session as Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Encode as Encode
import Json.Decode as Decode exposing (Value)
import Ports
import Request.Account as AccountRequest
import Request.Budget as BudgetRequest
import Request.CategoryGroup as CategoryGroupRequest
import Screen.DebtDetails as DebtDetails
import Views.Assets exposing (assets)
import Views.Footer as Footer
import Util exposing ((=>), toCurrency)


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

        -- TODO: If decoding fails, backup the session. It might need to be migrated.
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
                                , debtDetails = DebtDetails.init session.debtDetails
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
    , debtDetails : DebtDetails.Model
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
    , debtDetails = DebtDetails.init Nothing
    }


type Screen
    = WelcomeScreen
    | ChooseBudgetScreen
    | ChooseAccountsScreen
    | DebtDetailsScreen
    | ChooseCategoryScreen
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
    | HandleCategoriesResponse (Result Http.Error (List CategoryGroup))
    | SelectBudget (Maybe Budget)
    | ToggleAccount Account
    | DebtDetailsMsg DebtDetails.Msg
    | GoToChooseBudget
    | GoToChooseAccounts
    | GoToDebtDetails
    | GoToPaymentStrategies
    | GoToPaymentStrategy


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

        HandleCategoriesResponse result ->
            case result of
                Ok categoryGroups ->
                    ( { model | isLoadingScreenData = False }, Cmd.none )

                Err _ ->
                    ( { model
                        | isLoadingScreenData = False
                        , errorMessage = defaultErrorMessage
                      }
                    , Cmd.none
                    )

        SelectBudget maybeBudget ->
            ( { model | session = Session.setBudget maybeBudget model.session }, Cmd.none )

        ToggleAccount account ->
            { model | session = Session.toggleAccount account model.session } => Cmd.none

        DebtDetailsMsg subMsg ->
            let
                ( ( screenModel, screenCmd ), msgFromScreen ) =
                    DebtDetails.update subMsg model.debtDetails

                modelScreenMsg =
                    case msgFromScreen of
                        DebtDetails.NoOp ->
                            model

                        DebtDetails.GoBack ->
                            { model | currentScreen = ChooseAccountsScreen }

                        DebtDetails.GoNext ->
                            -- TODO: update session debtDetails from DebtDetail.detailEdits
                            { model | currentScreen = ChooseCategoryScreen }

                ( newModel, newCmd ) =
                    loadScreenData { modelScreenMsg | debtDetails = screenModel }
            in
                newModel => Cmd.batch [ Cmd.map DebtDetailsMsg screenCmd, newCmd ]

        GoToChooseBudget ->
            loadScreenData { model | currentScreen = ChooseBudgetScreen }

        GoToChooseAccounts ->
            case model.session.budget of
                Nothing ->
                    model => Cmd.none

                Just budget ->
                    let
                        ( newModel, newCmd ) =
                            loadScreenData { model | currentScreen = ChooseAccountsScreen }
                    in
                        ( newModel, Cmd.batch [ saveSession newModel.session, newCmd ] )

        GoToDebtDetails ->
            let
                ( newModel, newCmd ) =
                    loadScreenData
                        { model
                            | debtDetails = DebtDetails.initFromAccounts model.accounts
                            , currentScreen = DebtDetailsScreen
                        }
            in
                ( newModel, Cmd.batch [ saveSession newModel.session, newCmd ] )

        GoToPaymentStrategies ->
            ( model, Cmd.none )

        GoToPaymentStrategy ->
            ( model, Cmd.none )


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
                    ( { model | errorMessage = Just "Something went wrong, we couldn't find your selected budget." }
                    , Cmd.none
                    )

                Just budget ->
                    ( { model | isLoadingScreenData = True }
                    , AccountRequest.list model.apiUrl model.session.token budget.id
                        |> Http.send HandleAccountsResponse
                    )

        ChooseCategoryScreen ->
            case model.session.budget of
                Nothing ->
                    ( { model | errorMessage = Just "Something went wrong, we couldn't find your selected budget." }
                    , Cmd.none
                    )

                Just budget ->
                    ( { model | isLoadingScreenData = True }
                    , CategoryGroupRequest.list model.apiUrl model.session.token budget.id
                        |> Http.send HandleCategoriesResponse
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

        ChooseCategoryScreen ->
            viewCategoryGroups

        _ ->
            viewError model


viewDebtDetails : Model -> Html Msg
viewDebtDetails model =
    viewScreen viewDebtDetailsContent model


viewDebtDetailsContent : Model -> Html Msg
viewDebtDetailsContent model =
    DebtDetails.view model.session.accounts model.debtDetails
        |> Html.map DebtDetailsMsg


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


viewCategoryGroups : Html Msg
viewCategoryGroups =
    div [] []


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
