module ConfigGroup exposing (Msg, update, view)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (defaultValue, placeholder, checked, type', name)
import ConfigTypes exposing (..)
import List
import Maybe exposing (oneOf)
import Html.CssHelpers
import Html.Keyed
import CssClasses
import VirtualDom


{ id, class, classList } =
    Html.CssHelpers.withNamespace "lamassuAdmin"
type alias Model =
    ConfigGroup



-- UPDATE


type Msg
    = Input Crypto Machine String String


toMatchedFieldValue : Crypto -> Machine -> String -> Field -> Maybe FieldValue
toMatchedFieldValue crypto machine fieldCode field =
    let
        maybeFieldValue =
            case field.fieldValue of
                Err _ ->
                    field.loadedFieldValue

                Ok originalMaybeFieldValue ->
                    originalMaybeFieldValue
    in
        if (isOfFieldClass crypto machine fieldCode field) then
            maybeFieldValue
        else
            Nothing


pickField : List Field -> Crypto -> Machine -> String -> Maybe FieldValue
pickField fields crypto machine fieldCode =
    List.filterMap (toMatchedFieldValue crypto machine fieldCode) fields
        |> List.head


isOfFieldClass : Crypto -> Machine -> String -> Field -> Bool
isOfFieldClass crypto machine fieldCode field =
    field.crypto
        == crypto
        && field.machine
        == machine
        && field.code
        == fieldCode


isFieldClass : Field -> Field -> Bool
isFieldClass searchField field =
    isOfFieldClass searchField.crypto searchField.machine searchField.code field


placeField : List Field -> Field -> List Field
placeField fieldList field =
    let
        maybeOldField =
            List.filter (isFieldClass field) fieldList
                |> List.head

        newField =
            case maybeOldField of
                Nothing ->
                    field

                Just oldField ->
                    { oldField | fieldValue = field.fieldValue }
    in
        newField :: (List.filter (not << (isFieldClass field)) fieldList)


updateValues : Model -> Crypto -> Machine -> String -> String -> Model
updateValues model crypto machine fieldCode valueString =
    let
        maybeFieldDescriptor =
            List.filter (\fd -> fd.code == fieldCode) model.schema.entries
                |> List.head
    in
        case maybeFieldDescriptor of
            Just fieldDescriptor ->
                let
                    fieldValueHolder =
                        stringToFieldValue fieldDescriptor.fieldType valueString

                    field =
                        { code = fieldCode
                        , crypto = crypto
                        , machine = machine
                        , fieldValue = fieldValueHolder
                        , loadedFieldValue = Nothing
                        }

                    values =
                        placeField model.values field
                in
                    { model | values = values }

            Nothing ->
                model


update : Msg -> Model -> ( Model, Cmd Msg )
update (Input crypto machine fieldCode valueString) model =
    let
        newModel =
            updateValues model crypto machine fieldCode valueString
    in
        (Debug.log "DEBUG22" newModel) ! []



-- View


textInput crypto machine fieldDescriptor maybeFieldValue maybeFallbackFieldValue =
    let
        maybeSpecificString =
            Maybe.map fieldValueToString maybeFieldValue

        maybeFallbackString =
            Maybe.map fieldValueToString maybeFallbackFieldValue

        defaultString =
            Maybe.withDefault "" maybeSpecificString

        fallbackString =
            Maybe.withDefault "" maybeFallbackString

        cryptoString =
            cryptoToString crypto

        machineString =
            machineToString machine
    in
        input
            [ onInput (Input crypto machine fieldDescriptor.code)
            , defaultValue defaultString
            , placeholder fallbackString
            ]
            []


fieldInput : Crypto -> Machine -> FieldDescriptor -> Maybe FieldValue -> Maybe FieldValue -> Html Msg
fieldInput crypto machine fieldDescriptor maybeFieldValue maybeFallbackFieldValue =
    case fieldDescriptor.fieldType of
        FieldStringType ->
            textInput crypto machine fieldDescriptor maybeFieldValue maybeFallbackFieldValue

        FieldPercentageType ->
            textInput crypto machine fieldDescriptor maybeFieldValue maybeFallbackFieldValue

        FieldIntegerType ->
            textInput crypto machine fieldDescriptor maybeFieldValue maybeFallbackFieldValue

        FieldOnOffType ->
            -- TODO: Need to make a 3-state custom component
            textInput crypto machine fieldDescriptor maybeFieldValue maybeFallbackFieldValue

        FieldAccountType ->
            -- TODO: Need to turn into smart search field
            textInput crypto machine fieldDescriptor maybeFieldValue maybeFallbackFieldValue

        FieldCurrencyType ->
            -- TODO: Need to turn into smart search field
            textInput crypto machine fieldDescriptor maybeFieldValue maybeFallbackFieldValue


fieldComponent : Model -> Crypto -> Machine -> FieldDescriptor -> Html Msg
fieldComponent model crypto machine fieldDescriptor =
    let
        fieldCode =
            fieldDescriptor.code

        fieldType =
            fieldDescriptor.fieldType

        fields =
            model.values

        maybeGlobal =
            pickField fields GlobalCrypto GlobalMachine fieldCode

        maybeGlobalCrypto =
            pickField fields GlobalCrypto machine fieldCode

        maybeGlobalMachine =
            pickField fields crypto GlobalMachine fieldCode

        maybeSpecific =
            pickField fields crypto machine fieldCode

        maybeFallbackFieldValue =
            oneOf [ maybeSpecific, maybeGlobalMachine, maybeGlobalCrypto, maybeGlobal ]
    in
        fieldInput crypto machine fieldDescriptor maybeSpecific maybeFallbackFieldValue


cellView : Model -> Crypto -> Machine -> FieldDescriptor -> Html Msg
cellView model crypto machine fieldDescriptor =
    -- Note: keying here is needed to clear out fields when switching cryptos
    Html.Keyed.node "td"
        []
        [ ( (cryptoToString crypto)
                ++ "-"
                ++ (machineToString machine)
                ++ "-"
                ++ fieldDescriptor.code
          , fieldComponent model crypto machine fieldDescriptor
          )
        ]


globalRowClass : Machine -> VirtualDom.Property a
globalRowClass machine =
    case machine of
        GlobalMachine ->
            class [ CssClasses.ConfigTableGlobalRow ]

        _ ->
            class []


rowView : Model -> Crypto -> MachineDisplay -> Html Msg
rowView model crypto machineDisplay =
    tr [ globalRowClass machineDisplay.machine ]
        ((td [] [ text (machineDisplay.display) ])
            :: (List.map (cellView model crypto machineDisplay.machine)
                    model.schema.entries
               )
        )


headerCellView : FieldDescriptor -> Html Msg
headerCellView fieldDescriptor =
    td [] [ text fieldDescriptor.display ]


headerRowView : Model -> Crypto -> Html Msg
headerRowView model crypto =
    tr [] ((td [] []) :: List.map headerCellView model.schema.entries)


tableView : Model -> Crypto -> Html Msg
tableView model crypto =
    let
        headerRow =
            headerRowView model crypto

        machines =
            if (model.schema.machineScope == Specific) then
                model.data.machines
            else
                globalMachineDisplay :: model.data.machines

        rows =
            List.map (rowView model crypto) machines
    in
        table [ class [ CssClasses.ConfigTable ] ]
            [ thead [] [ headerRow ]
            , tbody [] rows
            ]


isField : String -> Field -> Bool
isField fieldCode field =
    field.code == fieldCode


view : Model -> Maybe Crypto -> Html Msg
view model maybeCrypto =
    let
        crypto =
            Maybe.withDefault GlobalCrypto maybeCrypto
    in
        div [ class [ CssClasses.ConfigTableContainer ] ]
            [ tableView model crypto ]
