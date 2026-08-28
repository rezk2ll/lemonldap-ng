// Session detail preparation — faithful port of `transformSession` and the
// `categories` map from the legacy sessions.js. Turns a raw session hash into
// ordered, translated groups of rows for the detail panel.

export type DetailRow = {
  title: string;
  value: any;
  epoch?: string | number;
  // "0" = header row, "1" = 2FA device, "2" = OIDC consent (deletable)
  td?: string;
};

export type DetailGroup = { title: string; nodes: DetailRow[] };

export type SessionDetail = {
  _utime?: number;
  id?: string;
  nodes: DetailGroup[];
};

// Attributes grouped in the detail view (order preserved).
const categories: Record<string, string[]> = {
  dateTitle: ["_utime", "_startTime", "_updateTime", "_lastAuthnUTime", "_lastSeen"],
  connectionTitle: ["ipAddr", "_timezone", "_url"],
  authenticationTitle: ["_session_id", "_user", "_password", "authenticationLevel"],
  modulesTitle: [
    "_auth",
    "_userDB",
    "_passwordDB",
    "_issuerDB",
    "_authChoice",
    "_authMulti",
    "_userDBMulti",
    "_2f",
  ],
  saml: ["_idp", "_idpConfKey", "_samlToken", "_lassoSessionDump", "_lassoIdentityDump"],
  groups: ["groups", "hGroups"],
  ldap: ["dn"],
  OpenIDConnect: [
    "_oidc_id_token",
    "_oidc_OP",
    "_oidc_access_token",
    "_oidc_refresh_token",
    "_oidc_access_token_eol",
    "_oidcConnectedRP",
    "_oidcConnectedRPIDs",
  ],
  sfaTitle: ["_2fDevices"],
  oidcConsents: ["_oidcConsents"],
};

export function localeDate(s: any): string {
  if (!s && s !== 0) return "";
  const d = new Date(Number(s) * 1000);
  return d.toLocaleString();
}

export function strToLocaleDate(s: any): string {
  const m = String(s).match(/^(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})$/);
  if (!m) return String(s);
  const d = new Date(`${m[1]}-${m[2]}-${m[3]}T${m[4]}:${m[5]}:${m[6]}`);
  return d.toLocaleString();
}

// A session is valid if it has not exceeded sessionTTL (persistent sessions
// are always valid).
export function isSessionValid(epoch: number, persistent: boolean): boolean {
  if (persistent) return true;
  const now = Date.now() / 1000;
  const ttl = Number((window as any).sessionTTL) || 0;
  return now - epoch < ttl;
}

const impPrefix = (): string => (window as any).impPrefix || "real_";

export function transformSession(raw: Record<string, any>): SessionDetail {
  const session: Record<string, any> = { ...raw };
  const time = session._utime;
  const res: DetailGroup[] = [];

  // 1. Normalize values: drop empty, split multivalued, format dates.
  for (const key of Object.keys(session)) {
    const value = session[key];
    if (!value && value !== 0) {
      delete session[key];
      continue;
    }
    if (typeof value === "string" && value.match(/; /)) {
      session[key] = value.split("; ");
    }
    if (typeof session[key] !== "object") {
      if (key === "_password") {
        session[key] = "********";
      } else if (key.match(/^(_utime|_lastAuthnUTime|_lastSeen|notification)$/)) {
        session[key] = localeDate(value);
      } else if (key.match(/^(_startTime|_updateTime)$/)) {
        session[key] = strToLocaleDate(value);
      }
    }
  }

  // 2. Grouped categories.
  for (const category of Object.keys(categories)) {
    const subres: DetailRow[] = [];
    for (const attr of categories[category]) {
      const val = session[attr];
      if (!val) {
        delete session[attr];
        continue;
      }
      if (attr === "_2fDevices") {
        try {
          const devices = JSON.parse(val);
          if (Array.isArray(devices) && devices.length > 0) {
            subres.push({ title: "type", value: "name", epoch: "date", td: "0" });
            for (const d of devices) {
              subres.push({
                title: d.type,
                value: d.name,
                epoch: d.epoch,
                td: "1",
              });
            }
          }
        } catch (e) {
          /* ignore malformed */
        }
        delete session[attr];
      } else if (val.toString().match(/"rp":\s*"[\w-]+"/)) {
        subres.push({ title: "RP", value: "scope", epoch: "date", td: "0" });
        try {
          const consents = JSON.parse(val);
          for (const c of consents) {
            subres.push({
              title: c.rp,
              value: c.scope,
              epoch: c.epoch,
              td: "2",
            });
          }
        } catch (e) {
          /* ignore malformed */
        }
        delete session[attr];
      } else if (val.toString().match(/\w+/)) {
        subres.push({ title: attr, value: session[attr], epoch: "" });
        delete session[attr];
      } else {
        delete session[attr];
      }
    }
    if (subres.length > 0) {
      res.push({ title: category, nodes: subres });
    }
  }

  // 3. openid* and already-sent notifications, grouped and date-sorted.
  const insert = (re: string, title: string) => {
    const reg = new RegExp(re);
    const collected: { key: string; date: any }[] = [];
    for (const key of Object.keys(session)) {
      const value = session[key];
      if (key.match(reg) && value) {
        collected.push({ key, date: value });
        delete session[key];
      }
    }
    if (collected.length) {
      collected.sort((a, b) => (a.key < b.key ? 1 : a.key > b.key ? -1 : 0));
      res.push({
        title,
        nodes: collected.map((c) => ({
          title: c.key,
          value: localeDate(c.date),
        })),
      });
    }
  };
  insert("^openid", "OpenID");
  insert("^notification_(.+)", "notificationsDone");

  // 4. Login history (success + failed), most recent first.
  if (session._loginHistory) {
    const rows: { t: number; title: string; value: string }[] = [];
    const collect = (list: any[], render: (l: any, cv: string) => string) => {
      for (const l of list || []) {
        let cv = "";
        for (const key of Object.keys(l)) {
          if (!key.match(/^(_utime|ipAddr|error)$/)) cv += `, ${key} : ${l[key]}`;
        }
        cv = cv.split(", ").sort().join(", ");
        rows.push({ t: l._utime, title: localeDate(l._utime), value: render(l, cv) });
      }
    };
    collect(
      session._loginHistory.successLogin,
      (l, cv) => `Success (IP ${l.ipAddr})` + cv
    );
    collect(
      session._loginHistory.failedLogin,
      (l, cv) => `Error ${l.error} (IP ${l.ipAddr})` + cv
    );
    delete session._loginHistory;
    rows.sort((a, b) => b.t - a.t);
    res.push({ title: "loginHistory", nodes: rows });
  }

  // 5. Remaining attributes and macros (spoofed first, real_ impersonation last).
  const remaining: DetailRow[] = Object.keys(session).map((key) => ({
    title: key,
    value: session[key],
  }));
  remaining.sort((a, b) => (a.title > b.title ? 1 : a.title < b.title ? -1 : 0));
  const realRe = new RegExp("^" + impPrefix() + ".+$");
  const spoof = remaining.filter((r) => !r.title.match(realRe));
  const real = remaining.filter((r) => r.title.match(realRe));
  res.push({ title: "attributesAndMacros", nodes: spoof.concat(real) });

  return { _utime: time, nodes: res };
}

// Format a grouping value into a tree node title (start/update time views).
export function formatTreeTitle(type: string, value: string): string {
  if (type.match(/^_?(start|update)Time$/i) || type === "_startTime" || type === "_updateTime") {
    return String(value)
      .replace(/^(\d{8})(\d{2})(\d{2})$/, "$2:$3")
      .replace(/^(\d{8})(\d{2})(\d)$/, "$2:$30")
      .replace(/^(\d{8})(\d{2})$/, "$2h")
      .replace(/^(\d{4})(\d{2})(\d{2})/, "$1-$2-$3");
  }
  return String(value);
}
