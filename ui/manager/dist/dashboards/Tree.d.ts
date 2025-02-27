/// <reference types="react" />
import { TreeApi } from "react-arborist";
import { TreeNode, treeFormat } from "../utils/recursTree";
import { llngConfig } from "../utils/types";
import "./Tree.css";
export declare function ToggleConfTree(itemId: string, treeRef: React.RefObject<TreeApi<treeFormat>>, tree: TreeNode[], config: llngConfig, setItems: React.Dispatch<React.SetStateAction<treeFormat[] | undefined>>): void;
export default function TreeRender({ tree, config, }: {
    tree?: TreeNode[];
    config: llngConfig;
}): import("react/jsx-runtime").JSX.Element;
