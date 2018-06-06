module Main exposing (Model, Msg, update, view, subscriptions, init)

import Color
import Data.AccessToken as AccessToken exposing (AccessToken(..), decoder)
import Data.Account as Account exposing (Account)
import Data.Budget exposing (Budget)
import Data.PaymentStrategy as PaymentStrategy exposing (PaymentStrategy, Payment)
import Data.Session as Session exposing (Session)
import Date exposing (Date)
import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Encode as Encode
import Json.Decode as Decode exposing (Value)
import LineChart
import LineChart.Area
import LineChart.Axis
import LineChart.Axis.Intersection
import LineChart.Colors
import LineChart.Container
import LineChart.Dots
import LineChart.Events
import LineChart.Grid
import LineChart.Interpolation
import LineChart.Junk
import LineChart.Legends
import LineChart.Line
import Ports
import Request.Account as AccountRequest
import Request.Budget as BudgetRequest
import Screen.DebtDetails as DebtDetails
import Views.Assets exposing (assets)
import Views.Footer as Footer
import Util exposing ((=>), milliDollarToFloat, toCurrency, toDuration, toMilliDollars)


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
                                , debtDetails = DebtDetails.initFromAccounts session.debtDetails session.accounts
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
    , amount : Maybe String
    , paymentStrategies : Maybe (List PaymentStrategy)
    , currentPaymentStrategy : Maybe PaymentStrategy
    , today : Maybe Date
    , chartHintedPayments : List Payment
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
    , amount = Nothing
    , paymentStrategies = Nothing
    , currentPaymentStrategy = Nothing
    , today = Nothing
    , chartHintedPayments = []
    }


type Screen
    = WelcomeScreen
    | ChooseBudgetScreen
    | ChooseAccountsScreen
    | DebtDetailsScreen
    | PaymentStrategiesScreen
    | PaymentStrategyScreen
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
                            case session.debtDetails of
                                Nothing ->
                                    DebtDetailsScreen

                                Just _ ->
                                    PaymentStrategiesScreen



-- UPDATE


type Msg
    = RequestAccessToken
    | UpdateAccessToken (Maybe AccessToken)
    | Disconnect
    | StartOver
    | HandleBudgetsResponse (Result Http.Error (List Budget))
    | HandleAccountsResponse (Result Http.Error (List Account))
    | SelectBudget (Maybe Budget)
    | ToggleAccount Account
    | DebtDetailsMsg DebtDetails.Msg
    | SetAmount (Maybe Int)
    | ChartHint (List Payment)
    | GoToChooseBudget
    | GoToChooseAccounts
    | GoToDebtDetails
    | GoToPaymentStrategies
    | GoToPaymentStrategy PaymentStrategy


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
                { model | session = newSession, currentScreen = WelcomeScreen } => saveSession newSession

        StartOver ->
            let
                newSession =
                    Session.setBudget Nothing model.session
            in
                loadScreenData
                    { model
                        | session = newSession
                        , currentScreen = screenFromSession newSession
                    }

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
                        | accounts =
                            accounts
                                |> List.filter (\a -> (not a.closed) && a.balance < 0)
                                |> Just
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
            ( { model | session = Session.setBudget maybeBudget model.session }, Cmd.none )

        ToggleAccount account ->
            { model | session = Session.toggleAccount account model.session } => Cmd.none

        DebtDetailsMsg subMsg ->
            let
                ( ( screenModel, screenCmd ), msgFromScreen ) =
                    DebtDetails.update subMsg model.debtDetails

                ( modelScreenMsg, modelScreenCmd ) =
                    case msgFromScreen of
                        DebtDetails.NoOp ->
                            model => Cmd.none

                        DebtDetails.GoBack ->
                            { model | currentScreen = ChooseAccountsScreen } => Cmd.none

                        DebtDetails.GoNext ->
                            let
                                nextSession =
                                    Session.updateDebtDetails
                                        (DebtDetails.buildDebtDetails screenModel)
                                        model.session
                            in
                                { model | currentScreen = PaymentStrategiesScreen, session = nextSession }
                                    => saveSession nextSession

                ( newModel, newCmd ) =
                    loadScreenData { modelScreenMsg | debtDetails = screenModel }
            in
                newModel => Cmd.batch [ modelScreenCmd, Cmd.map DebtDetailsMsg screenCmd, newCmd ]

        SetAmount maybeAmount ->
            let
                ( newModel, newCmd ) =
                    loadScreenData
                        { model | session = Session.setAmount maybeAmount model.session }
            in
                newModel => Cmd.batch [ saveSession newModel.session, newCmd ]

        ChartHint payments ->
            { model | chartHintedPayments = payments } => Cmd.none

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
                            | debtDetails = DebtDetails.initFromAccounts model.session.debtDetails model.session.accounts
                            , currentScreen = DebtDetailsScreen
                        }
            in
                ( newModel, Cmd.batch [ saveSession newModel.session, newCmd ] )

        GoToPaymentStrategies ->
            let
                ( newModel, newCmd ) =
                    loadScreenData { model | currentScreen = PaymentStrategiesScreen }
            in
                newModel => Cmd.batch [ saveSession newModel.session, newCmd ]

        GoToPaymentStrategy paymentStrategy ->
            { model
                | currentScreen = PaymentStrategyScreen
                , currentPaymentStrategy = Just paymentStrategy
            }
                => Cmd.none


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

        PaymentStrategiesScreen ->
            case model.session.debtDetails of
                Just debtDetails ->
                    if Dict.isEmpty debtDetails then
                        { model | currentScreen = ErrorScreen } => Cmd.none
                    else
                        let
                            amount =
                                model.session.amount
                                    |> Maybe.withDefault (Session.minPaymentsTotal model.session)

                            details =
                                Dict.values debtDetails

                            newPaymentStrategies =
                                [ PaymentStrategy.initHighInterestFirst details amount
                                , PaymentStrategy.initLowestInterestFirst details amount
                                , PaymentStrategy.initLowestBalanceFirst details amount
                                , PaymentStrategy.initHighestBalanceFirst details amount
                                ]
                                    |> List.sortWith
                                        (\a b ->
                                            case (compare b.months a.months) of
                                                EQ ->
                                                    compare b.interest a.interest

                                                LT ->
                                                    LT

                                                GT ->
                                                    GT
                                        )
                                    |> List.reverse
                        in
                            { model | paymentStrategies = Just newPaymentStrategies } => Cmd.none

                _ ->
                    { model | currentScreen = ErrorScreen } => Cmd.none

        _ ->
            model => Cmd.none


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

        PaymentStrategiesScreen ->
            viewPaymentStrategies model

        PaymentStrategyScreen ->
            viewPaymentStrategy model

        _ ->
            viewError model


viewWelcome : Model -> Html Msg
viewWelcome model =
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
        , Footer.view
        ]


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
            p [ class "text-center" ] [ text "No budgets." ]

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


viewDebtDetails : Model -> Html Msg
viewDebtDetails model =
    viewScreen viewDebtDetailsContent model


viewDebtDetailsContent : Model -> Html Msg
viewDebtDetailsContent model =
    DebtDetails.view model.session.accounts model.debtDetails
        |> Html.map DebtDetailsMsg


viewPaymentStrategies : Model -> Html Msg
viewPaymentStrategies model =
    viewScreen viewPaymentStrategiesContent model


viewPaymentStrategiesContent : Model -> Html Msg
viewPaymentStrategiesContent model =
    let
        budgetName =
            model.session.budget
                |> Maybe.map .name
                |> Maybe.withDefault ""

        totalDebt =
            totalDebtAmount model

        minAmount =
            Session.minPaymentsTotal model.session

        amount =
            model.session.amount
                |> Maybe.withDefault minAmount
    in
        section [ class "o-payment-strategies" ]
            [ header [ class "text-center" ]
                [ h1 [] [ text budgetName ]
                , h2 [ class "h4" ] [ text "Payment Strategies" ]
                ]
            , section [ class "py-4" ]
                [ p [ class "mb-0 text-center text-uppercase text-muted" ]
                    [ small [] [ text "Total Debt" ] ]
                , h3
                    [ class "text-center text-danger h1 mb-2" ]
                    [ text (toCurrency totalDebt)
                    ]
                , p [ class "mb-0 text-center text-uppercase text-muted" ]
                    [ small [] [ text "Monthly Debt Budget" ] ]
                , h3
                    [ class "text-center text-success display-4" ]
                    [ text (toCurrency amount)
                    ]
                , div [ class "mb-4 text-center" ]
                    [ input
                        [ type_ "range"
                        , Html.Attributes.min (minAmount |> milliDollarToFloat >> ceiling >> toString)
                        , Html.Attributes.max
                            (totalDebt
                                |> abs
                                >> milliDollarToFloat
                                >> (\n -> n / 4)
                                >> Basics.min (milliDollarToFloat minAmount)
                                >> Basics.max 5000.0
                                >> ceiling
                                >> toString
                            )
                        , step "1"
                        , defaultValue (amount |> milliDollarToFloat >> toString)
                        , onInput (SetAmount << (String.toFloat >> Result.toMaybe >> Maybe.map toMilliDollars))
                        ]
                        []
                    ]
                , viewPaymentStrategiesList model.paymentStrategies
                , div [ class "d-flex mt-4" ]
                    [ button
                        [ class "btn btn-outline-dark mr-auto"
                        , onClick GoToDebtDetails
                        ]
                        [ text "Back" ]
                    ]
                ]
            ]


viewPaymentStrategiesList : Maybe (List PaymentStrategy) -> Html Msg
viewPaymentStrategiesList maybePaymentStrategies =
    case maybePaymentStrategies of
        Nothing ->
            p [ class "text-center" ] [ text "No payment strategies." ]

        Just paymentStrategies ->
            div [ class "list-group" ]
                (List.map
                    (\paymentStrategy ->
                        div
                            [ class "list-group-item d-flex"
                            , onClick (GoToPaymentStrategy paymentStrategy)
                            ]
                            [ div [ class "mr-auto" ]
                                [ h5 [ class "mb-0" ] [ text paymentStrategy.name ]
                                , small [ class "text-uppercase text-muted font-weight-light" ]
                                    [ text ("Interest Paid " ++ (toCurrency paymentStrategy.interest)) ]
                                ]
                            , div
                                [ class "align-self-center font-weight-bold"
                                ]
                                [ text (toDuration paymentStrategy.months) ]
                            ]
                    )
                    paymentStrategies
                )


viewPaymentStrategy : Model -> Html Msg
viewPaymentStrategy model =
    viewScreen viewPaymentStrategyContent model


viewPaymentStrategyContent : Model -> Html Msg
viewPaymentStrategyContent model =
    let
        maybePaymentStrategy =
            model.currentPaymentStrategy

        title =
            maybePaymentStrategy
                |> Maybe.map .name
                |> Maybe.withDefault "Payment Strategy Not Found"

        paymentChart =
            case ( model.session.accounts, maybePaymentStrategy ) of
                ( Just accounts, Just paymentStrategy ) ->
                    div [] [ chart accounts paymentStrategy model.chartHintedPayments ]

                _ ->
                    viewEmpty
    in
        section [ class "o-payment-strategy" ]
            [ header [ class "text-center" ]
                [ h1 [] [ text title ]
                ]
            , section [ class "py-4" ]
                [ paymentChart
                , footer [ class "d-flex mt-4" ]
                    [ button
                        [ class "btn btn-outline-dark mr-auto"
                        , onClick GoToPaymentStrategies
                        ]
                        [ text "Back" ]
                    ]
                ]
            ]


chart : List Account -> PaymentStrategy -> List Payment -> Html Msg
chart accounts paymentStrategy chartedHintedPayments =
    let
        linesCount =
            List.length paymentStrategy.schedules

        colors =
            lineChartColors linesCount

        dots =
            lineChartDots linesCount
    in
        LineChart.viewCustom (chartConfig chartedHintedPayments)
            (paymentStrategy.schedules
                |> List.map3
                    (\color dot schedule ->
                        let
                            account =
                                accounts
                                    |> List.filter (\a -> a.id == schedule.accountId)
                                    |> List.head
                                    |> Maybe.withDefault (Account.init schedule.accountId)
                        in
                            LineChart.line
                                color
                                dot
                                account.name
                                schedule.payments
                    )
                    colors
                    dots
            )


lineChartDots : Int -> List LineChart.Dots.Shape
lineChartDots count =
    let
        dots =
            [ LineChart.Dots.diamond
            , LineChart.Dots.circle
            , LineChart.Dots.triangle
            , LineChart.Dots.square
            , LineChart.Dots.plus
            , LineChart.Dots.cross
            ]

        repeatCount =
            round ((toFloat count) / (toFloat (List.length dots)))
    in
        List.repeat (Basics.max 1 repeatCount) dots
            |> List.concat
            |> List.take count


lineChartColors : Int -> List Color.Color
lineChartColors count =
    let
        colors =
            [ LineChart.Colors.pink
            , LineChart.Colors.blue
            , LineChart.Colors.purple
            , LineChart.Colors.red
            , LineChart.Colors.gold
            , LineChart.Colors.cyan
            , LineChart.Colors.green
            , LineChart.Colors.teal
            ]

        repeatCount =
            round ((toFloat count) / (toFloat (List.length colors)))
    in
        List.repeat (Basics.max 1 repeatCount) colors
            |> List.concat
            |> List.take count


viewError : Model -> Html Msg
viewError model =
    viewScreen viewErrorContent model


viewErrorContent : Model -> Html Msg
viewErrorContent model =
    section [ class "o-error-content" ]
        [ header [ class "text-center" ]
            [ h1
                [ class "lead"
                , property "innerHTML" (Encode.string """
                    &ldquo;Unlike some politicians, I can admin to a mistake.
                    <small>– Nelson Mandela</small>
                """)
                ]
                []
            , p [ class "text-center" ]
                [ text "I made a mistake while processing your data and my circuits blew up. Sorry!"
                ]
            , div [ class "text-center py-4" ]
                [ button [ class "btn btn-secondary btn-lg", onClick StartOver ]
                    [ text "Start Over"
                    ]
                ]
            ]
        ]


viewScreen : (Model -> Html Msg) -> Model -> Html Msg
viewScreen content model =
    div [ class "container-fluid" ]
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


totalDebtAmount : Model -> Int
totalDebtAmount model =
    model.session.accounts
        |> Maybe.withDefault []
        |> List.map .balance
        |> List.sum



-- CHART CONFIG


chartConfig : List Payment -> LineChart.Config Payment Msg
chartConfig hintedPayments =
    { y = LineChart.Axis.default 450 "balance" (\p -> (toFloat p.balance) / 1000)
    , x = LineChart.Axis.default 1270 "month" (.number >> toFloat)
    , container = containerConfig
    , interpolation = LineChart.Interpolation.linear
    , intersection = LineChart.Axis.Intersection.default
    , legends = LineChart.Legends.default
    , events = LineChart.Events.hoverMany ChartHint
    , area = LineChart.Area.default
    , grid = LineChart.Grid.dots 1 LineChart.Colors.gray
    , line = LineChart.Line.default
    , dots = LineChart.Dots.custom (LineChart.Dots.empty 5 1)
    , junk = LineChart.Junk.hoverMany hintedPayments formatX formatY
    }


formatX : Payment -> String
formatX payment =
    "Month " ++ (toString payment.number)


formatY : Payment -> String
formatY payment =
    toCurrency payment.balance


containerConfig : LineChart.Container.Config Msg
containerConfig =
    LineChart.Container.custom
        { attributesHtml = []
        , attributesSvg = []
        , size = LineChart.Container.relative
        , margin = LineChart.Container.Margin 32 192 32 96
        , id = "line-chart-area"
        }
