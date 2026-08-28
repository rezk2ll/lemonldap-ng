// Configuration metadata: attribute types, field definitions and the parameter
// tree. These files are large (~230 KB) and change only with the LemonLDAP::NG
// schema, so — like the legacy manager loads struct.json — they are served as
// static assets and fetched once at startup (see loadMetadata, awaited by the
// manager entry point) instead of being bundled into the JS.
//
// The exports are live bindings reassigned by loadMetadata: every consumer just
// imports { attributes } / { definitions } / { tree } and reads them at render
// time, which happens after the metadata has loaded. They are typed loosely so
// the JSON is not bundled just to type call sites; a handful of iterations that
// relied on the precise shapes got explicit annotations instead.
/* eslint-disable @typescript-eslint/no-explicit-any */
export let attributes: any = {};
export let definitions: any = {};
export let tree: any = {};

// Inject already-available metadata (used by the test setup, and usable for a
// server-side preload) instead of fetching it.
export function setMetadata(a: any, d: any, t: any): void {
  attributes = a;
  definitions = d;
  tree = t;
}

export async function loadMetadata(): Promise<void> {
  const prefix = (window as any).staticPrefix || "/static/";
  const get = (name: string): Promise<any> =>
    fetch(`${prefix}new/${name}`).then((r) => r.json());
  const [a, d, t] = await Promise.all([
    get("attributes.json"),
    get("definitions.json"),
    get("tree.json"),
  ]);
  attributes = a;
  definitions = d;
  tree = t;
}
