module ConfigTypes exposing (..)

import Selectize


type alias DisplayRec =
    { code : String
    , display : String
    }


type Crypto
    = CryptoCode String
    | GlobalCrypto


type Machine
    = MachineId String
    | GlobalMachine


type alias MachineDisplay =
    { machine : Machine
    , display : String
    }


type alias CryptoDisplay =
    { crypto : Crypto
    , display : String
    }


type ConfigScope
    = Global
    | Specific
    | Both


type FieldError
    = FieldParsingError String
    | FieldValidationError String


type alias FieldHolder valueType =
    Result FieldError (Maybe valueType)


type alias FieldScope =
    { crypto : Crypto
    , machine : Machine
    }


type alias FieldLocator =
    { fieldScope : FieldScope
    , code : String
    }


type alias SelectizeModel =
    Selectize.Model String


type InputCluster
    = FieldStringCluster String (List (FieldInstance String ()))
    | FieldPercentageCluster String (List (FieldInstance Float ()))
    | FieldIntegerCluster String (List (FieldInstance Int ()))
    | FieldOnOffCluster String (List (FieldInstance Bool ()))


type SelectizeCluster
    = FieldAccountCluster String String (List (FieldInstance String SelectizeModel))
    | FieldCurrencyCluster String (List (FieldInstance String SelectizeModel))
    | FieldLanguageCluster String (List (FieldInstance (List String) SelectizeModel))


type FieldCluster
    = FieldInputCluster InputCluster
    | FieldSelectizeCluster SelectizeCluster


type alias FieldInstance valueType componentModel =
    { fieldScope : FieldScope
    , fieldValue : FieldHolder valueType
    , loadedValue : Maybe valueType
    , componentModel : componentModel
    }


type SelectizeFieldType
    = FieldAccountType String
    | FieldCurrencyType
    | FieldLanguageType


type InputFieldType
    = FieldStringType
    | FieldPercentageType
    | FieldIntegerType
    | FieldOnOffType


type FieldType
    = FieldTypeInput InputFieldType
    | FieldTypeSelectize SelectizeFieldType


type alias FieldDescriptor =
    { code : String
    , display : String
    , fieldType : FieldType
    }


type alias ConfigSchema =
    { code : String
    , display : String
    , cryptoScope : ConfigScope
    , machineScope : ConfigScope
    , entries : List FieldDescriptor
    }


type alias ConfigGroup =
    { schema : ConfigSchema
    , values : List FieldCluster
    , data : ConfigData
    }


type alias AccountRec =
    { code : String
    , display : String
    , class : String
    , cryptos : Maybe (List Crypto)
    }


type alias ConfigData =
    { cryptos : List CryptoDisplay
    , currencies : List DisplayRec
    , languages : List DisplayRec
    , accounts : List AccountRec
    , machines : List MachineDisplay
    }


globalCryptoDisplay : CryptoDisplay
globalCryptoDisplay =
    { crypto = GlobalCrypto
    , display = "Global"
    }


globalMachineDisplay : MachineDisplay
globalMachineDisplay =
    { machine = GlobalMachine
    , display = "Global"
    }



-- fieldValueToString : FieldValue -> String
-- fieldValueToString fieldValue =
--     case fieldValue of
--         FieldStringValue v ->
--             v
--
--         FieldPercentageValue v ->
--             toString v
--
--         FieldIntegerValue v ->
--             toString v
--
--         FieldOnOffValue v ->
--             if v then
--                 "on"
--             else
--                 "off"
--
--         FieldAccountValue _ v ->
--             v
--
--         FieldCurrencyValue v ->
--             v
--
--         FieldLanguageValue v ->
--             Debug.crash "Can't turn languages into string"


machineToString : Machine -> String
machineToString machine =
    case machine of
        GlobalMachine ->
            "global"

        MachineId machineId ->
            machineId


cryptoToString : Crypto -> String
cryptoToString crypto =
    case crypto of
        GlobalCrypto ->
            "global"

        CryptoCode code ->
            code


listMachines : ConfigGroup -> List MachineDisplay
listMachines configGroup =
    case configGroup.schema.machineScope of
        Specific ->
            configGroup.data.machines

        Global ->
            [ globalMachineDisplay ]

        Both ->
            globalMachineDisplay :: configGroup.data.machines


listCryptos : ConfigGroup -> List CryptoDisplay
listCryptos configGroup =
    case configGroup.schema.cryptoScope of
        Specific ->
            configGroup.data.cryptos

        Global ->
            [ globalCryptoDisplay ]

        Both ->
            globalCryptoDisplay :: configGroup.data.cryptos


fieldScopes : ConfigGroup -> List FieldScope
fieldScopes configGroup =
    let
        machines =
            List.map .machine (listMachines configGroup)

        cryptos =
            List.map .crypto (listCryptos configGroup)

        cryptoScopes crypto =
            List.map (\machine -> { machine = machine, crypto = crypto }) machines
    in
        List.concatMap cryptoScopes cryptos


stringToCrypto : String -> Crypto
stringToCrypto string =
    case string of
        "global" ->
            GlobalCrypto

        _ ->
            CryptoCode string
