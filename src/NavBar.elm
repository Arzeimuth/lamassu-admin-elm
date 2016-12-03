module NavBar exposing (view, routeToUrl)

import Html exposing (Html, Attribute, a, div, hr, input, span, text, ul, li, nav)
import Html.Events exposing (onClick)
import Html.CssHelpers
import Css.Classes
import String
import CoreTypes
    exposing
        ( Msg(..)
        , Category(..)
        , Route(..)
        , MachineSubRoute(..)
        , machineSubRouteToString
        )


{ id, class, classList } =
    Html.CssHelpers.withNamespace "lamassuAdmin"


maybeUrl : String -> List (Maybe String) -> String
maybeUrl root maybeStrings =
    List.filterMap identity maybeStrings
        |> List.append [ root ]
        |> String.join "/"


routeToUrl : Route -> String
routeToUrl route =
    case route of
        PairRoute ->
            "/#pair"

        AccountRoute account ->
            "/#account/" ++ account

        ConfigRoute configGroup maybeCrypto ->
            maybeUrl ("/#config/" ++ configGroup) [ maybeCrypto ]

        MachineRoute route ->
            "/#machine/" ++ (machineSubRouteToString route)

        NotFoundRoute ->
            Debug.crash "Need unknown route"


linkClasses : Route -> Route -> Bool -> Attribute msg
linkClasses linkRoute route isValid =
    let
        validityClass =
            if isValid then
                []
            else
                [ Css.Classes.InvalidGroup ]

        active =
            case route of
                PairRoute ->
                    linkRoute == route

                AccountRoute _ ->
                    linkRoute == route

                ConfigRoute config _ ->
                    linkRoute == ConfigRoute config Nothing

                MachineRoute _ ->
                    linkRoute == route

                NotFoundRoute ->
                    Debug.crash "Need NotFoundRoute"
    in
        if (active) then
            class ([ Css.Classes.NavBarRoute, Css.Classes.Active ] ++ validityClass)
        else
            class ([ Css.Classes.NavBarRoute ] ++ validityClass)


type alias Link =
    ( String, Route, Bool )


activeCategory : Maybe Category -> Category -> Attribute msg
activeCategory maybeCurrentCategory linkedCategory =
    case maybeCurrentCategory of
        Nothing ->
            class [ Css.Classes.NavBarCategory ]

        Just currentCategory ->
            if currentCategory == linkedCategory then
                class [ Css.Classes.NavBarCategory, Css.Classes.Active ]
            else
                class [ Css.Classes.NavBarCategory ]


categoryView : Maybe Category -> ( String, Category, Route ) -> Html Msg
categoryView currentCategory link =
    let
        ( desc, category, linkRoute ) =
            link
    in
        div
            [ onClick (NewUrl (routeToUrl linkRoute))
            , activeCategory currentCategory category
            ]
            [ text desc ]


linkView : Maybe Category -> Route -> Maybe Category -> Link -> Html Msg
linkView maybeCategory currentRoute maybeLinkedCategory link =
    let
        ( desc, linkRoute, isValid ) =
            link
    in
        div [ onClick (NewUrl (routeToUrl linkRoute)), linkClasses linkRoute currentRoute isValid ] [ text desc ]


linksView : Maybe Category -> Route -> ( String, Category, Route ) -> List Link -> Html Msg
linksView maybeCurrentCategory currentRoute ( catDesc, cat, route ) links =
    if maybeCurrentCategory == (Just cat) then
        div [ class [ Css.Classes.NavBarCategoryContainer ] ]
            [ categoryView maybeCurrentCategory ( catDesc, cat, route )
            , div [] (List.map (linkView maybeCurrentCategory currentRoute (Just cat)) links)
            ]
    else
        div [ class [ Css.Classes.NavBarCategoryContainer ] ]
            [ categoryView maybeCurrentCategory ( catDesc, cat, route )
            ]


determineCategory : Route -> Maybe Category
determineCategory route =
    case route of
        PairRoute ->
            Nothing

        AccountRoute account ->
            Just AccountCat

        ConfigRoute config maybeCryptoCodeString ->
            Just ConfigCat

        MachineRoute machineSubRoute ->
            Just MachineCat

        NotFoundRoute ->
            Nothing


view : Route -> List String -> Html Msg
view route invalidGroups =
    let
        maybeCategory =
            determineCategory route

        l =
            linkView maybeCategory route Nothing

        ll =
            linksView maybeCategory route

        isValid group =
            not (List.member group invalidGroups)

        configLink code display =
            ( display, ConfigRoute code Nothing, isValid code )
    in
        nav [ class [ Css.Classes.NavBar ] ]
            [ ll ( "Machines", MachineCat, MachineRoute MachineActions )
                [ ( "Actions", MachineRoute MachineActions, True )
                ]
            , ll ( "Configuration", ConfigCat, ConfigRoute "commissions" Nothing )
                [ configLink "commissions" "Commissions"
                , configLink "machineSettings" "Machine settings"
                , configLink "machines" "Machines"
                , configLink "fiat" "Fiat currencies"
                , configLink "cryptoServices" "Crypto services"
                , configLink "notifications" "Notifications"
                , configLink "compliance" "Compliance"
                ]
            , ll ( "Accounts", AccountCat, AccountRoute "bitgo" )
                [ ( "BitGo", AccountRoute "bitgo", True )
                , ( "Twilio", AccountRoute "twilio", True )
                , ( "Mailjet", AccountRoute "mailjet", True )
                ]
            , l ( "Pairing", PairRoute, True )
            ]
