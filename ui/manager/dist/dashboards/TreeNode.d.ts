import { NodeApi } from "react-arborist";
import { treeFormat } from "../utils/recursTree";
import { llngConfig } from "../utils/types";
export declare function TreeNodeType({ node, config, }: {
    node: NodeApi<treeFormat>;
    config: llngConfig;
}): import("react/jsx-runtime").JSX.Element;
