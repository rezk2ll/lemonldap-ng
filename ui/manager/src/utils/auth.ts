// Authentication helpers.
//
// LemonLDAP::NG protects the manager backend with a handler that, for an
// unauthenticated Ajax request (Accept: application/json), returns a real
// 401 with a "WWW-Authenticate: SSO <portal>" header instead of a 302 to the
// portal. The legacy AngularJS manager caught that 401 on *every* Ajax
// request and redirected the browser to the portal. This module reproduces
// that behaviour for the React manager through a global `fetch` interceptor.

// Redirect the browser to the portal for authentication, keeping the current
// URL (base64 encoded) so the user comes back here after login.
export const goToPortal = (portal?: string | null) => {
  const target = portal || (window as any).portal;
  if (target) {
    window.location.href =
      `${target}?url=` + encodeURIComponent(window.btoa(window.location.href));
  }
};

// Extract the portal URL from a "WWW-Authenticate: SSO <portal>" header.
const portalFromResponse = (response: Response): string | undefined => {
  const header = response.headers.get("WWW-Authenticate");
  const match = header ? /^SSO\s+(\S+)/.exec(header) : null;
  return match ? match[1] : undefined;
};

// Guard so that concurrent 401 responses trigger a single redirection.
let redirecting = false;

// Redirect to the portal when the response denotes an unauthenticated request
// (401 with a "WWW-Authenticate: SSO <portal>" header, or any 401 when the
// portal URL is already known). Returns true when a redirection was triggered.
export const handleUnauthorized = (response: Response): boolean => {
  if (response.status !== 401) return false;
  const portal = portalFromResponse(response);
  if (!portal && !(window as any).portal) return false;
  if (!redirecting) {
    redirecting = true;
    goToPortal(portal);
  }
  return true;
};

// Install a global `fetch` interceptor that:
//  - advertises a JSON-capable client (Accept: application/json) so the
//    server answers protected requests with a real 401 instead of a 302
//    redirect that `fetch` would silently follow to the portal login page;
//  - redirects to the portal on such a 401, like the legacy interceptor did
//    for every Ajax request.
export const installFetchInterceptor = () => {
  if ((window as any).__llngFetchInterceptor) return;
  (window as any).__llngFetchInterceptor = true;

  const nativeFetch = window.fetch.bind(window);
  window.fetch = async (
    input: RequestInfo | URL,
    init?: RequestInit
  ): Promise<Response> => {
    const base =
      init?.headers ??
      (input instanceof Request ? input.headers : undefined);
    const headers = new Headers(base);
    if (!headers.has("Accept")) headers.set("Accept", "application/json");

    const response = await nativeFetch(input, { ...init, headers });
    handleUnauthorized(response);
    return response;
  };
};
