export interface ConfigChange {
  path: string[];
  kind: "added" | "removed" | "changed";
  before?: unknown;
  after?: unknown;
}

// Metadata rewritten by the server on each save, never a user change
const IGNORED_KEYS = new Set([
  "cfgNum",
  "cfgLog",
  "cfgDate",
  "cfgAuthor",
  "cfgAuthorIP",
  "cfgVersion",
  "prev",
  "next",
]);

function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function isEmpty(value: unknown) {
  return value === undefined || value === null || value === "";
}

// Forms do not always keep the original type ("1" vs 1): compare scalars by
// their string form, and arrays by their JSON form.
function sameValue(a: unknown, b: unknown) {
  if (isEmpty(a) && isEmpty(b)) return true;
  if (Array.isArray(a) || Array.isArray(b)) {
    return JSON.stringify(a) === JSON.stringify(b);
  }
  return String(a) === String(b);
}

function walk(
  before: unknown,
  after: unknown,
  path: string[],
  changes: ConfigChange[]
) {
  // Recurse into hashes (an added or removed hash lists its leaves)
  if (
    (isObject(before) || isEmpty(before)) &&
    (isObject(after) || isEmpty(after)) &&
    (isObject(before) || isObject(after))
  ) {
    const b = isObject(before) ? before : {};
    const a = isObject(after) ? after : {};
    const keys = Object.keys(b).concat(
      Object.keys(a).filter(
        (key) => !Object.prototype.hasOwnProperty.call(b, key)
      )
    );
    keys.sort().forEach((key) => {
      if (path.length === 0 && IGNORED_KEYS.has(key)) return;
      walk(b[key], a[key], [...path, key], changes);
    });
    return;
  }
  if (sameValue(before, after)) return;
  if (isEmpty(before)) {
    changes.push({ path, kind: "added", after });
  } else if (isEmpty(after)) {
    changes.push({ path, kind: "removed", before });
  } else {
    changes.push({ path, kind: "changed", before, after });
  }
}

// Leaf-level differences between the loaded configuration and the edited one
export function configDiff(before: unknown, after: unknown): ConfigChange[] {
  const changes: ConfigChange[] = [];
  walk(before, after, [], changes);
  return changes;
}
