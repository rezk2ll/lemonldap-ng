import { Provider } from "react-redux";
import App from "./App";
import { store } from "./app/store";
import { mountApp } from "./bootstrap";
import { loadMetadata } from "./metadata";

// The configuration metadata (attributes/definitions/tree) is fetched, not
// bundled. It must be available on the first render — reassigning the live
// bindings does not re-render React — so we wait for it before mounting. A
// failed fetch still mounts the app (degraded: forms lose their metadata).
loadMetadata()
  .catch((e) => console.error("Failed to load manager metadata", e))
  .finally(() =>
    mountApp(
      <Provider store={store}>
        <App htmlName={process.env.REACT_APP_HTMLNAME || ""} />
      </Provider>
    )
  );
