// URLs of the manager API and static files, built from the globals defined
// by psgi.js: the manager is not always served at the root (e.g.
// /manager.psgi/). Both scriptname and staticPrefix end with "/".
export const apiUrl = (path: string): string =>
  `${(window as any).scriptname || "/"}${path}`;

export const staticUrl = (path: string): string =>
  `${(window as any).staticPrefix || "/static/"}${path}`;
