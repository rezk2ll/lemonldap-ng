// Shared entry-point bootstrap for every manager SPA (configuration,
// sessions, ...). It wraps the given app element with the common theme and
// providers. psgi.js (which defines availableLanguages, scriptname,
// menulinks, links...) is loaded by the template before this bundle, and
// unauthenticated Ajax calls are redirected to the portal by the fetch
// interceptor.
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
import { installFetchInterceptor } from "./utils/auth";

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

  // psgi.js is loaded by a <script> tag placed before this bundle in the
  // template, so its globals are already set here. It used to be fetched and
  // injected as an inline script, which a strict Content-Security-Policy
  // forbids: its content is dynamic, so no hash can cover it.
  renderApp();
}
