import { TreeNode, treeFormat } from "./recursTree";
import { llngConfig } from "./types";
export declare function findElementByTitleOrValue(arr: TreeNode[], searchTerm: string, parent?: string): TreeNode | undefined;
export declare function findElementInConf(config: llngConfig, node: treeFormat): any;
export declare function changeElementInConf(config: llngConfig, node: treeFormat, obj: any): true | undefined;
