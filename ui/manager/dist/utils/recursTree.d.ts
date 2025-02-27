import { llngConfig } from "./types";
export interface TreeNode {
    help?: string;
    cnodes?: TreeNode[];
    template?: string;
    _nodes_cond?: TreeNode[];
    _nodes?: TreeNode[];
    title: string;
    id?: string;
    type?: string;
    get?: string;
}
export interface treeFormat {
    id: string;
    name: string;
    type?: string;
    children?: treeFormat[];
    app?: string;
    help?: string;
}
export declare const confFieldsEq: {
    casAppMetaDataNode: string;
    casSrvMetaDataNode: string;
    oidcOPMetaDataNode: string;
    oidcRPMetaDataNode: string;
    samlIDPMetaDataNode: string;
    samlSPMetaDataNode: string;
    virtualHost: string;
};
export declare function recursTree(tree: TreeNode, config: llngConfig, parentId: string, app?: string): treeFormat;
