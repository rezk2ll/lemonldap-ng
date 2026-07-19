import { Provider } from "react-redux";
import App from "./App";
import { store } from "./app/store";
import { mountApp } from "./bootstrap";

mountApp(
  <Provider store={store}>
    <App htmlName={process.env.REACT_APP_HTMLNAME || ""} />
  </Provider>
);
