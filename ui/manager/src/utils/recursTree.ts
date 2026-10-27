import { t } from "i18next";
import { attributes } from "../metadata";
import { menuApplicationKeys } from "./menu";
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
  // Id of the parent node ("root" for top-level nodes)
  parent?: string;
}

export const confFieldsEq = {
  casAppMetaDataNode: "casAppMetaDataExportedVars",
  casSrvMetaDataNode: "casSrvMetaDataExportedVars",
  oidcOPMetaDataNode: "oidcOPMetaDataExportedVars",
  oidcRPMetaDataNode: "oidcRPMetaDataOptions",
  samlIDPMetaDataNode: "samlIDPMetaDataXML",
  samlSPMetaDataNode: "samlSPMetaDataXML",
  virtualHost: "locationRules",
};

// Children are built on first access: a large configuration (hundreds of
// applications, each with its own subtree) would otherwise cost tens of
// thousands of nodes up front, most of which are never opened. The property is
// not enumerable so that serializing a node (Redux action payloads) does not
// walk the whole subtree.
function withChildren(
  node: treeFormat,
  build: () => treeFormat[]
): treeFormat {
  let children: treeFormat[] | undefined;
  Object.defineProperty(node, "children", {
    enumerable: false,
    configurable: true,
    get: () => (children ??= build()),
    set: (value: treeFormat[]) => {
      children = value;
    },
  });
  return node;
}

function nodeType(tree: TreeNode) {
  return tree.type || attributes[tree.title as keyof typeof attributes]?.type;
}

export function recursTree(
  tree: TreeNode,
  config: llngConfig,
  parentId: string,
  app?: string
): treeFormat {
  const id = `${parentId};${tree.title}`;
  if (tree.cnodes && typeof tree.cnodes === "object") {
    const nodeName = tree.title?.slice(0, -1) || "";
    if (Object.keys(confFieldsEq).includes(nodeName)) {
      const cnodes = tree.cnodes;
      return withChildren(
        {
          name: t(tree.title),
          help: tree.help,
          type: attributes[tree.title as keyof typeof attributes]?.type,
          id,
          app,
          parent: parentId,
        },
        () =>
          Object.keys(
            (config[
              confFieldsEq[
                nodeName as keyof typeof confFieldsEq
              ] as keyof llngConfig
            ] || {}) as Record<string, string>
          ).map((el) =>
            withChildren(
              {
                name: t(el),
                type: nodeName,
                app: el,
                id: `${id};${el}`,
                parent: id,
              },
              () =>
                cnodes.map((node: TreeNode) =>
                  recursTree(node, config, `${id};${el}`, el)
                )
            )
          )
      );
    }
  } else if (tree.cnodes === "applicationList") {
    const list = (config[tree.title as keyof llngConfig] || {}) as Record<
      string,
      Record<string, any>
    >;
    return withChildren(
      {
        name: t(tree.title),
        help: tree.help,
        type: nodeType(tree),
        id,
        parent: parentId,
      },
      () =>
        Object.keys(list)
          .sort((key1, key2) => list[key1].order - list[key2].order)
          .map((el) => ({
            name: list[el].catname,
            id: `${tree.title};${el}`,
            type: list[el].type,
            parent: id,
            children: menuApplicationKeys(list[el])
              .sort((key1, key2) => list[el][key1].order - list[el][key2].order)
              .map((key) => ({
                name: list[el][key].options.name,
                id: `${tree.title};${el};${key}`,
                type: "application",
                parent: `${tree.title};${el}`,
              })),
          }))
    );
  } else if (tree._nodes) {
    const nodes = tree._nodes_cond
      ? tree._nodes.concat(tree._nodes_cond)
      : tree._nodes;
    return withChildren(
      {
        name: t(tree.title),
        help: tree.help,
        type: nodeType(tree),
        id,
        app,
        parent: parentId,
      },
      () => nodes.map((node: TreeNode) => recursTree(node, config, id, app))
    );
  }
  return {
    name: t(tree.title),
    type: nodeType(tree),
    id,
    app,
    help: tree.help,
    parent: parentId,
  };
}
