module Screen.DebtDetails exposing (Model, Msg, initNew, update, view)

import Data.Account exposing (Account)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)
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



-- VIEW --


view : List Account -> Model -> Html Msg
view accounts model =
    div []
        (accounts
            |> List.map (\a -> viewDetailEdit (findAccountDetailEdit a model) a)
        )


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



-- UPDATE


type Msg
    = Save
    | SetRate String String
    | SetMinPayment String String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Save ->
            case validate modelValidator model of
                [] ->
                    model => Cmd.none

                errors ->
                    model => Cmd.none

        SetRate accountId rate ->
            model => Cmd.none

        SetMinPayment accountId minPayment ->
            model => Cmd.none


findAccountDetailEdit : Account -> List DetailEdit -> DetailEdit
findAccountDetailEdit account detailEdits =
    List.filter (\dd -> dd.accountId == account.id) detailEdits
        |> List.head
        |> Maybe.withDefault (initDetailEdit account)



-- VALIDATION --


type Field
    = Form
    | Rate
    | MinPayment


type alias Error =
    ( Field, String )


modelValidator : Validator Error Model
modelValidator =
    Validate.all
        [ ifEmptyList identity (Form => "")
        ]


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
