import { green, grey, orange, yellow } from "@mui/material/colors";
import {
  StyledEngineProvider,
  ThemeProvider,
  createTheme,
} from "@mui/material/styles";
import React from "react";
import { createRoot } from "react-dom/client";
import { Provider } from "react-redux";
import App from "./App";
import { store } from "./app/store";
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
const container = document.getElementById("root")!;
const root = createRoot(container);

const renderApp = () => {
  root.render(
    <ThemeProvider theme={theme}>
      <StyledEngineProvider injectFirst>
        <React.StrictMode>
          <Provider store={store}>
            <App htmlName={process.env.REACT_APP_HTMLNAME || ""} />
          </Provider>
        </React.StrictMode>
      </StyledEngineProvider>
    </ThemeProvider>
  );

  reportWebVitals();
};

// Handle a 401 (WWW-Authenticate: SSO <portal>) on any Ajax request by
// redirecting to the portal, like the legacy AngularJS $lmhttp interceptor.
installFetchInterceptor();

// psgi.js defines window.availableLanguages, window.menulinks and
// window.links, which are read during the very first render (e.g. by the
// Navbar). It must be loaded *before* rendering, otherwise the app crashes
// on `window.availableLanguages.map(...)`.
//
// The interceptor above fetches it with `Accept: application/json`, so an
// unauthenticated request yields a real 401 (WWW-Authenticate: SSO <portal>)
// instead of a 302 to the portal that a plain <script> tag would silently
// follow, loading the login page as JavaScript and leaving those globals
// undefined.
const bootstrap = async () => {
  let response: Response;
  try {
    response = await fetch("/psgi.js", { credentials: "same-origin" });
  } catch (e) {
    // Network error, typically a cross-origin 302 to the portal blocked by
    // CORS: the user needs to authenticate.
    goToPortal();
    return;
  }

  // Not authenticated: the interceptor already redirected on 401; also cover
  // the case of a 302 to the portal that fetch already followed.
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

  // Render even if psgi.js could not be loaded, so failures are visible
  // instead of a blank page.
  renderApp();
};

bootstrap();
