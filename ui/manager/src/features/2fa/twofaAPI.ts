// REST client for the existing manager Second-Factor API (unchanged server
// side). The 2FA explorer searches persistent sessions for `_2fDevices`.
// Paths are relative to `window.scriptname`, like the legacy explorer.

export type SfaListValue = {
  value?: string; // group node
  count?: number;
  session?: string; // leaf node
  userId?: string;
  [k: string]: unknown;
};

export type SfaListResponse = {
  result: number;
  count: number;
  total: number;
  values: SfaListValue[];
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

// The session type is always "persistent" for the 2FA explorer.
export async function listSfa(query: string): Promise<SfaListResponse> {
  const res = await fetch(`${base()}2ndfa/persistent?${query}`, {
    credentials: "same-origin",
  });
  return toJson(res);
}

export async function getSfaSession(
  sessionId: string
): Promise<Record<string, any>> {
  const res = await fetch(
    `${base()}2ndfa/persistent/${encodeURIComponent(sessionId)}`,
    { credentials: "same-origin" }
  );
  return toJson(res);
}

// Delete one 2FA device identified by type + epoch.
export async function deleteDevice(
  sessionId: string,
  type: string,
  epoch: string | number
): Promise<{ result: number }> {
  const res = await fetch(
    `${base()}2ndfa/persistent/${encodeURIComponent(
      sessionId
    )}?type=${encodeURIComponent(type)}&epoch=${encodeURIComponent(
      String(epoch)
    )}`,
    { method: "DELETE", credentials: "same-origin" }
  );
  return toJson(res);
}

// Registered second-factor types (drives the type-filter checkboxes), read
// from `available2FSelfRegistration` with Yubikey renamed to UBK, exactly as
// the server builds regSfaTypes. Falls back to a common default.
export async function get2FTypes(): Promise<string[]> {
  try {
    const res = await fetch(`${base()}confs/latest?full=1`, {
      credentials: "same-origin",
    });
    const conf = await toJson(res);
    const raw =
      conf && conf.available2FSelfRegistration
        ? String(conf.available2FSelfRegistration)
        : "Password,TOTP,WebAuthn,Yubikey";
    return raw
      .split(/[,\s]+/)
      .filter(Boolean)
      .map((t: string) => (t === "Yubikey" ? "UBK" : t));
  } catch (e) {
    return ["Password", "TOTP", "WebAuthn", "UBK"];
  }
}
