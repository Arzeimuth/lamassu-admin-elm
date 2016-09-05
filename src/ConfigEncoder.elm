module ConfigEncoder exposing (..)

import Json.Encode exposing (..)
import List
import ConfigTypes exposing (..)


encodeFieldValueObject : String -> Value -> Value
encodeFieldValueObject fieldTypeStr value =
    object [ ( "fieldType", string fieldTypeStr ), ( "value", value ) ]


encodeFieldValue : Maybe FieldValue -> Value
encodeFieldValue maybeFieldValue =
    case maybeFieldValue of
        Nothing ->
            null

        Just fieldValue ->
            case fieldValue of
                FieldStringValue value ->
                    encodeFieldValueObject "string" (string value)

                FieldPercentageValue value ->
                    encodeFieldValueObject "percentage" (float value)

                FieldIntegerValue value ->
                    encodeFieldValueObject "integer" (int value)

                FieldOnOffValue value ->
                    encodeFieldValueObject "onOff" (bool value)

                FieldAccountValue accountClass value ->
                    object
                        [ ( "fieldType", string "account" )
                        , ( "accountClass", string accountClass )
                        , ( "value", string value )
                        ]

                FieldCurrencyValue value ->
                    encodeFieldValueObject "currency" (string value)


encodeCrypto : Crypto -> Value
encodeCrypto crypto =
    case crypto of
        CryptoCode cryptoCode ->
            string cryptoCode

        GlobalCrypto ->
            string "global"


encodeMachine : Machine -> Value
encodeMachine machine =
    case machine of
        MachineId machineId ->
            string machineId

        GlobalMachine ->
            string "global"


encodeFieldScope : FieldScope -> Value
encodeFieldScope fieldScope =
    Json.Encode.object
        [ ( "crypto", encodeCrypto fieldScope.crypto )
        , ( "machine", encodeMachine fieldScope.machine )
        ]


encodeFieldLocator : FieldLocator -> Value
encodeFieldLocator fieldLocator =
    Json.Encode.object
        [ ( "fieldScope", encodeFieldScope fieldLocator.fieldScope )
        , ( "code", string fieldLocator.code )
        ]


encodeFieldResult : FieldInstance -> Maybe Value
encodeFieldResult fieldInstance =
    let
        encode maybeFieldValue =
            Json.Encode.object
                [ ( "fieldLocator", encodeFieldLocator fieldInstance.fieldLocator )
                , ( "fieldValue", encodeFieldValue maybeFieldValue )
                ]

        onlyDirty maybeFieldValue =
            if (fieldInstance.loadedFieldValue == maybeFieldValue) then
                Nothing
            else
                Just (encode maybeFieldValue)
    in
        Result.toMaybe fieldInstance.fieldValue
            `Maybe.andThen` onlyDirty


encodeResults : String -> List FieldInstance -> Value
encodeResults configGroupCode fieldInstances =
    Json.Encode.object
        [ ( "groupCode", string configGroupCode )
        , ( "values", list (List.filterMap encodeFieldResult fieldInstances) )
        ]
