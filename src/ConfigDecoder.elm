module ConfigDecoder exposing (..)

import Json.Decode exposing (..)
import FieldSetTypes exposing (FieldStatus)
import FieldSetDecoder exposing (fieldStatusDecoder, fieldStatusValueDecoder)
import ConfigTypes exposing (..)


nullOr : Decoder a -> Decoder (Maybe a)
nullOr decoder =
    oneOf
        [ null Nothing
        , map Just decoder
        ]


fieldValueTypeDecoder : String -> Decoder FieldValue
fieldValueTypeDecoder fieldType =
    case fieldType of
        "string" ->
            map FieldString ("value" := nullOr string)

        "percentage" ->
            map FieldPercentage ("value" := nullOr int)

        "integer" ->
            map FieldInteger ("value" := nullOr int)

        _ ->
            fail ("Unsupported field type: " ++ fieldType)


fieldValueDecoder : Decoder FieldValue
fieldValueDecoder =
    ("fieldType" := string) `andThen` fieldValueTypeDecoder


fieldStatusDecoder : Decoder FieldStatus
fieldStatusDecoder =
    ("code" := string) `andThen` fieldStatusValueDecoder


fieldDecoder : Decoder Field
fieldDecoder =
    object5 Field
        ("code" := string)
        ("display" := string)
        ("value" := fieldValueDecoder)
        ("value" := fieldValueDecoder)
        ("status" := fieldStatusDecoder)


fieldSetDecoder =
    object1 FieldSet
        ("fields" := list fieldDecoder)


string2machine : String -> Machine
string2machine s =
    if s == "global" then
        GlobalMachine
    else
        MachineId s


machineDecoder : Decoder Machine
machineDecoder =
    map string2machine string


machineConfigDecoder : Decoder MachineConfig
machineConfigDecoder =
    object2 MachineConfig
        ("machine" := machineDecoder)
        ("fieldSet" := fieldSetDecoder)


string2Crypto : String -> Crypto
string2Crypto s =
    if s == "global" then
        GlobalCrypto
    else
        CryptoCode s


cryptoDecoder : Decoder Crypto
cryptoDecoder =
    map string2Crypto string


cryptoConfigDecoder : Decoder CryptoConfig
cryptoConfigDecoder =
    object2 CryptoConfig
        ("crypto" := cryptoDecoder)
        ("machineConfigs" := list machineConfigDecoder)


cryptoDescriptorDecoder : Decoder CryptoDescriptor
cryptoDescriptorDecoder =
    object2 CryptoDescriptor
        ("crypto" := cryptoDecoder)
        ("display" := string)


displayRecDecoder : Decoder DisplayRec
displayRecDecoder =
    object2 DisplayRec
        ("code" := string)
        ("display" := string)


string2configScope : String -> Result String ConfigScope
string2configScope s =
    case s of
        "global" ->
            Ok Global

        "specific" ->
            Ok Specific

        "both" ->
            Ok Both

        _ ->
            Err ("No such ConfigScope " ++ s)


configScopeDecoder : Decoder ConfigScope
configScopeDecoder =
    customDecoder string string2configScope


configGroupDecoder : Decoder ConfigGroup
configGroupDecoder =
    object5 ConfigGroup
        ("group" := displayRecDecoder)
        ("cryptoScope" := configScopeDecoder)
        ("machineScope" := configScopeDecoder)
        ("cryptoConfigs" := list cryptoConfigDecoder)
        ("data" := configDataDecoder)


accountRecDecoder : Decoder AccountRec
accountRecDecoder =
    object3 AccountRec
        ("code" := string)
        ("display" := string)
        ("class" := string)


configDataDecoder : Decoder ConfigData
configDataDecoder =
    object3 ConfigData
        ("currencies" := list displayRecDecoder)
        ("languages" := list displayRecDecoder)
        ("accounts" := list accountRecDecoder)
