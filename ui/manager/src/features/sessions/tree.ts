// Lazy session tree construction — the progressive-discovery core.
// Mirrors `updateTree` from the legacy sessions.js: builds the query for a
// node's depth, applies overScheme when a node exceeds MAX children, fetches
// and turns the result into group / leaf tree nodes.
import { MAX, overScheme, schemeFor } from "./schemes";
import { formatTreeTitle } from "./sessionDisplay";
import { listSessions } from "./sessionsAPI";

export type TreeNode = {
  id: string;
  isLeaf: boolean;
  // group node
  value?: string;
  title?: string;
  count?: number;
  level: number;
  over: number;
  query?: string;
  // leaf (session) node
  session?: string;
  date?: number;
};

let autoId = 0;
const nextId = () => `node${++autoId}`;

// The context needed to (re)load a node's children.
export type NodeContext = {
  value: string;
  level: number;
  over: number;
  query?: string;
  count?: number;
};

export const ROOT_CONTEXT: NodeContext = {
  value: "",
  level: 0,
  over: 0,
};

export async function loadChildren(
  type: string,
  sessionType: string,
  node: NodeContext
): Promise<{ children: TreeNode[]; total: number }> {
  const scheme = schemeFor(type);
  let level = node.level;
  let over = node.over;
  let query = scheme[level](type, node.value, node.query);

  // Insert an extra level when a node has more than MAX children.
  if (node.count != null && node.count > MAX && overScheme[type]) {
    const tmp = overScheme[type](type, node.value, level, over, node.query);
    if (tmp) {
      over++;
      query = tmp;
      level = level - 1;
    } else {
      over = 0;
    }
  } else {
    over = 0;
  }

  const data = await listSessions(sessionType, query);
  const children: TreeNode[] = [];
  if (data && data.result) {
    for (const v of data.values || []) {
      if (level < scheme.length - 1) {
        children.push({
          id: nextId(),
          isLeaf: false,
          value: v.value,
          count: v.count,
          title: formatTreeTitle(type, v.value ?? ""),
          level: level + 1,
          over,
          query,
        });
      } else {
        children.push({
          id: nextId(),
          isLeaf: true,
          session: v.session,
          date: v.date,
          level: level + 1,
          over,
        });
      }
    }
  }
  return { children, total: data ? data.total : 0 };
}
