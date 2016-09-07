module NavBar exposing (Page(..), view, update, Msg)

import Html exposing (Html, Attribute, a, div, hr, input, span, text, ul, li, nav)
import Html.Events exposing (onClick)
import Html.CssHelpers
import Css.Classes
import Navigation exposing (newUrl)
import VirtualDom


{ id, class, classList } =
    Html.CssHelpers.withNamespace "lamassuAdmin"



-- MODEL


type Page
    = AccountPage String
    | PairPage
    | ConfigPage String (Maybe String)
    | UnknownPage


type alias Model =
    ()


initModel : Model
initModel =
    ()


load : ( Model, Cmd Msg )
load =
    ( (), Cmd.none )



-- UPDATE


type Msg
    = NewPage Page


update : Msg -> Model -> ( Model, Cmd Msg )
update (NewPage page) model =
    case page of
        PairPage ->
            model ! [ newUrl "/pair" ]

        AccountPage account ->
            model ! [ newUrl ("/account/" ++ account) ]

        ConfigPage configGroup maybeCrypto ->
            case maybeCrypto of
                Nothing ->
                    model ! [ newUrl ("/config/" ++ configGroup) ]

                Just crypto ->
                    model ! [ newUrl ("/config/" ++ configGroup ++ "/" ++ crypto) ]

        UnknownPage ->
            Debug.crash "Need unknown page"



-- Bit hacky, but we have to match only first parameter of page


activePage : Page -> Page -> VirtualDom.Property a
activePage linkPage page =
    let
        active =
            case page of
                PairPage ->
                    linkPage == page

                AccountPage _ ->
                    linkPage == page

                ConfigPage config _ ->
                    (Debug.log "DEBUG2" linkPage) == (Debug.log "DEBUG3" (ConfigPage config Nothing))

                UnknownPage ->
                    Debug.crash "Need unknown page"
    in
        if (active) then
            class [ Css.Classes.Active ]
        else
            class []


view : Page -> Html Msg
view page =
    nav [ class [ Css.Classes.NavBar ] ]
        [ div [ onClick (NewPage PairPage), activePage PairPage page ] [ text "Pairing" ]
        , div [ onClick (NewPage (AccountPage "twilio")), activePage (AccountPage "twilio") page ] [ text "Accounts" ]
        , div [ onClick (NewPage (ConfigPage "commissions" Nothing)), activePage (ConfigPage "commissions" Nothing) page ] [ text "Commissions" ]
        , div [ onClick (NewPage (ConfigPage "limits" Nothing)), activePage (ConfigPage "limits" Nothing) page ] [ text "Limits" ]
        , div [ onClick (NewPage (ConfigPage "fiat" Nothing)), activePage (ConfigPage "fiat" Nothing) page ] [ text "Fiat" ]
        , div [ onClick (NewPage (ConfigPage "crypto-services" Nothing)), activePage (ConfigPage "crypto-services" Nothing) page ] [ text "Crypto services" ]
        ]
