module Screen.DebtDetails exposing (ExternalMsg(..), Model, Msg, buildDebtDetails, init, initFromAccounts, update, view)

import Data.Account exposing (Account)
import Data.DebtDetail exposing (DebtDetail)
import Dict as Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Util exposing ((=>), toCurrency)
import Validate exposing (Validator, ifBlank, ifEmptyList, ifNotInt, ifTrue, validate)


-- MODEL


type alias Model =
    { showErrors : Bool
    , detailEdits : Dict String DetailEdit
    }


type alias DetailEdit =
    { accountId : String
    , balance : Int
    , errors : List Error
    , rate : String
    , minPayment : String
    }


init : Maybe (Dict String DebtDetail) -> Model
init maybeDebtDetails =
    let
        detailEdits =
            case maybeDebtDetails of
                Nothing ->
                    Dict.empty

                Just debtDetails ->
                    Dict.map (\_ dd -> initFromDebtDetail dd) debtDetails
    in
        { showErrors = False, detailEdits = detailEdits }


initFromAccounts : Maybe (Dict String DebtDetail) -> Maybe (List Account) -> Model
initFromAccounts maybeDebtDetails maybeAccounts =
    let
        baseDetailEdits =
            init maybeDebtDetails
                |> .detailEdits

        detailEdits =
            case maybeAccounts of
                Nothing ->
                    Dict.empty

                Just accounts ->
                    accounts
                        |> List.map
                            (\a ->
                                a.id
                                    => Maybe.withDefault
                                        (initForAccount a.id a.balance)
                                        (Dict.get a.id baseDetailEdits)
                            )
                        |> Dict.fromList
    in
        { showErrors = False, detailEdits = detailEdits }


initFromDebtDetail : DebtDetail -> DetailEdit
initFromDebtDetail debtDetail =
    { accountId = debtDetail.accountId
    , balance = debtDetail.balance
    , errors = []
    , rate = toString debtDetail.rate
    , minPayment = toString debtDetail.minPayment
    }


initForAccount : String -> Int -> DetailEdit
initForAccount accountId balance =
    { accountId = accountId
    , balance = balance
    , errors = []
    , rate = ""
    , minPayment = ""
    }



-- UPDATE


type Msg
    = SetRate String String
    | SetMinPayment String String
    | Back
    | Continue


type ExternalMsg
    = NoOp
    | GoBack
    | GoNext


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        SetRate accountId rate ->
            let
                newDetailEdits =
                    Dict.update accountId (Maybe.map (\a -> { a | rate = rate })) model.detailEdits
                        |> Dict.map validateDetailEdit
            in
                { model | detailEdits = newDetailEdits }
                    => Cmd.none
                    => NoOp

        SetMinPayment accountId minPayment ->
            let
                newDetailEdits =
                    Dict.update accountId (Maybe.map (\a -> { a | minPayment = minPayment })) model.detailEdits
                        |> Dict.map validateDetailEdit
            in
                { model | detailEdits = newDetailEdits }
                    => Cmd.none
                    => NoOp

        Back ->
            ( model, Cmd.none ) => GoBack

        Continue ->
            let
                newDetailEdits =
                    Dict.map validateDetailEdit model.detailEdits

                newModel =
                    { model | detailEdits = newDetailEdits, showErrors = True }

                hasErrors =
                    Dict.values newModel.detailEdits
                        |> List.map (.errors >> List.length)
                        |> List.any (\s -> s > 0)

                newExternalMsg =
                    if hasErrors then
                        NoOp
                    else
                        GoNext
            in
                newModel
                    => Cmd.none
                    => newExternalMsg


validateDetailEdit : String -> DetailEdit -> DetailEdit
validateDetailEdit _ detailEdit =
    { detailEdit | errors = validate detailEditValidator detailEdit }



-- VIEW --


view : Maybe (List Account) -> Model -> Html Msg
view maybeAccounts model =
    let
        content =
            case maybeAccounts of
                Nothing ->
                    [ p [ class "alert alert-info" ]
                        [ text "Go back to select the debt accounts you want to create a payment strategy for." ]
                    ]

                Just accounts ->
                    List.map (\a -> viewDetailEdit a (Dict.get a.id model.detailEdits)) accounts
    in
        section [ class "o-debt-details" ]
            [ header [ class "text-center" ] [ h1 [] [ text "Debt Details" ] ]
            , section [ class "py-4" ]
                [ Html.form [ onSubmit Continue ]
                    [ div [] content
                    , div [ class "d-flex mt-4" ]
                        [ button
                            [ class "btn btn-outline-dark mr-auto"
                            , type_ "button"
                            , onClick Back
                            ]
                            [ text "Back" ]
                        , button
                            [ class "btn btn-primary"
                            , type_ "submit"
                            ]
                            [ text "Next Step" ]
                        ]
                    ]
                ]
            ]


viewDetailEdit : Account -> Maybe DetailEdit -> Html Msg
viewDetailEdit account maybeDetailEdit =
    case maybeDetailEdit of
        Nothing ->
            viewEmpty

        Just detailEdit ->
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
                            [ viewRateControl detailEdit
                            , viewMinPaymentControl detailEdit
                            ]
                        ]
                    ]
                ]


viewRateControl : DetailEdit -> Html Msg
viewRateControl detailEdit =
    let
        errorMessage =
            findErrorMessage Rate detailEdit.errors

        hasError =
            errorMessage /= Nothing

        errorText =
            case errorMessage of
                Nothing ->
                    viewEmpty

                Just message ->
                    viewErrorMessage message
    in
        div [ class "form-group row", classList [ ( "text-danger", hasError ) ] ]
            [ label [ class "col-sm-7 col-form-label", for ("rate-" ++ detailEdit.accountId) ]
                [ text "Interest Rate"
                ]
            , div [ class "col-sm-5 input-group" ]
                [ input
                    [ class "form-control text-right"
                    , classList [ ( "border-danger", hasError ) ]
                    , id ("rate-" ++ detailEdit.accountId)
                    , type_ "number"
                    , Html.Attributes.min "0"
                    , Html.Attributes.max "100"
                    , step "0.1"
                    , onInput (SetRate detailEdit.accountId)
                    , defaultValue detailEdit.rate
                    ]
                    []
                , div [ class "input-group-append" ]
                    [ span [ class "input-group-text", classList [ ( "text-light border-danger bg-danger", hasError ) ] ] [ text "%" ]
                    ]
                ]
            , errorText
            ]


viewMinPaymentControl : DetailEdit -> Html Msg
viewMinPaymentControl detailEdit =
    let
        errorMessage =
            findErrorMessage MinPayment detailEdit.errors

        hasError =
            errorMessage /= Nothing

        errorText =
            case errorMessage of
                Nothing ->
                    viewEmpty

                Just message ->
                    viewErrorMessage message
    in
        div [ class "form-group row", classList [ ( "text-danger", hasError ) ] ]
            [ label [ class "col-sm-7 col-form-label", for ("min-payment-" ++ detailEdit.accountId) ] [ text "Minimum Payment" ]
            , div [ class "col-sm-5 input-group" ]
                [ div [ class "input-group-prepend" ]
                    [ span [ class "input-group-text", classList [ ( "border-danger bg-danger text-light", hasError ) ] ] [ text "$" ]
                    ]
                , input
                    [ class "form-control text-right"
                    , classList [ ( "border-danger", hasError ) ]
                    , id ("min-payment-" ++ detailEdit.accountId)
                    , type_ "number"
                    , Html.Attributes.min "0"
                    , step "10"
                    , onInput (SetMinPayment detailEdit.accountId)
                    , defaultValue detailEdit.minPayment
                    ]
                    []
                ]
            , errorText
            ]


viewErrorMessage : String -> Html msg
viewErrorMessage message =
    small [ class "form-text font-weight-bold pl-3" ] [ text message ]


viewEmpty : Html msg
viewEmpty =
    span [ style [ ( "display", "none" ) ] ] []



-- VALIDATION --


type Field
    = Form
    | Rate
    | MinPayment


type alias Error =
    ( Field, String )


detailEditValidator : Validator Error DetailEdit
detailEditValidator =
    Validate.all
        [ Validate.firstError
            [ ifBlank .rate (Rate => "Need an interest rate to calculate your payment strategies.")
            , ifNotFloat .rate (Rate => "Interest rate must be a number.")
            , ifLessThan 0 .rate (Rate => "Must be a number greater than or equal to zero.")
            ]
        , Validate.firstError
            [ ifBlank .minPayment (MinPayment => "Need a minimum payment to calculate your payment strategies.")
            , ifNotFloat .minPayment (MinPayment => "Minimum payment must be a number.")
            , ifLessThan 0 .minPayment (MinPayment => "Must be a number greater than or equal to zero.")
            ]
        ]


ifNotFloat : (subject -> String) -> Error -> Validator Error subject
ifNotFloat subjectToString error =
    ifTrue
        (\s -> (subjectToString s |> String.toFloat |> Result.toMaybe) == Nothing)
        error


ifLessThan : Int -> (subject -> String) -> Error -> Validator Error subject
ifLessThan number subjectToString error =
    ifTrue
        (\s ->
            (let
                result =
                    subjectToString s |> String.toFloat |> Result.toMaybe
             in
                case result of
                    Nothing ->
                        True

                    Just value ->
                        value < (toFloat number)
            )
        )
        error


findErrorMessage : Field -> List Error -> Maybe String
findErrorMessage field errors =
    List.filter (\( f, _ ) -> f == field) errors
        |> List.head
        |> Maybe.map Tuple.second


buildDebtDetails : Model -> Dict String DebtDetail
buildDebtDetails model =
    model.detailEdits
        |> Dict.map validateDetailEdit
        |> Dict.filter (\_ de -> List.isEmpty de.errors)
        |> Dict.map
            (\_ de ->
                let
                    ( maybeRate, maybeMinPayment ) =
                        ( String.toInt de.rate |> Result.toMaybe
                        , String.toInt de.minPayment |> Result.toMaybe
                        )
                in
                    case ( maybeRate, maybeMinPayment ) of
                        ( Just rate, Just minPayment ) ->
                            Just
                                { accountId = de.accountId
                                , balance = de.balance
                                , rate = rate
                                , minPayment = minPayment
                                }

                        _ ->
                            Nothing
            )
        |> Dict.foldl
            (\k mde acc ->
                case mde of
                    Just de ->
                        Dict.insert k de acc

                    Nothing ->
                        acc
            )
            Dict.empty



-- https://github.com/rtfeldman/elm-spa-example/blob/master/src/Page/Article/Editor.elm
-- http://package.elm-lang.org/packages/rtfeldman/elm-validate/3.0.0/Validate
