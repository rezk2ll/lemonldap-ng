import { fireEvent, screen } from "@testing-library/react";
import { t } from "i18next";
import { Configuration } from "../src/pages/Configuration";
import attributes from "../src/static/attributes.json";
import { renderWithProviders } from "../src/utils/test-utils";
import {
  changeInput,
  changeRadio,
  changeSelect,
  changeSelectbis,
  clickOption,
  clickSubOption,
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
    clickOption("samlSPMetaDataXML");

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
  it('should render ApplicationDashboard for app type "cas" and navigate through data', async () => {
    const location = {
      type: "app",
      info: { name: "cas_test", type: "AppCas" },
    };

    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    fireEvent.click(
      screen.getByText(t("casAppMetaDataExportedVars"), { selector: ".option" })
    );
    expect(
      screen.getByText(t("casAppMetaDataExportedVars"), { selector: ".title2" })
    ).toBeInTheDocument();
    fireEvent.click(
      screen.getByText(t("casAppMetaDataMacros"), { selector: ".option" })
    );
    expect(
      screen.getByText(t("casAppMetaDataMacros"), { selector: ".title2" })
    ).toBeInTheDocument();

    fireEvent.click(
      screen.getByText(t("casAppMetaDataOptions"), { selector: ".option" })
    );
    expect(
      screen.getByText(t("casAppMetaDataOptions"), { selector: ".title2" })
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
  test('should render ApplicationDashboard for app type "cas" and adds new macro', async () => {
    const location = {
      type: "app",
      info: { name: "cas_test", type: "AppCas" },
    };
    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    fireEvent.click(
      screen.getByText(t("casAppMetaDataMacros"), { selector: ".option" })
    );
    fireEvent.click(screen.getAllByTestId("AddCircleIcon")[0]);
    expect(screen.getByDisplayValue("new")).toBeInTheDocument();
  });
  test('should render ApplicationDashboard for app type "cas" and change datas', async () => {
    const location = {
      type: "app",
      info: { name: "cas_test", type: "AppCas" },
    };
    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    fireEvent.click(
      screen.getByText(t("casAppMetaDataOptions"), { selector: ".option" })
    );
    fireEvent.click(screen.getByText(t("on")));
    expect(screen.getByLabelText(t("on"))).toBeChecked();
    expect(screen.getByLabelText(t("off"))).not.toBeChecked();

    const displayNameInput = screen.getAllByText("", {
      selector: ".MuiInputBase-input",
    })[0];
    fireEvent.change(displayNameInput, {
      target: { value: "New Display Name" },
    });
    expect(displayNameInput).toHaveDisplayValue("New Display Name");

    const serviceInput = screen.getAllByText("", {
      selector: ".MuiInputBase-input",
    })[1];
    fireEvent.change(serviceInput, { target: { value: "New Service Value" } });
    expect(serviceInput).toHaveDisplayValue("New Service Value");

    const authLevelInput = screen.getAllByText("", {
      selector: ".MuiInputBase-input",
    })[2];
    fireEvent.change(authLevelInput, {
      target: { value: 1 },
    });
    expect(authLevelInput).toHaveDisplayValue("1");
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
  test('should render ApplicationDashboard for app type "saml" and change datas', async () => {
    const location = {
      type: "app",
      info: { name: "saml_test", type: "SPsaml" },
    };
    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    clickOption("samlSPMetaDataXML");
    const file = new File(["file content"], "file.txt", { type: "text/plain" });

    fireEvent.change(screen.getByLabelText("upload"), {
      target: { files: [file] },
    });
    vi.fn().mockResolvedValue("file content");
    expect(await screen.findByText("file content")).toBeDefined();

    clickOption("samlSPMetaDataExportedAttributes");

    fireEvent.click(screen.getAllByTestId("AddCircleIcon")[0]);
    changeInput(0, "New Claim Name");
    changeInput(1, "New Variable Name");

    // changeRadio(0);
    changeSelect(
      "Unspecified",
      0,
      "urn:oasis:names:tc:SAML:2.0:attrname-format:uri"
    );

    expect(screen.getByText(t("URI"))).toBeDefined();

    clickOption("samlSPMetaDataMacros");
    fireEvent.click(screen.getAllByTestId("AddCircleIcon")[0]);
    changeInput(0, "New Key");
    changeInput(1, "New Value");

    const option = screen.getByTestId("samlSPMetaDataOptions");
    fireEvent.click(option);
    expect(option).toHaveClass("selected");
    changeSelectbis(0, "email");
    changeInput(0, "auth");
    changeInput(1, 2);
    changeInput(2, 3);
    changeRadio(0);
    changeRadio(1);

    clickSubOption("samlSPMetaDataOptionsSignature");
    changeRadio(0);

    changeSelect(t("default"), 0, "RSA_SHA256");
    expect(screen.getByText(t("RSA SHA256"))).toBeDefined();
    changeRadio(1);
    changeRadio(2);
    changeRadio(3);

    clickSubOption("samlSPMetaDataOptionsSecurity");
    changeInput(0, "auth");
    changeInput(1, 2);
    changeRadio(0);

    changeSelect(t("None"), 0, "nameid");
    expect(screen.getByText(t("Name ID"))).toBeDefined();

    clickSubOption("samlSPMetaDataOptionsFederation");

    changeSelect(t("keep"), 0, "ignore");
    expect(screen.getByText(t("ignore"))).toBeDefined();
  });
});
