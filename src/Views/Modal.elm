module Views.Modal exposing (Options, view, viewBackdrop)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes.Aria exposing (..)
import Html.Events exposing (onClick, onWithOptions)
import Json.Decode as Decode


type alias Options msg =
    { closeMessage : msg
    , title : Maybe (Html msg)
    , body : Maybe (Html msg)
    , footer : Maybe (Html msg)
    }


view : Options msg -> Bool -> Html msg
view options show =
    let
        header =
            case options.title of
                Nothing ->
                    empty

                Just title ->
                    div [ class "modal-header" ]
                        [ div [ class "modal-title" ]
                            [ title ]
                        , closeButton options
                        ]

        body =
            case options.body of
                Nothing ->
                    empty

                Just body ->
                    div [ class "modal-body" ] [ body ]

        footer =
            case options.footer of
                Nothing ->
                    empty

                Just footer ->
                    div [ class "modal-footer" ] [ footer ]
    in
        div [ class "modal", classList [ ( "show", show ) ], tabindex -1, role "dialog", onClick options.closeMessage ]
            [ div [ class "modal-dialog", role "document" ]
                [ div [ class "modal-content" ]
                    [ header
                    , body
                    , footer
                    ]
                ]
            ]


viewBackdrop : msg -> Bool -> Html msg
viewBackdrop closeMessage show =
    if show then
        div [ class "modal-backdrop show", onClick closeMessage ] []
    else
        empty


closeButton : Options msg -> Html msg
closeButton options =
    button
        [ type_ "button"
        , class "close"
        , ariaLabel "Close"
        , onWithOptions "click" { stopPropagation = True, preventDefault = False } (Decode.succeed options.closeMessage)
        ]
        [ span [ ariaHidden True ] [ text "×" ] ]


empty : Html msg
empty =
    span [ style [ ( "display", "none" ) ] ] []
