import "@testing-library/jest-dom";
import { render, screen } from "@testing-library/react";
import Navbar from "../../src/components/Navbar";

const renderNavbar = () =>
  render(<Navbar htmlName="sessions.html" open={false} toggleNavbar={() => {}} />);

describe("Navbar", () => {
  afterEach(() => {
    delete (window as any).links;
  });

  it("shows every section when psgi.js gives no module list", () => {
    renderNavbar();
    for (const key of ["Configuration", "sessions", "notifications", "secondFactors"]) {
      expect(screen.getByText(key)).toBeInTheDocument();
    }
  });

  it("shows only the enabled modules", () => {
    (window as any).links = [
      { title: "sessions", target: "sessions.html", icon: "duplicate" },
      { title: "api", target: "api.html", icon: "flash" },
    ];
    renderNavbar();
    expect(screen.getByText("sessions")).toBeInTheDocument();
    for (const key of ["Configuration", "notifications", "secondFactors", "api"]) {
      expect(screen.queryByText(key)).not.toBeInTheDocument();
    }
  });
});
