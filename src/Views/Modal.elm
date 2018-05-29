module Views.Modal exposing (Options, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Attributes.Aria exposing (..)


type alias Options msg =
    { id : String
    , title : Maybe (Html msg)
    , body : Maybe (Html msg)
    , footer : Maybe (Html msg)
    }


view : Options msg -> Html msg
view options =
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
        div [ id options.id, class "modal fade", tabindex -1, role "dialog" ]
            [ div [ class "modal-dialog", role "document" ]
                [ div [ class "modal-content" ]
                    [ header
                    , body
                    , footer
                    ]
                ]
            ]


closeButton : Options msg -> Html msg
closeButton options =
    button
        [ type_ "button"
        , class "close"
        , ariaLabel "Close"
        , attribute "data-dismiss" "modal"
        ]
        [ span [ ariaHidden True ] [ text "×" ] ]


empty : Html msg
empty =
    span [ style [ ( "display", "none" ) ] ] []
