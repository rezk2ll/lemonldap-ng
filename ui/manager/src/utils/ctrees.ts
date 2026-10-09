// Per-object parameter trees ("ctrees": what an OIDC RP, a SAML SP... holds),
// read from nstruct.json like the advanced configuration view. Application
// pages are built from them so they follow the configuration schema
// (Lemonldap::NG::Manager::Build::CTrees) instead of hard-coding parameters.
import { getTree } from "./getTree";

export interface CtreeNode {
  title: string;
  id?: string;
  type?: string;
  help?: string;
  get?: string;
  cnodes?: string | CtreeNode[];
  _nodes?: CtreeNode[];
  _nodes_cond?: CtreeNode[];
}

let struct: Promise<CtreeNode[]> | undefined;

// Inject an already-parsed nstruct.json (test setup) instead of fetching it.
export function setStruct(s: CtreeNode[]): void {
  struct = Promise.resolve(s);
}

export function loadStruct(): Promise<CtreeNode[]> {
  if (!struct) {
    struct = getTree()
      .then((r) => r.json())
      .catch((e) => {
        struct = undefined;
        throw e;
      });
  }
  return struct;
}

// The ctree of `<type>s` (e.g. "oidcRPMetaDataNodes"), wherever it sits.
export function findCtree(nodes: CtreeNode[], type: string): CtreeNode[] | undefined {
  for (const node of nodes) {
    if (!node || typeof node !== "object") continue;
    if (node.title === `${type}s` && Array.isArray(node.cnodes)) {
      return node.cnodes;
    }
    for (const sub of [node._nodes, node._nodes_cond, node.cnodes]) {
      if (Array.isArray(sub)) {
        const found = findCtree(sub, type);
        if (found) return found;
      }
    }
  }
  return undefined;
}

export function children(node: CtreeNode): CtreeNode[] {
  return [...(node._nodes || []), ...(node._nodes_cond || [])];
}

export function isGroup(node: CtreeNode): boolean {
  return Array.isArray(node._nodes);
}
