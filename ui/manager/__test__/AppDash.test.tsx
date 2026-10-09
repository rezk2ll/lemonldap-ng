import { fireEvent, screen, within } from "@testing-library/react";
import { t } from "i18next";
import { Configuration } from "../src/pages/Configuration";
import { renderWithProviders } from "../src/utils/test-utils";
import {
  changeInput,
  changeRadio,
  changeSelect,
  clickOption,
} from "../src/utils/test-utils";

global.fetch = vi.fn();

describe("Application Dashboard", () => {
  it('should render ApplicationDashboard for app type "native"', async () => {
    const location = {
      type: "app",
      info: { name: "native.example.com", type: "native" },
    };

    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");


    expect(screen.getAllByText("native.example.com")[0]).toBeInTheDocument();
    expect(screen.getByText("native")).toBeInTheDocument();
  });

  it('should render ApplicationDashboard for app type "saml"', async () => {
    const location = {
      type: "app",
      info: { name: "saml_test", type: "SPsaml" },
    };

    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    expect(screen.getAllByText("saml_test")[0]).toBeInTheDocument();
    expect(screen.getByText("SPsaml")).toBeInTheDocument();
    fireEvent.click(await screen.findByTestId("samlSPMetaDataXML"));

    (fetch as jest.Mock).mockResolvedValueOnce({
      ok: true,
      statusText: "OK",
      json: () => Promise.resolve({ key: "value" }),
    });

    fireEvent.change(screen.getByPlaceholderText(t("url")), {
      target: { value: "http://example.com" },
    });
    fireEvent.click(screen.getByText(t("load")));
    await screen.findByText(t("loading"));

    expect(fetch).toHaveBeenCalledWith("/prx", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ url: "http://example.com" }),
    });
  });

  it('should render ApplicationDashboard for app type "oidc"', async () => {
    const location = {
      type: "app",
      info: { name: "oidc_test", type: "RPoidc" },
    };

    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    expect(screen.getAllByText("oidc_test")[0]).toBeInTheDocument();
    expect(screen.getByText("RPoidc")).toBeInTheDocument();
  });

  it('should render ApplicationDashboard for app type "cas"', async () => {
    const location = {
      type: "app",
      info: { name: "cas_test", type: "AppCas" },
    };

    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    expect(screen.getAllByText("cas_test")[0]).toBeInTheDocument();
    expect(screen.getByText("AppCas")).toBeInTheDocument();
  });
  it('should render ApplicationDashboard for app type "native" and change data', async () => {
    const location = {
      type: "app",
      info: { name: "native.example.com", type: "native" },
    };

    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    expect(screen.getByText("basicOptions")).toBeInTheDocument();
    expect(screen.getByText("locationRules")).toBeInTheDocument();
    expect(
      screen.getByText("exportedHeaders", { selector: ".title2" })
    ).toBeInTheDocument();
    expect(screen.getByText("post")).toBeInTheDocument();
    expect(screen.getByText("vhostOptions")).toBeInTheDocument();
    changeRadio(0);
    clickOption("locationRules");

    fireEvent.click(screen.getAllByTestId("AddCircleIcon")[0]);

    expect(screen.getByDisplayValue("New rule")).toBeInTheDocument();
    changeInput(1, "test");
    changeInput(2, "alias");

    fireEvent.click(screen.getAllByTestId("RemoveCircleIcon")[2]);
    expect(screen.queryByDisplayValue("New rule")).not.toBeInTheDocument();
    clickOption("exportedHeaders");

    fireEvent.click(screen.getAllByTestId("AddCircleIcon")[0]);
    expect(screen.getByDisplayValue("new")).toBeInTheDocument();
    changeInput(0, "test");
    changeInput(1, "alias");
    fireEvent.click(screen.getAllByTestId("RemoveCircleIcon")[0]);
    expect(screen.queryByDisplayValue("new")).not.toBeInTheDocument();
    clickOption("vhostOptions");

    clickOption("post");
    fireEvent.click(screen.getAllByTestId("AddCircleIcon")[0]);
    expect(
      screen.getByDisplayValue("/absolute/path/to/form")
    ).toBeInTheDocument();
    changeInput(1, "alias");
    changeInput(2, "alias");
    fireEvent.click(screen.getAllByTestId("RemoveCircleIcon")[0]);
    expect(
      screen.queryByDisplayValue("/absolute/path/to/form")
    ).not.toBeInTheDocument();
    clickOption("vhostOptions");

    changeRadio(0);
    changeInput(0, 2);
    changeInput(1, "alias");
    changeInput(2, "alias");
    changeSelect("Main", 0, "CDA");
    expect(screen.getByText(t("CDA"))).toBeInTheDocument();

    changeInput(1, "alias");
  });

  it("should trigger navigation when clicking on Breadcrumbs link", async () => {
    const location = {
      type: "app",
      info: { name: "oidc_test", type: "RPoidc" },
    };
    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    fireEvent.click(
      screen.getByText(location.info.name, { selector: ".MuiLink-root" })
    );
    expect(
      screen.getByText(location.info.name, { selector: ".title" })
    ).toBeInTheDocument();
  });
  test('should render ApplicationDashboard for app type "cas" and adds new exported variable', async () => {
    const location = {
      type: "app",
      info: { name: "cas_test", type: "AppCas" },
    };
    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    fireEvent.click(screen.getAllByTestId("AddCircleIcon")[0]);
    expect(screen.getByDisplayValue("new")).toBeInTheDocument();
  });
  test('should render ApplicationDashboard for app type "cas" from the parameter tree', async () => {
    const location = {
      type: "app",
      info: { name: "cas_test", type: "AppCas" },
    };
    const { store } = renderWithProviders(<Configuration location={location} />);
    const conf = () =>
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      store.getState().config.data.config as unknown as Record<string, any>;
    const row = (param: string) =>
      // eslint-disable-next-line testing-library/no-node-access
      screen.getByText(param, { selector: "th" }).closest("tr")!;

    fireEvent.click(await screen.findByTestId("casAppMetaDataMacros"));
    fireEvent.click(screen.getAllByTestId("AddCircleIcon")[0]);
    expect(conf().casAppMetaDataMacros.cas_test).toEqual({ new: "" });

    fireEvent.click(screen.getByTestId("casAppMetaDataOptions"));
    expect(screen.getByDisplayValue("https://google.com")).toBeInTheDocument();
    fireEvent.change(
      // eslint-disable-next-line testing-library/no-node-access
      row("casAppMetaDataOptionsUserAttribute").querySelector("input")!,
      { target: { value: "mail" } }
    );
    expect(
      conf().casAppMetaDataOptions.cas_test.casAppMetaDataOptionsUserAttribute
    ).toBe("mail");
    fireEvent.click(
      within(row("casAppMetaDataOptionsLogout")).getByLabelText(t("on"))
    );
    expect(conf().casAppMetaDataOptions.cas_test.casAppMetaDataOptionsLogout).toBe(
      1
    );

    fireEvent.click(screen.getByTestId("casAppMetaDataOptionsDisplay"));
    fireEvent.change(
      // eslint-disable-next-line testing-library/no-node-access
      row("casAppMetaDataOptionsDisplayName").querySelector("input")!,
      { target: { value: "My CAS app" } }
    );
    expect(
      conf().casAppMetaDataOptions.cas_test.casAppMetaDataOptionsDisplayName
    ).toBe("My CAS app");
  });
  test('should render ApplicationDashboard for app type "oidc" from the parameter tree', async () => {
    const location = {
      type: "app",
      info: { name: "oidc_test", type: "RPoidc" },
    };
    const { store } = renderWithProviders(<Configuration location={location} />);
    const rp = () =>
      store.getState().config.data.config.oidcRPMetaDataOptions!.oidc_test;
    const row = (param: string) =>
      // eslint-disable-next-line testing-library/no-node-access
      screen.getByText(param, { selector: "th" }).closest("tr")!;

    // Basic options: only the parameters of the tree, labelled once
    fireEvent.click(await screen.findByTestId("oidcRPMetaDataOptionsBasic"));
    expect(screen.getAllByText("oidcRPMetaDataOptionsClientID")).toHaveLength(1);
    expect(screen.queryByText("oidcRPMetaDataOptionsAuthMethod")).toBeNull();
    fireEvent.change(screen.getByDisplayValue("abab"), {
      target: { value: "New Client ID" },
    });
    expect(rp().oidcRPMetaDataOptionsClientID).toBe("New Client ID");

    // Security: the token endpoint auth method is a select, mTLS is inline
    fireEvent.click(screen.getByTestId("oidcRPMetaDataOptions"));
    fireEvent.click(await screen.findByTestId("security"));
    expect(screen.getByText("mtls", { selector: "th" })).toBeInTheDocument();
    expect(
      // eslint-disable-next-line testing-library/no-node-access
      row("oidcRPMetaDataOptionsAuthMethod").querySelector(".MuiSelect-select")
    ).not.toBeNull();
    fireEvent.change(
      // eslint-disable-next-line testing-library/no-node-access
      row("oidcRPMetaDataOptionsAuthMethod").querySelector("input")!,
      { target: { value: "private_key_jwt" } }
    );
    expect(rp().oidcRPMetaDataOptionsAuthMethod).toBe("private_key_jwt");

    // Scopes: two independent hashes stored outside the options
    fireEvent.click(screen.getByTestId("oidcRPMetaDataOptionsScopes"));
    fireEvent.click(screen.getAllByTestId("AddCircleIcon")[2]);
    expect(
      store.getState().config.data.config.oidcRPMetaDataScopeRules?.oidc_test
    ).toEqual({ new: "" });
    expect(
      store.getState().config.data.config.oidcRPMetaDataOptionsExtraClaims
        ?.oidc_test
    ).toBeUndefined();

    // Timeouts are stored as numbers
    fireEvent.click(screen.getByTestId("oidcRPMetaDataOptionsTimeouts"));
    fireEvent.change(
      // eslint-disable-next-line testing-library/no-node-access
      row("oidcRPMetaDataOptionsRtActivity").querySelector("input")!,
      { target: { value: "30" } }
    );
    expect(rp().oidcRPMetaDataOptionsRtActivity).toBe(30);

    // Keys: JWKS document upload
    fireEvent.click(screen.getByTestId("oidcRpKeys"));
    const file = new File(["file content"], "file.txt", { type: "text/plain" });
    fireEvent.change(screen.getByLabelText("upload"), {
      target: { files: [file] },
    });
    expect(await screen.findByText("file content")).toBeDefined();

    // Display section, missing from the former hard-coded page
    fireEvent.click(screen.getByTestId("oidcRPMetaDataOptionsDisplay"));
    fireEvent.change(
      // eslint-disable-next-line testing-library/no-node-access
      row("oidcRPMetaDataOptionsDisplayName").querySelector("input")!,
      { target: { value: "My RP" } }
    );
    expect(rp().oidcRPMetaDataOptionsDisplayName).toBe("My RP");
  });
  test('should render ApplicationDashboard for app type "saml" from the parameter tree', async () => {
    const location = {
      type: "app",
      info: { name: "saml_test", type: "SPsaml" },
    };
    const { store } = renderWithProviders(<Configuration location={location} />);
    const conf = () =>
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      store.getState().config.data.config as unknown as Record<string, any>;
    const sp = () => conf().samlSPMetaDataOptions.saml_test;
    const row = (param: string) =>
      // eslint-disable-next-line testing-library/no-node-access
      screen.getByText(param, { selector: "th" }).closest("tr")!;
    const select = (param: string, value: string) =>
      fireEvent.change(
        // eslint-disable-next-line testing-library/no-node-access
        row(param).querySelector("input")!,
        { target: { value } }
      );

    // Metadata XML is stored apart from the options
    fireEvent.click(await screen.findByTestId("samlSPMetaDataXML"));
    const file = new File(["file content"], "file.txt", { type: "text/plain" });
    fireEvent.change(screen.getByLabelText("upload"), {
      target: { files: [file] },
    });
    expect(await screen.findByText("file content")).toBeDefined();
    expect(conf().samlSPMetaDataXML.saml_test.samlSPMetaDataXML).toBe(
      "file content"
    );

    fireEvent.click(screen.getByTestId("samlSPMetaDataExportedAttributes"));
    fireEvent.click(screen.getAllByTestId("AddCircleIcon")[0]);
    expect(conf().samlSPMetaDataExportedAttributes.saml_test).toHaveProperty(
      "new"
    );

    fireEvent.click(screen.getByTestId("samlSPMetaDataMacros"));
    fireEvent.click(screen.getAllByTestId("AddCircleIcon")[0]);
    expect(conf().samlSPMetaDataMacros.saml_test).toEqual({ new: "" });

    fireEvent.click(screen.getByTestId("samlSPMetaDataOptions"));
    fireEvent.click(
      await screen.findByTestId("samlSPMetaDataOptionsAuthnResponse")
    );
    fireEvent.change(
      // eslint-disable-next-line testing-library/no-node-access
      row("samlSPMetaDataOptionsNotOnOrAfterTimeout").querySelector("input")!,
      { target: { value: "120" } }
    );
    expect(sp().samlSPMetaDataOptionsNotOnOrAfterTimeout).toBe(120);

    fireEvent.click(screen.getByTestId("samlSPMetaDataOptionsSignature"));
    select("samlSPMetaDataOptionsSignatureMethod", "RSA_SHA256");
    expect(sp().samlSPMetaDataOptionsSignatureMethod).toBe("RSA_SHA256");

    fireEvent.click(screen.getByTestId("samlSPMetaDataOptionsSecurity"));
    select("samlSPMetaDataOptionsEncryptionMode", "nameid");
    expect(sp().samlSPMetaDataOptionsEncryptionMode).toBe("nameid");

    fireEvent.click(screen.getByTestId("samlSPMetaDataOptionsFederation"));
    select("samlSPMetaDataOptionsFederationOptionalAttributes", "ignore");
    expect(sp().samlSPMetaDataOptionsFederationOptionalAttributes).toBe(
      "ignore"
    );
  });
});
