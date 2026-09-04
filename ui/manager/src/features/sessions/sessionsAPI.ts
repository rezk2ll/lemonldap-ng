// REST client for the existing manager Sessions API (unchanged server side).
// All paths are relative to `window.scriptname` (injected by psgi.js), exactly
// like the legacy AngularJS explorer: `${scriptname}sessions/...`.

export type SessionListValue = {
  // group node
  value?: string;
  count?: number;
  // leaf node
  session?: string;
  date?: number;
  // orderBy / doubleIp extra fields
  sessions?: SessionListValue[];
  [field: string]: unknown;
};

export type SessionListResponse = {
  result: number;
  count: number;
  total: number;
  values: SessionListValue[];
};

const base = (): string => (window as any).scriptname || "/";

async function toJson(res: Response) {
  const text = await res.text();
  try {
    return text ? JSON.parse(text) : {};
  } catch (e) {
    throw new Error(text || res.statusText);
  }
}

export async function listSessions(
  sessionType: string,
  query: string
): Promise<SessionListResponse> {
  const res = await fetch(`${base()}sessions/${sessionType}?${query}`, {
    credentials: "same-origin",
  });
  return toJson(res);
}

export async function getSession(
  sessionType: string,
  sessionId: string
): Promise<Record<string, any>> {
  const res = await fetch(
    `${base()}sessions/${sessionType}/${encodeURIComponent(sessionId)}`,
    { credentials: "same-origin" }
  );
  return toJson(res);
}

export async function deleteSession(
  sessionType: string,
  sessionId: string
): Promise<{ result: number }> {
  const res = await fetch(
    `${base()}sessions/${sessionType}/${encodeURIComponent(sessionId)}`,
    { method: "DELETE", credentials: "same-origin" }
  );
  return toJson(res);
}

export async function globalLogout(
  sessionType: string,
  sessionId: string
): Promise<{ result: number; count: number }> {
  const res = await fetch(
    `${base()}sessions/glogout/${sessionType}/${encodeURIComponent(sessionId)}`,
    { method: "POST", credentials: "same-origin" }
  );
  return toJson(res);
}

export async function deleteOIDCConsent(
  sessionType: string,
  sessionId: string,
  rp: string,
  epoch: string | number
): Promise<{ result: number }> {
  const res = await fetch(
    `${base()}sessions/OIDCConsent/${sessionType}/${encodeURIComponent(
      sessionId
    )}?rp=${encodeURIComponent(rp)}&epoch=${encodeURIComponent(String(epoch))}`,
    { method: "DELETE", credentials: "same-origin" }
  );
  return toJson(res);
}
