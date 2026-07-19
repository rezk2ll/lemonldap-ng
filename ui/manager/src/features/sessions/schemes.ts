// Progressive discovery of sessions — faithful port of the legacy
// `schemes` / `overScheme` from lemonldap-ng-manager/site/js-src/sessions.js.
//
// Each `schemes[type]` is an array of query builders, one per tree depth.
// Expanding a node runs `schemes[type][level](type, value, currentQuery)` to
// build the `sessions/<type>?<query>` request. When a node returns more than
// `MAX` children, `overScheme[type]` inserts an extra intermediate level so
// the user drills down instead of facing a huge flat list.

// Max number of sessions displayed before an extra grouping level is added.
export const MAX = 25;

export type SchemeFn = (t: string, v: string, q?: string) => string;
export type OverSchemeFn = (
  t: string,
  v: string,
  level: number,
  over: number,
  q?: string
) => string | null;

export const schemes: Record<string, SchemeFn[]> = {
  _whatToTrace: [
    // First level: group by first letter
    (t) => `groupBy=substr(${t},1)`,
    // Second level (if no overScheme): usernames
    (t, v) => `${t}=${v}*&groupBy=${t}`,
    (t, v) => `${t}=${v}`,
  ],
  ipAddr: [
    (t) => `groupBy=net(${t},16,1)`,
    (t, v) => {
      if (!v.match(/:/)) v = v + ".";
      return `${t}=${v}*&groupBy=net(${t},32,2)`;
    },
    (t, v) => {
      if (!v.match(/:/)) v = v + ".";
      return `${t}=${v}*&groupBy=net(${t},48,3)`;
    },
    (t, v) => {
      if (!v.match(/:/)) v = v + ".";
      return `${t}=${v}*&groupBy=net(${t},128,4)`;
    },
    (t, v) => `${t}=${v}&groupBy=_whatToTrace`,
    (t, v, q) => (q || "").replace(/&groupBy.*$/, "") + `&_whatToTrace=${v}`,
  ],
  _startTime: [
    (t) => `groupBy=substr(${t},8)`,
    (t, v) => `${t}=${v}*&groupBy=substr(${t},10)`,
    (t, v) => `${t}=${v}*&groupBy=substr(${t},11)`,
    (t, v) => `${t}=${v}*&groupBy=substr(${t},12)`,
    (t, v) => `${t}=${v}*&groupBy=_whatToTrace`,
    (t, v, q) => (q || "").replace(/&groupBy.*$/, "") + `&_whatToTrace=${v}`,
  ],
  doubleIp: [
    (t) => t,
    (t, v) => `_whatToTrace=${v}&groupBy=ipAddr`,
    (t, v, q) => (q || "").replace(/&groupBy.*$/, "") + `&ipAddr=${v}`,
  ],
  _session_uid: [
    (t) => `groupBy=substr(${t},1)`,
    (t, v) => `${t}=${v}*&groupBy=${t}`,
    (t, v) => `${t}=${v}`,
  ],
};

// When a node has more than MAX children and an overScheme is defined for its
// type, an extra level is inserted (returns null to stop inserting).
export const overScheme: Record<string, OverSchemeFn> = {
  _whatToTrace: (t, v, level, over) => {
    // "v.length >= (level+over)" avoids a loop when a single user opened more
    // than MAX sessions.
    if (v.length >= level + over) return null;
    if (level === 1 && v.length > over) {
      return `${t}=${v}*&groupBy=substr(${t},${level + over + 1})`;
    }
    return null;
  },
  // Note: IPv4 only
  ipAddr: (t, v, level, over) => {
    if (level > 0 && level < 4 && !v.match(/^\d+\.\d/) && over < 2) {
      return `${t}=${v}*&groupBy=net(${t},${16 * level + 4 * (over + 1)},${
        1 + level + over
      })`;
    }
    return null;
  },
  _startTime: (t, v, level, over) => {
    if (level > 3) {
      return `${t}=${v}*&groupBy=substr(${t},${10 + level + over})`;
    }
    return null;
  },
  _session_uid: (t, v, level, over) => {
    if (level === 1 && v.length > over) {
      return `${t}=${v}*&groupBy=substr(${t},${level + over + 1})`;
    }
    return null;
  },
};

// Pick the query scheme for a session-view type (_updateTime reuses the
// _startTime scheme, unknown types fall back to _whatToTrace).
export function schemeFor(type: string): SchemeFn[] {
  if (schemes[type]) return schemes[type];
  if (type === "_updateTime") return schemes._startTime;
  return schemes._whatToTrace;
}
