import "@testing-library/jest-dom";
import { act, fireEvent, screen, waitFor } from "@testing-library/react";
import { t } from "i18next";
import { Configuration } from "../src/pages/Configuration";
import { renderWithProviders } from "../src/utils/test-utils";


describe("Configuration Component", () => {
  it('should render ApplicationDashboard for location type "app"', async () => {
    const location = {
      type: "app",
      info: { name: "TestApp", type: "TestType" },
    };

    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    expect(screen.getByText("TestApp")).toBeInTheDocument();
    expect(screen.getByText("TestType")).toBeInTheDocument();
  });

  it('should render Manager and AddApp for location type "conf"', async () => {
    const location = { type: "conf", info: { name: "TestConf" } };

    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    expect(screen.getByText(t("currentConfiguration"))).toBeInTheDocument();
  });

  it('should render SimpleAuthParams by default and toggle to AdvancedAuthParams for location type "authParams"', async () => {
    const location = { type: "authParams", info: { name: "latest" } };

    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    expect(
      screen.queryByText("", { selector: ".optionNavbar" })
    ).not.toBeInTheDocument();

    const selectInput = screen.getByLabelText(t("authentication"));
    const selectElement = selectInput.parentElement?.querySelector("input");

    await act(async () => {
      fireEvent.change(selectElement!, { target: { value: "Demo" } });
      fireEvent.click(screen.getByTestId("TuneIcon"));
    });

    await waitFor(() => {
      expect(
        screen.getByText("", { selector: ".optionNavbar" })
      ).toBeInTheDocument();
    });
  });

  it('should render IssuerDashboard for location type "issuer"', async () => {
    const location = { type: "issuer", info: { name: "TestIssuer" } };

    renderWithProviders(<Configuration location={location} />);
    await screen.findAllByText("14");

    expect(screen.getByText("TestIssuer")).toBeInTheDocument();
  });
});
