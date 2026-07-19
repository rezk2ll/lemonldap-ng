// REST client for the existing manager Notifications API (unchanged server
// side). Paths are relative to `window.scriptname`, like the legacy explorer.

export type NotifType = "actives" | "done";

export type NotifListValue = {
  value?: string; // group node
  count?: number;
  notification?: string; // leaf: internal id
  uid?: string;
  date?: string;
  condition?: string;
  reference?: string;
  [k: string]: unknown;
};

export type NotifListResponse = {
  result: number;
  count: number;
  total: number;
  values: NotifListValue[];
};

export type NotifViewResponse = {
  result: number;
  count: number;
  notifications?: any[];
  done?: string;
  error?: string;
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

export async function listNotifications(
  type: NotifType,
  query: string
): Promise<NotifListResponse> {
  const res = await fetch(`${base()}notifications/${type}?${query}`, {
    credentials: "same-origin",
  });
  return toJson(res);
}

export async function viewNotification(
  type: NotifType,
  id: string
): Promise<NotifViewResponse> {
  const res = await fetch(
    `${base()}notifications/${type}/${encodeURIComponent(id)}`,
    { credentials: "same-origin" }
  );
  return toJson(res);
}

export type NewNotification = {
  uid: string;
  reference: string;
  condition?: string;
  date?: string;
  xml: string;
};

export async function createNotification(
  body: NewNotification
): Promise<{ result: number; error?: string }> {
  const res = await fetch(`${base()}notifications/actives`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
    credentials: "same-origin",
  });
  return toJson(res);
}

// Mark an active notification (uid_reference) as done.
export async function markAsDone(
  id: string
): Promise<{ result: number; error?: string }> {
  const res = await fetch(
    `${base()}notifications/actives/${encodeURIComponent(id)}`,
    {
      method: "PUT",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ done: 1 }),
      credentials: "same-origin",
    }
  );
  return toJson(res);
}

// Definitely purge a done notification (uid_reference_doneId).
export async function purgeNotification(
  id: string
): Promise<{ result: number; error?: string }> {
  const res = await fetch(
    `${base()}notifications/done/${encodeURIComponent(id)}`,
    { method: "DELETE", credentials: "same-origin" }
  );
  return toJson(res);
}
