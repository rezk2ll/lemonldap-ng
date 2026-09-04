// Lazy notification tree with progressive discovery — faithful port of the
// scheme / overScheme / updateTree from the legacy notifications.js.
// Notifications are grouped by uid: first letter -> uid -> individual
// notifications, with an extra letter level inserted past MAX children.
import { listNotifications, NotifType } from "./notificationsAPI";

export const MAX = 25;

// scheme[level](value) -> query string
const scheme: ((v: string) => string)[] = [
  () => "groupBy=substr(uid,1)",
  (v) => `uid=${v}*&groupBy=uid`,
  (v) => `uid=${v}`,
];

const overScheme = (v: string, level: number, over: number): string | null => {
  if (level === 1 && v.length > over) {
    return `uid=${v}*&groupBy=substr(uid,${level + over + 1})`;
  }
  return null;
};

export type NotifNode = {
  id: string;
  isLeaf: boolean;
  // group node
  value?: string;
  count?: number;
  level: number;
  over: number;
  query?: string;
  // leaf node
  notification?: string;
  uid?: string;
  date?: string;
  condition?: string;
  reference?: string;
};

export type NotifNodeContext = {
  value: string;
  level: number;
  over: number;
  query?: string;
  count?: number;
};

export const ROOT_CONTEXT: NotifNodeContext = { value: "", level: 0, over: 0 };

let autoId = 0;
const nextId = () => `nnode${++autoId}`;

export async function loadChildren(
  type: NotifType,
  node: NotifNodeContext
): Promise<{ children: NotifNode[]; total: number }> {
  let level = node.level;
  let over = node.over;
  let query = scheme[level](node.value);

  if (node.count != null && node.count > MAX) {
    const tmp = overScheme(node.value, level, over);
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

  const data = await listNotifications(type, query);
  const children: NotifNode[] = [];
  if (data && data.result) {
    for (const v of data.values || []) {
      if (level < scheme.length - 1) {
        children.push({
          id: nextId(),
          isLeaf: false,
          value: v.value,
          count: v.count,
          level: level + 1,
          over,
          query,
        });
      } else {
        children.push({
          id: nextId(),
          isLeaf: true,
          level: level + 1,
          over,
          notification: v.notification,
          uid: v.uid,
          date: v.date,
          condition: v.condition,
          reference: v.reference,
        });
      }
    }
  }
  return { children, total: data ? data.total : 0 };
}

// Format a stored notification date (YYYYMMDD) as YYYY-MM-DD for display.
export function formatNotifDate(date?: string): string {
  if (!date) return "";
  return String(date).replace(/^(\d{4})(\d{2})(\d{2})$/, "$1-$2-$3");
}

// Build the view id used by GET notifications/<type>/<id>.
export function viewId(type: NotifType, node: NotifNode): string {
  if (type === "done") {
    return String(node.notification || "").replace(/#/g, "_");
  }
  return `${node.uid}_${node.reference}`;
}
