// Lazy 2FA user tree with progressive discovery — faithful port of the
// scheme / overScheme / updateTree from the legacy 2ndfa.js. Groups users
// with registered second factors by first letter, then lists the users; an
// extra letter level is inserted past MAX users. Optional device-type filters
// are appended as repeatable `&type=` params.
import { listSfa } from "./twofaAPI";

export const MAX = 25;

// Group/leaf on _session_uid: it is always present on persistent sessions and
// is the field the server populates as `userId` in the leaf list (grouping by
// _whatToTrace returns userId: null since that field is not always stored).
const T = "_session_uid";

const scheme: ((t: string, v: string) => string)[] = [
  (t) => `groupBy=substr(${t},1)`,
  (t, v) => `${t}=${v}*`,
];

const overScheme = (
  t: string,
  v: string,
  level: number,
  over: number
): string | null => {
  if (level === 1 && v.length > over) {
    return `${t}=${v}*&groupBy=substr(${t},${level + over + 1})`;
  }
  return null;
};

export type SfaNode = {
  id: string;
  isLeaf: boolean;
  // group node
  value?: string;
  count?: number;
  level: number;
  over: number;
  // leaf node (a user)
  session?: string;
  userId?: string;
};

export type SfaNodeContext = {
  value: string;
  level: number;
  over: number;
  count?: number;
};

export const ROOT_CONTEXT: SfaNodeContext = { value: "", level: 0, over: 0 };

let autoId = 0;
const nextId = () => `sfanode${++autoId}`;

const typeParams = (types: string[]): string =>
  types.map((t) => `&type=${encodeURIComponent(t)}`).join("");

export async function loadChildren(
  node: SfaNodeContext,
  types: string[]
): Promise<{ children: SfaNode[]; total: number }> {
  let level = node.level;
  let over = node.over;
  let query = scheme[level](T, node.value);

  if (node.count != null && node.count > MAX) {
    const tmp = overScheme(T, node.value, level, over);
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

  const data = await listSfa(query + typeParams(types));
  return {
    children: buildNodes(data.values, level, over),
    total: Number(data.total) || 0,
  };
}

// Direct user search (uid prefix) — a flat leaf list.
export async function searchUsers(
  search: string,
  types: string[]
): Promise<{ children: SfaNode[]; total: number }> {
  const data = await listSfa(`_session_uid=${search}*` + typeParams(types));
  const children: SfaNode[] = (data.values || []).map((v) => ({
    id: nextId(),
    isLeaf: true,
    level: 2,
    over: 0,
    session: v.session,
    userId: v.userId,
  }));
  return { children, total: Number(data.total) || 0 };
}

function buildNodes(values: any[], level: number, over: number): SfaNode[] {
  const children: SfaNode[] = [];
  for (const v of values || []) {
    if (level < scheme.length - 1) {
      children.push({
        id: nextId(),
        isLeaf: false,
        value: v.value,
        count: v.count,
        level: level + 1,
        over,
      });
    } else {
      children.push({
        id: nextId(),
        isLeaf: true,
        level: level + 1,
        over,
        session: v.session,
        userId: v.userId,
      });
    }
  }
  return children;
}
