module CoreTypes
    exposing
        ( Msg(..)
        , Category(..)
        , Route(..)
        , MachineSubRoute(..)
        , machineSubRouteToString
        )

import Pair
import Account
import Config
import Machine


type Category
    = AccountCat
    | ConfigCat
    | MachineCat


machineSubRouteToString : MachineSubRoute -> String
machineSubRouteToString machineSubRoute =
    case machineSubRoute of
        MachineActions ->
            "actions"


type MachineSubRoute
    = MachineActions


type Route
    = AccountRoute String
    | PairRoute
    | ConfigRoute String (Maybe String)
    | MachineRoute MachineSubRoute
    | NotFoundRoute


type Msg
    = AccountMsg Account.Msg
    | PairMsg Pair.Msg
    | ConfigMsg Config.Msg
    | MachineMsg Machine.Msg
    | LoadAccounts (List ( String, String ))
    | NewRoute (Maybe Category) Route
