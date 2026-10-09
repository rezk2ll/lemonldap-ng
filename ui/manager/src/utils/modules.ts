// Manager modules enabled in lemonldap-ng.ini (enabledModules): psgi.js lists
// them in `links`, identified by their default route (e.g. "sessions.html").
// Without psgi.js (dev server, tests), every module is considered enabled.
export function isModuleEnabled(target: string): boolean {
  const links = (window as any).links as { target: string }[] | undefined;
  if (!Array.isArray(links)) return true;
  return links.some((l) => l.target === target);
}
