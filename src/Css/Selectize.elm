module Css.Selectize exposing (..)

import Css exposing (..)
import Css.Colors as Colors
import Selectize
import Css.Admin exposing (..)
import Css.Elements exposing (input)


component : Mixin
component =
    mixin
        [ borderRadius (px 3)
        , position relative
        , descendants
            [ (.) SelectBox
                [ displayFlex
                , alignItems center
                , padding2 zero (px 5)
                , property "background-color" "inherit"
                ]
            , (.) BoxContainer
                [ position absolute
                , property "z-index" "100"
                , left (px -3)
                , backgroundColor Colors.white
                , textAlign left
                , fontWeight (int 500)
                , fontSize (pct 80)
                , borderRadius (px 3)
                , backgroundColor Colors.white
                , border3 (px 3) solid Colors.lightGrey
                , borderTop zero
                , color Colors.sandstone
                , width (em 15)
                , cursor pointer
                , padding (px 5)
                ]
            , (.) BoxItems
                []
            , (.) BoxItemActive
                [ color Colors.cobalt
                , fontWeight (int 900)
                ]
            , (.) BoxItem
                [ padding2 (px 3) (px 6)
                ]
            , (.) Info
                [ padding2 (px 3) (px 6)
                , color Colors.darkGrey
                ]
            , (.) MultiItemContainer
                [ descendants
                    [ (.) SelectedItem
                        [ backgroundColor Colors.cobalt
                        , color Colors.white
                        , padding3 (px 2) (px 3) (px 1)
                        , fontFamilies [ "Inconsolata" ]
                        , fontSize (pct 70)
                        , fontWeight bold
                        , borderRadius (px 3)
                        ]
                    , (.) FallbackItem
                        [ backgroundColor Colors.sandstone
                        ]
                    ]
                ]
            , (.) SingleItemContainer
                [ descendants
                    [ (.) SelectedItem
                        [ fontFamilies [ "Fira Code" ]
                        , fontSize (px 11)
                        , padding zero
                        , borderRadius zero
                        ]
                    , (.) FallbackItem
                        [ color Colors.sandstone
                        ]
                    ]
                ]
            , input
                [ textAlign left
                , property "background-color" "inherit"
                , padding2 (px 6) (px 2)
                ]
            ]
        ]


type Class
    = SelectizeContainer
    | SelectBox
    | BoxItems
    | BoxItem
    | BoxItemActive
    | SelectedItems
    | FallbackItems
    | FallbackItem
    | SelectedItem
    | InputEditing
    | SingleItemContainer
    | MultiItemContainer
    | BoxContainer
    | Info
    | InfoNoMatches
    | NoOptions


classes : Selectize.HtmlClasses
classes =
    { container = className SelectizeContainer
    , singleItemContainer = className SingleItemContainer
    , multiItemContainer = className MultiItemContainer
    , selectBox = className SelectBox
    , selectedItems = className SelectedItems
    , fallbackItems = className FallbackItems
    , fallbackItem = className FallbackItem
    , selectedItem = className SelectedItem
    , boxContainer = className BoxContainer
    , boxItems = className BoxItems
    , boxItem = className BoxItem
    , boxItemActive = className BoxItemActive
    , info = className Info
    , infoNoMatches = className InfoNoMatches
    , inputEditing = className InputEditing
    , noOptions = className NoOptions
    }
