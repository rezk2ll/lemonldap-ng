import "@testing-library/jest-dom";
import { act, render, waitFor } from "@testing-library/react";
import { Provider } from "react-redux";
import App from "../src/App";
import { history, store } from "../src/app/store";

describe("App routing", () => {
  it("redirects an unknown path to the page route, keeping the hash", async () => {
    act(() => history.replace("/#conf/latest"));
    render(
      <Provider store={store}>
        <App htmlName="manager.html" />
      </Provider>
    );
    await waitFor(() => expect(history.location.pathname).toBe("/manager.html"));
    expect(history.location.hash).toBe("#conf/latest");
  });
});
