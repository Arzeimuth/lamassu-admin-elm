module Pair exposing (..)

import Html exposing (Html, Attribute, a, div, hr, input, span, text, node, button, strong)
import Html.Attributes exposing (id, attribute, placeholder, disabled, style)
import Html.Events exposing (onClick, onInput)
import Http
import HttpBuilder exposing (..)
import String
import RemoteData exposing (RemoteData(NotAsked, Loading, Failure, Success))


-- MODEL


type alias Model =
    { totem : RemoteData.WebData String
    , name : String
    }


getTotem : String -> Cmd Msg
getTotem name =
    get "/api/totem"
        |> withQueryParams [ ( "name", name ) ]
        |> withExpect Http.expectString
        |> send RemoteData.fromResult
        |> Cmd.map Load


init : Model
init =
    { totem = RemoteData.NotAsked
    , name = ""
    }



-- UPDATE


type Msg
    = Load (RemoteData.WebData String)
    | InputName String
    | SubmitName


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Load webData ->
            { model | totem = webData } ! []

        InputName name ->
            { model | name = name } ! []

        SubmitName ->
            model ! [ getTotem model.name ]


view : Model -> Html Msg
view model =
    case Debug.log "DEBUG33" model.totem of
        NotAsked ->
            div []
                [ div []
                    [ input
                        [ onInput InputName
                        , placeholder "Coffee shop, 43 Elm St."
                        ]
                        []
                    , button
                        [ onClick SubmitName, disabled (String.isEmpty model.name) ]
                        [ text "Pair" ]
                    ]
                ]

        Loading ->
            div []
                [ div [] [ text "..." ] ]

        Failure err ->
            div [] [ text (toString err) ]

        Success totem ->
            div
                []
                [ div
                    [ style
                        [ ( "background-color", "#eee" )
                        , ( "padding", "10px" )
                        , ( "width", "225px" )
                        , ( "margin-bottom", "20px" )
                        , ( "border-radius", "6px" )
                        ]
                    ]
                    [ node "qr-code" [ attribute "data" (Debug.log "Totem" totem) ] [] ]
                , div []
                    [ span [] [ text "Scan this QR to pair " ]
                    , strong [] [ text model.name ]
                    ]
                ]
