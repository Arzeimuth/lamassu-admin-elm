module Css.Selectize exposing (..)

import Css exposing (..)
import Colors
import Selectize
import Css.Admin exposing (..)
import Css.Elements exposing (input)


component : Mixin
component =
    mixin
        [ backgroundColor Colors.white
        , borderRadius (px 3)
        , position relative
        , descendants
            [ (.) SelectBox
                [ displayFlex
                , alignItems center
                , padding2 zero (px 3)
                ]
            , (.) BoxItems
                [ position absolute
                , property "z-index" "100"
                , backgroundColor Colors.white
                , textAlign left
                , fontWeight (int 500)
                , fontSize (pct 80)
                , borderRadius (px 3)
                , backgroundColor Colors.darkerLightGrey
                , color Colors.sandstone
                , width (em 15)
                ]
            , (.) BoxItemActive
                [ color Colors.cobalt
                , fontWeight (int 900)
                ]
            , (.) BoxItem
                [ padding2 (px 3) (px 6)
                ]
            , (.) Instructions
                [ position absolute
                , property "z-index" "100"
                , backgroundColor Colors.white
                , textAlign left
                , fontWeight (int 500)
                , fontSize (pct 80)
                , padding2 (px 3) (px 6)
                , width (pct 100)
                , backgroundColor Colors.darkerLightGrey
                , color Colors.sandstone
                , borderRadius (px 3)
                , width (em 15)
                ]
            , (.) SelectedItem
                [ backgroundColor Colors.cobalt
                , color Colors.white
                , padding3 (px 2) (px 3) (px 1)
                , fontFamilies [ "Inconsolata" ]
                , fontSize (pct 70)
                , fontWeight bold
                , borderRadius (px 3)
                ]
            , (.) FallbackItems
                [ children
                    [ (.) SelectedItem
                        [ backgroundColor Colors.sandstone
                        ]
                    ]
                ]
            , input
                [ textAlign left
                , opacity zero
                ]
            , (.) InputEditing
                [ opacity (int 1)
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
    | SelectedItem
    | Instructions
    | InputEditing


classes : Selectize.HtmlClasses
classes =
    { container = className SelectizeContainer
    , selectBox = className SelectBox
    , selectedItems = className SelectedItems
    , fallbackItems = className FallbackItems
    , selectedItem = className SelectedItem
    , boxItems = className BoxItems
    , boxItem = className BoxItem
    , boxItemActive = className BoxItemActive
    , instructionsForBlank = className Instructions
    , inputEditing = className InputEditing
    }
