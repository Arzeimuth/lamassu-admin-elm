module ConfigDecoder exposing (..)

import Json.Decode exposing (..)
import ConfigTypes exposing (..)
import SelectizeHelpers exposing (..)


fieldScopeDecoder : Decoder FieldScope
fieldScopeDecoder =
    object2 FieldScope
        ("crypto" := cryptoDecoder)
        ("machine" := machineDecoder)


fieldLocatorDecoder : Decoder FieldLocator
fieldLocatorDecoder =
    object2 FieldLocator
        ("fieldScope" := fieldScopeDecoder)
        ("code" := string)


string2machine : String -> Machine
string2machine s =
    if s == "global" then
        GlobalMachine
    else
        MachineId s


machineDecoder : Decoder Machine
machineDecoder =
    map string2machine string


cryptoDecoder : Decoder Crypto
cryptoDecoder =
    map stringToCrypto string


displayRecDecoder : Decoder DisplayRec
displayRecDecoder =
    object2 DisplayRec
        ("code" := string)
        ("display" := string)


machineDisplayDecoder : Decoder MachineDisplay
machineDisplayDecoder =
    object2 MachineDisplay
        ("machine" := machineDecoder)
        ("display" := string)


cryptoDisplayDecoder : Decoder CryptoDisplay
cryptoDisplayDecoder =
    object2 CryptoDisplay
        ("crypto" := cryptoDecoder)
        ("display" := string)


string2ConfigScope : String -> Result String ConfigScope
string2ConfigScope s =
    case s of
        "global" ->
            Ok Global

        "specific" ->
            Ok Specific

        "both" ->
            Ok Both

        _ ->
            Err ("No such ConfigScope " ++ s)


inputFieldTypeDecoder : String -> Decoder FieldType
inputFieldTypeDecoder s =
    (case s of
        "string" ->
            succeed FieldStringType

        "percentage" ->
            succeed FieldPercentageType

        "integer" ->
            succeed FieldIntegerType

        "onOff" ->
            succeed FieldOnOffType

        _ ->
            fail ("No such FieldType " ++ s)
    )
        |> map FieldTypeInput


selectizeFieldTypeDecoder : String -> Decoder FieldType
selectizeFieldTypeDecoder s =
    (case s of
        "account" ->
            map FieldAccountType ("accountClass" := string)

        "currency" ->
            succeed FieldCurrencyType

        "language" ->
            succeed FieldLanguageType

        _ ->
            fail ("No such FieldType " ++ s)
    )
        |> map FieldTypeSelectize


configScopeDecoder : Decoder ConfigScope
configScopeDecoder =
    customDecoder string string2ConfigScope


fieldTypeDecoder : String -> Decoder FieldType
fieldTypeDecoder fieldType =
    oneOf [ inputFieldTypeDecoder fieldType, selectizeFieldTypeDecoder fieldType ]


fieldDescriptorDecoder : Decoder FieldDescriptor
fieldDescriptorDecoder =
    object3 FieldDescriptor
        ("code" := string)
        ("display" := string)
        (("fieldType" := string) `andThen` fieldTypeDecoder)


configSchemaDecoder : Decoder ConfigSchema
configSchemaDecoder =
    object5 ConfigSchema
        ("code" := string)
        ("display" := string)
        ("cryptoScope" := configScopeDecoder)
        ("machineScope" := configScopeDecoder)
        ("entries" := list fieldDescriptorDecoder)


stringTuple : Decoder ( String, String )
stringTuple =
    tuple2 (,) string string


componentFieldInstanceRecDecoder :
    (FieldScope -> Maybe valueType -> componentType)
    -> valueType
    -> Decoder (ComponentFieldInstanceRec valueType componentType)
componentFieldInstanceRecDecoder initComponent val =
    ("fieldScope" := fieldScopeDecoder)
        `andThen`
            (\fieldScope ->
                succeed
                    { fieldScope = fieldScope
                    , fieldValue = Ok (Just val)
                    , loadedValue = Just val
                    , componentModel = initComponent fieldScope (Just val)
                    }
            )


fieldInstanceRecDecoder : valueType -> Decoder (FieldInstanceRec valueType)
fieldInstanceRecDecoder val =
    ("fieldScope" := fieldScopeDecoder)
        `andThen`
            (\fieldScope ->
                succeed
                    { fieldScope = fieldScope
                    , fieldValue = Ok (Just val)
                    , loadedValue = Just val
                    }
            )


classedFieldInstanceDecoder : ConfigData -> String -> Decoder FieldInstance
classedFieldInstanceDecoder configData class =
    ("fieldType" := string)
        `andThen`
            (\fieldType ->
                case fieldType of
                    "currency" ->
                        ("fieldValue" := string)
                            `andThen` (componentFieldInstanceRecDecoder (initAccountSelectize configData class))
                            |> map FieldAccountInstance
                            |> map FieldSelectizeInstance

                    _ ->
                        fail ("Unsupported " ++ fieldType)
            )


fieldInstanceDecoder : ConfigData -> Decoder FieldInstance
fieldInstanceDecoder configData =
    ("fieldType" := string)
        `andThen`
            (\fieldType ->
                case fieldType of
                    "string" ->
                        ("fieldValue" := string)
                            `andThen` fieldInstanceRecDecoder
                            |> map FieldStringInstance
                            |> map FieldInputInstance

                    "percentage" ->
                        ("fieldValue" := float)
                            `andThen` fieldInstanceRecDecoder
                            |> map FieldPercentageInstance
                            |> map FieldInputInstance

                    "integer" ->
                        ("fieldValue" := int)
                            `andThen` fieldInstanceRecDecoder
                            |> map FieldIntegerInstance
                            |> map FieldInputInstance

                    "onOff" ->
                        ("fieldValue" := bool)
                            `andThen` fieldInstanceRecDecoder
                            |> map FieldOnOffInstance
                            |> map FieldInputInstance

                    "currency" ->
                        ("fieldValue" := string)
                            `andThen` (componentFieldInstanceRecDecoder (initCurrencySelectize configData))
                            |> map FieldCurrencyInstance
                            |> map FieldSelectizeInstance

                    "language" ->
                        ("fieldValue" := list string)
                            `andThen` (componentFieldInstanceRecDecoder (initLanguageSelectize configData))
                            |> map FieldLanguageInstance
                            |> map FieldSelectizeInstance

                    _ ->
                        fail ("Unsupported " ++ fieldType)
            )


fieldGroupDecoder : ConfigData -> Decoder FieldGroup
fieldGroupDecoder configData =
    ("fieldCode" := string)
        `andThen`
            (\fieldCode ->
                if fieldCode == "account" then
                    (("fieldClass" := string)
                        `andThen`
                            (\fieldClass ->
                                (object3 ClassedFieldGroupType
                                    ("fieldCode" := string)
                                    ("fieldInstances" := list (classedFieldInstanceDecoder configData fieldClass))
                                    (succeed fieldClass)
                                )
                            )
                    )
                        |> map ClassedFieldGroup
                else
                    (object2 UnclassedFieldGroupType
                        ("fieldCode" := string)
                        ("fieldInstances" := list (fieldInstanceDecoder configData))
                    )
                        |> map UnclassedFieldGroup
            )


configGroupDecoderHelper : ConfigData -> Decoder ConfigGroup
configGroupDecoderHelper configData =
    object3 ConfigGroup
        ("schema" := configSchemaDecoder)
        ("values" := list (fieldGroupDecoder configData))
        (succeed configData)


configGroupDecoder : Decoder ConfigGroup
configGroupDecoder =
    ("data" := configDataDecoder)
        `andThen` configGroupDecoderHelper


accountRecDecoder : Decoder AccountRec
accountRecDecoder =
    oneOf
        [ object4 AccountRec
            ("code" := string)
            ("display" := string)
            ("class" := string)
            ("cryptos" := map Just (list cryptoDecoder))
        , object4 AccountRec
            ("code" := string)
            ("display" := string)
            ("class" := string)
            (succeed Nothing)
        ]


configDataDecoder : Decoder ConfigData
configDataDecoder =
    object5 ConfigData
        ("cryptos" := list cryptoDisplayDecoder)
        ("currencies" := list displayRecDecoder)
        ("languages" := list displayRecDecoder)
        ("accounts" := list accountRecDecoder)
        ("machines" := list machineDisplayDecoder)
