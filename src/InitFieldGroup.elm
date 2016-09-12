module InitFieldGroup exposing (..)

import ConfigTypes exposing (..)
import Selectize


-- { fieldLocator : FieldLocator
-- , fieldValue : FieldHolder valueType
-- , loadedFieldValue : Maybe valueType
-- , component : Selectize.State
-- }


initSelectizeFieldInstance : FieldLocator -> valueType -> FieldScope -> SelectizeFieldInstance valueType
initSelectizeFieldInstance fieldLocator value fieldScope =
    { fieldLocator = fieldLocator
    , fieldValue = Ok (Just value)
    , loadedFieldValue = Just value
    , component = Selectize.initialSelectize
    }


initSelectizeCluster : List FieldScope -> Field -> Maybe SelectizeCluster
initSelectizeCluster fieldScopes field =
    case field.fieldValue of
        AccountValue v ->
            List.map (initSelectizeFieldInstance field.fieldLocator v) fieldScopes
                |> AccountCluster
                |> Just


initInputFieldInstance : FieldLocator -> valueType -> FieldScope -> InputFieldInstance valueType
initInputFieldInstance fieldLocator value fieldScope =
    { fieldLocator = fieldLocator
    , fieldValue = Ok (Just value)
    , loadedFieldValue = Just value
    }


initInputCluster : List FieldScope -> Field -> Maybe InputCluster
initInputCluster fieldScopes field =
    case field.fieldValue of
        StringValue v ->
            List.map (initInputFieldInstance field.fieldLocator v) fieldScopes
                |> StringCluster
                |> Just


init : ConfigGroup -> List Field -> FieldGroup
init configGroup fields =
    let
        scopes =
            fieldScopes configGroup

        selectize =
            List.filterMap (initSelectizeCluster scopes) fields

        input =
            List.filterMap (initInputCluster scopes) fields
    in
        { selectize = selectize
        , input = input
        }
