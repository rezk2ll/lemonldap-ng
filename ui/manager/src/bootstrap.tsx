// Shared entry-point bootstrap for every manager SPA (configuration,
// sessions, ...). It wraps the given app element with the common theme and
// providers, loads psgi.js (which defines window.availableLanguages,
// window.scriptname, window.menulinks, window.links...) before the first
// render, and redirects to the portal when the user is not authenticated.
import { green, grey, orange, yellow } from "@mui/material/colors";
import {
  StyledEngineProvider,
  ThemeProvider,
  createTheme,
} from "@mui/material/styles";
import React, { ReactNode } from "react";
import { createRoot } from "react-dom/client";
import "./i18n";
import "./index.css";
import reportWebVitals from "./reportWebVitals";
import {
  goToPortal,
  handleUnauthorized,
  installFetchInterceptor,
} from "./utils/auth";

const theme = createTheme({
  palette: {
    primary: orange,
    secondary: {
      main: grey[800],
      dark: grey[900],
      light: grey[500],
    },
    success: green,
    warning: yellow,
  },
});

export function mountApp(children: ReactNode) {
  // Handle a 401 (WWW-Authenticate: SSO <portal>) on any Ajax request by
  // redirecting to the portal, like the legacy AngularJS $lmhttp interceptor.
  installFetchInterceptor();

  const container = document.getElementById("root")!;
  const root = createRoot(container);

  const renderApp = () => {
    root.render(
      <ThemeProvider theme={theme}>
        <StyledEngineProvider injectFirst>
          <React.StrictMode>{children}</React.StrictMode>
        </StyledEngineProvider>
      </ThemeProvider>
    );
    reportWebVitals();
  };

  const bootstrap = async () => {
    let response: Response;
    try {
      response = await fetch("/psgi.js", { credentials: "same-origin" });
    } catch (e) {
      // Cross-origin 302 to the portal blocked by CORS: authenticate.
      goToPortal();
      return;
    }

    // Not authenticated: the interceptor already redirected on 401; also
    // cover a 302 to the portal that fetch already followed.
    if (handleUnauthorized(response) || response.redirected) {
      if (response.redirected) goToPortal(response.url.replace(/\?.*$/, ""));
      return;
    }

    if (response.ok) {
      // Execute psgi.js in the global scope so its top-level `var`
      // declarations become window globals, exactly as a <script> tag would.
      const code = await response.text();
      const script = document.createElement("script");
      script.text = code;
      document.body.appendChild(script);
    }

    renderApp();
  };

  bootstrap();
}
