// Parse the `_2fDevices` field of a persistent session into device rows.

export type Device = {
  type: string;
  name: string;
  epoch: number;
  [k: string]: any;
};

export function parseDevices(session: Record<string, any>): Device[] {
  const raw = session ? session._2fDevices : null;
  if (!raw) return [];
  try {
    const arr = typeof raw === "string" ? JSON.parse(raw) : raw;
    return Array.isArray(arr) ? arr : [];
  } catch (e) {
    return [];
  }
}

export function localeDate(s: any): string {
  if (!s && s !== 0) return "";
  return new Date(Number(s) * 1000).toLocaleString();
}
