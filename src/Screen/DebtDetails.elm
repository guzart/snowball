module Screen.DebtDetails exposing (ExternalMsg(..), Model, Msg, initNew, update, view)

import Data.Account exposing (Account)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Util exposing ((=>), toCurrency)
import Validate exposing (Validator, ifBlank, ifEmptyList, ifNotInt, validate)


-- MODEL


type alias Model =
    List DetailEdit


type alias DetailEdit =
    { accountId : String
    , errors : List Error
    , rate : String
    , minPayment : String
    }


initNew : Model
initNew =
    -- TODO: Initialize with values from session, i.e. DebtDetail
    []


initDetailEdit : Account -> DetailEdit
initDetailEdit account =
    { accountId = account.id
    , errors = []
    , rate = ""
    , minPayment = ""
    }



-- UPDATE


type Msg
    = SetRate String String
    | SetMinPayment String String
    | Submit
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
            model => Cmd.none => NoOp

        SetMinPayment accountId minPayment ->
            model => Cmd.none => NoOp

        Submit ->
            List.map (\de -> { de | errors = (validate detailEditValidator de) }) model
                => Cmd.none
                => NoOp

        Back ->
            ( model, Cmd.none ) => GoBack

        Continue ->
            ( model, Cmd.none ) => GoNext


findAccountDetailEdit : Account -> List DetailEdit -> DetailEdit
findAccountDetailEdit account detailEdits =
    List.filter (\dd -> dd.accountId == account.id) detailEdits
        |> List.head
        |> Maybe.withDefault (initDetailEdit account)



-- VIEW --


view : Maybe (List Account) -> Model -> Html Msg
view maybeAccounts model =
    let
        isNextDisabled =
            maybeAccounts == Nothing

        content =
            case maybeAccounts of
                Nothing ->
                    [ p [ class "alert alert-info" ]
                        [ text "Go back to select the debt accounts you want to create a payment strategy for." ]
                    ]

                Just accounts ->
                    List.map (\a -> viewDetailEdit (findAccountDetailEdit a model) a) accounts
    in
        section [ class "o-debt-details" ]
            [ header [ class "text-center" ] [ h1 [] [ text "Debt Details" ] ]
            , section [ class "py-4" ]
                [ Html.form [ onSubmit Submit ]
                    [ div [] content
                    , div [ class "d-flex mt-4" ]
                        [ button
                            [ class "btn btn-outline-dark mr-auto"
                            , onClick Back
                            ]
                            [ text "Back" ]
                        , button
                            [ class "btn"
                            , classList [ ( "btn-outline-primary", isNextDisabled ), ( "btn-primary", not isNextDisabled ) ]
                            , disabled isNextDisabled
                            , onClick Continue
                            ]
                            [ text "Next Step" ]
                        ]
                    ]
                ]
            ]


viewDetailEdit : DetailEdit -> Account -> Html Msg
viewDetailEdit detailEdit account =
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
                    , viewMinPaymentControl account
                    ]
                ]
            ]
        ]


viewRateControl : DetailEdit -> Html Msg
viewRateControl detailEdit =
    div [ class "form-group row text-danger" ]
        [ label [ class "col-sm-8 col-form-label", for ("rate-" ++ detailEdit.accountId) ]
            [ text "Interest Rate"
            ]
        , div [ class "col-sm-4 input-group" ]
            [ input
                [ class "form-control text-right border-danger"
                , id ("rate-" ++ detailEdit.accountId)
                , type_ "number"
                , Html.Attributes.min "0"
                , step "0.1"
                , onInput (SetRate detailEdit.accountId)
                , defaultValue detailEdit.rate
                ]
                []
            , div [ class "input-group-append border-danger" ]
                [ span [ class "input-group-text text-light border-danger bg-danger" ] [ text "%" ]
                ]
            ]
        , small [ class "form-text font-weight-bold pl-3" ]
            [ text "Need an interest rate to calculate your payment strategies." ]
        ]


viewMinPaymentControl : Account -> Html Msg
viewMinPaymentControl account =
    div [ class "form-group row" ]
        [ label [ class "col-sm-7 col-form-label", for ("min-payment-" ++ account.id) ] [ text "Minimum Payment" ]
        , div [ class "col-sm-5 input-group" ]
            [ div [ class "input-group-prepend" ]
                [ span [ class "input-group-text" ] [ text "$" ]
                ]
            , input
                [ class "form-control text-right"
                , id ("min-payment-" ++ account.id)
                , type_ "number"
                , Html.Attributes.min "0"
                , step "10"
                , onInput (SetMinPayment account.id)
                ]
                []
            ]
        ]



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
            , ifNotInt .rate (\_ -> (Rate => "Interest rate must be a number."))
            ]
        , Validate.firstError
            [ ifBlank .minPayment (MinPayment => "Need a minimum payment to calculate your payment strategies.")
            , ifNotInt .minPayment (\_ -> (Rate => "Minimum payment must be a number."))
            ]
        ]



-- https://github.com/rtfeldman/elm-spa-example/blob/master/src/Page/Article/Editor.elm
-- http://package.elm-lang.org/packages/rtfeldman/elm-validate/3.0.0/Validate
