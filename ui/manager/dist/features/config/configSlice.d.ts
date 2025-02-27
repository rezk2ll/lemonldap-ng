import { treeFormat } from "../../utils/recursTree";
import { MetaData, llngConfig } from "../../utils/types";
export interface ConfigState {
    loading: boolean;
    error: {
        has: boolean;
        errorContent: string;
    };
    data: {
        metadata: MetaData;
        config: llngConfig;
    };
    saveResponse?: Record<string, Record<string, Array<Record<string, string>>>>;
}
export declare const initialState: ConfigState;
export declare const getConfigAsync: import("@reduxjs/toolkit").AsyncThunk<Object, number | undefined, {
    state?: unknown;
    dispatch?: import("redux").Dispatch<import("redux").AnyAction> | undefined;
    extra?: unknown;
    rejectValue?: unknown;
    serializedErrorType?: unknown;
    pendingMeta?: unknown;
    fulfilledMeta?: unknown;
    rejectedMeta?: unknown;
}>;
export declare const getPartialConfigAsync: import("@reduxjs/toolkit").AsyncThunk<Object, void, {
    state?: unknown;
    dispatch?: import("redux").Dispatch<import("redux").AnyAction> | undefined;
    extra?: unknown;
    rejectValue?: unknown;
    serializedErrorType?: unknown;
    pendingMeta?: unknown;
    fulfilledMeta?: unknown;
    rejectedMeta?: unknown;
}>;
export declare const saveConfigAsync: import("@reduxjs/toolkit").AsyncThunk<Object, llngConfig, {
    state?: unknown;
    dispatch?: import("redux").Dispatch<import("redux").AnyAction> | undefined;
    extra?: unknown;
    rejectValue?: unknown;
    serializedErrorType?: unknown;
    pendingMeta?: unknown;
    fulfilledMeta?: unknown;
    rejectedMeta?: unknown;
}>;
export declare const savePartialConfigAsync: import("@reduxjs/toolkit").AsyncThunk<Object, llngConfig, {
    state?: unknown;
    dispatch?: import("redux").Dispatch<import("redux").AnyAction> | undefined;
    extra?: unknown;
    rejectValue?: unknown;
    serializedErrorType?: unknown;
    pendingMeta?: unknown;
    fulfilledMeta?: unknown;
    rejectedMeta?: unknown;
}>;
export declare const setError: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/setError">, removeError: import("@reduxjs/toolkit").ActionCreatorWithoutPayload<"config/removeError">, toggleMaintenance: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/toggleMaintenance">, toggleCAS: import("@reduxjs/toolkit").ActionCreatorWithoutPayload<"config/toggleCAS">, toggleOIDC: import("@reduxjs/toolkit").ActionCreatorWithoutPayload<"config/toggleOIDC">, toggleSAML: import("@reduxjs/toolkit").ActionCreatorWithoutPayload<"config/toggleSAML">, toggleGET: import("@reduxjs/toolkit").ActionCreatorWithoutPayload<"config/toggleGET">, toggleOID2: import("@reduxjs/toolkit").ActionCreatorWithoutPayload<"config/toggleOID2">, saveOIDCPrivSig: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/saveOIDCPrivSig">, saveOIDCPrivIdSig: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/saveOIDCPrivIdSig">, saveOIDCPubSig: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/saveOIDCPubSig">, saveSAMLPrivIdSig: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/saveSAMLPrivIdSig">, saveSAMLPrivSig: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/saveSAMLPrivSig">, saveSAMLPubSig: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/saveSAMLPubSig">, updateLocationRule: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    appName: string;
    locationRules: Record<string, string>;
}, "config/updateLocationRule">, updateDefaultLocationRule: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    appName: string;
    rule: string;
}, "config/updateDefaultLocationRule">, newLocationRule: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newLocationRule">, delLocationRule: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    key: string;
}, "config/delLocationRule">, newVhostHeaders: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newVhostHeaders">, delVhostHeader: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    key: string;
}, "config/delVhostHeader">, updateVhostHeaders: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    data: Record<string, string>;
}, "config/updateVhostHeaders">, updateVhostPost: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    appName: string;
    post: Record<string, Record<string, string>>;
}, "config/updateVhostPost">, delVhostPost: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    key: string;
}, "config/delVhostPost">, newVhostPost: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newVhostPost">, updateVhostOptions: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    option: string;
    value: boolean | number | string;
}, "config/updateVhostOptions">, changeAppName: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    newName: string;
}, "config/changeAppName">, delApp: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    type: string;
}, "config/delApp">, dupApp: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    oldName: string;
    newAppName: string;
}, "config/dupApp">, newApp: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    type: string;
}, "config/newApp">, updateOIDCclientID: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    id: string;
}, "config/updateOIDCclientID">, updateOIDCPrivateClient: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    privateClient: string;
}, "config/updateOIDCPrivateClient">, updateOIDCPublicClient: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    publicClient: number;
}, "config/updateOIDCPublicClient">, updateCASexportedVars: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    data: Record<string, string>;
}, "config/updateCASexportedVars">, newCASexportedVars: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newCASexportedVars">, delCASexportedVars: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    key: string;
}, "config/delCASexportedVars">, delCASAppMetaDataMacros: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    key: string;
}, "config/delCASAppMetaDataMacros">, updateCASAppMetaDataMacros: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    data: Record<string, string>;
}, "config/updateCASAppMetaDataMacros">, newCASAppMetaDataMacros: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newCASAppMetaDataMacros">, updateCASOptions: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    option: string;
    value: boolean | number | string;
}, "config/updateCASOptions">, updateSamlSPMetadata: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    data: string;
}, "config/updateSamlSPMetadata">, newSAMLSPMetaDataMacros: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newSAMLSPMetaDataMacros">, updateSAMLSPMetaDataMacros: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    data: Record<string, string>;
}, "config/updateSAMLSPMetaDataMacros">, delSAMLSPMetaDataMacros: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    key: string;
}, "config/delSAMLSPMetaDataMacros">, updateSamlMetadataExportedAttribute: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    appName: string;
    data: Record<string, string>;
    fieldName: string;
}, "config/updateSamlMetadataExportedAttribute">, newSamlMetadataExportedAttribute: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    appName: string;
    fieldName: string;
}, "config/newSamlMetadataExportedAttribute">, delSamlMetadataExportedAttribute: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    appName: string;
    key: string;
    fieldName: string;
}, "config/delSamlMetadataExportedAttribute">, updateSamlMetaDataOptions: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    option: string;
    value: string | number;
}, "config/updateSamlMetaDataOptions">, newOIDCRPMetaDataMacros: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newOIDCRPMetaDataMacros">, updateOIDCRPMetaDataMacros: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    data: Record<string, string>;
}, "config/updateOIDCRPMetaDataMacros">, delOIDCRPMetaDataMacros: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    key: string;
}, "config/delOIDCRPMetaDataMacros">, updateOidcRPMetaDataExportedVars: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    appName: string;
    data: Record<string, string>;
}, "config/updateOidcRPMetaDataExportedVars">, newOidcRPMetaDataExportedVars: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newOidcRPMetaDataExportedVars">, delOidcRPMetaDataExportedVars: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    appName: string;
    key: string;
}, "config/delOidcRPMetaDataExportedVars">, updateOidcMetaDataOptions: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    option: string;
    value: string | number;
}, "config/updateOidcMetaDataOptions">, delOidcRPMetaDataOptionsExtraClaims: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    key: string;
}, "config/delOidcRPMetaDataOptionsExtraClaims">, newOidcRPMetaDataOptionsExtraClaims: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newOidcRPMetaDataOptionsExtraClaims">, updateOidcRPMetaDataOptionsExtraClaims: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    data: Record<string, string>;
}, "config/updateOidcRPMetaDataOptionsExtraClaims">, newOidcRPMetaDataScopeRules: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newOidcRPMetaDataScopeRules">, delOidcRPMetaDataScopeRules: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    key: string;
}, "config/delOidcRPMetaDataScopeRules">, updateOidcRPMetaDataScopeRules: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    data: Record<string, string>;
}, "config/updateOidcRPMetaDataScopeRules">, updateOidcRPMetaDataOptionsJwks: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    data: string;
}, "config/updateOidcRPMetaDataOptionsJwks">, updateAuthParams: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    param: string;
    value: string;
}, "config/updateAuthParams">, updateConfigParams: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    param: keyof llngConfig;
    value: string | number | boolean | {
        k: string;
        v: string;
    }[] | Record<string, string> | Record<string, Record<string, string>> | Record<string, Record<string, string | number | Record<string, string | number | Record<string, string>>>> | {
        k: string;
        v: string;
    }[] | Record<string, object> | Record<string, Record<string, string | number | boolean>> | Record<string, Record<string, string | Record<string, string | number>>> | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | string[] | Record<string, Record<string, string | number>> | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | Record<string, Record<string, Record<string, string>>> | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | Record<string, {
        type?: string | undefined;
        over?: Record<string, string | number> | undefined;
        register?: number | boolean | undefined;
    }> | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | null | undefined;
}, "config/updateConfigParams">, delCombParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/delCombParam">, newCombParam: import("@reduxjs/toolkit").ActionCreatorWithoutPayload<"config/newCombParam">, updateCombParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<Record<string, Record<string, string | Record<string, string | number>>>, "config/updateCombParam">, newCombOverParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newCombOverParam">, delCombOverParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    key: string;
}, "config/delCombOverParam">, updateCombOverParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    data: Record<string, string>;
}, "config/updateCombOverParam">, newChoiceParam: import("@reduxjs/toolkit").ActionCreatorWithoutPayload<"config/newChoiceParam">, delChoiceParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/delChoiceParam">, updateChoiceParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<Record<string, string>, "config/updateChoiceParam">, newChoiceOverParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newChoiceOverParam">, delChoiceOverParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    key: string;
}, "config/delChoiceOverParam">, updateChoiceOverParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    data: Record<string, string>;
}, "config/updateChoiceOverParam">, newModuleOpt: import("@reduxjs/toolkit").ActionCreatorWithPayload<keyof llngConfig, "config/newModuleOpt">, delModuleOpt: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: keyof llngConfig;
    key: string;
}, "config/delModuleOpt">, updateModuleOpt: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: keyof llngConfig;
    data: string | number | boolean | {
        k: string;
        v: string;
    }[] | Record<string, string> | Record<string, Record<string, string>> | Record<string, Record<string, string | number | Record<string, string | number | Record<string, string>>>> | {
        k: string;
        v: string;
    }[] | Record<string, object> | Record<string, Record<string, string | number | boolean>> | Record<string, Record<string, string | Record<string, string | number>>> | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | string[] | Record<string, Record<string, string | number>> | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | Record<string, Record<string, Record<string, string>>> | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | Record<string, {
        type?: string | undefined;
        over?: Record<string, string | number> | undefined;
        register?: number | boolean | undefined;
    }> | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | {
        k: string;
        v: string;
    }[] | null | undefined;
}, "config/updateModuleOpt">, updateGetParamHostname: import("@reduxjs/toolkit").ActionCreatorWithPayload<Record<string, Record<string, string>>, "config/updateGetParamHostname">, delGetParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/delGetParam">, updateGetParamOption: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    data: Record<string, string>;
}, "config/updateGetParamOption">, newGetParam: import("@reduxjs/toolkit").ActionCreatorWithoutPayload<"config/newGetParam">, delGetParamOption: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    key: string;
}, "config/delGetParamOption">, newGetParamOption: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newGetParamOption">, changeConf: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    node: treeFormat;
    newValue: any;
}, "config/changeConf">, newSfExtraOverParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newSfExtraOverParam">, updateSfExtraOverParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    data: Record<string, string>;
}, "config/updateSfExtraOverParam">, deleteSfExtraOverParam: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    name: string;
    key: string;
}, "config/deleteSfExtraOverParam">, newCategory: import("@reduxjs/toolkit").ActionCreatorWithoutPayload<"config/newCategory">, renameCategory: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    id: string;
    newname: string;
}, "config/renameCategory">, delCategory: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/delCategory">, newApplication: import("@reduxjs/toolkit").ActionCreatorWithPayload<string, "config/newApplication">, changeApplicationField: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    catid: string;
    id: string;
    field: string;
    value: string;
}, "config/changeApplicationField">, delApplication: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    catid: string;
    id: string;
}, "config/delApplication">, moveCat: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    category: string;
    direction: string;
}, "config/moveCat">, moveApp: import("@reduxjs/toolkit").ActionCreatorWithPayload<{
    category: string;
    appName: string;
    direction: string;
}, "config/moveApp">;
declare const _default: import("redux").Reducer<ConfigState, import("redux").AnyAction>;
export default _default;
