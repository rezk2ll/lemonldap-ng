import "@testing-library/jest-dom";
import { render, screen } from "@testing-library/react";
import { vi } from "vitest";
import { ManagerHome } from "../src/dashboards/ManagerHome";

describe("ManagerHome", () => {
  afterEach(() => {
    delete (window as any).links;
    vi.unstubAllGlobals();
  });

  it("shows a card with its counter for each enabled module", async () => {
    (window as any).links = [
      { title: "sessions", target: "sessions.html" },
      { title: "notifications", target: "notifications.html" },
      { title: "api", target: "api.html" },
    ];
    const fetchMock = vi.fn(async (url: string) => {
      // The server may send the total as a string
      const total = url.includes("sessions/") ? 42 : "7";
      return new Response(JSON.stringify({ result: 1, count: 1, total, values: [] }));
    });
    vi.stubGlobal("fetch", fetchMock);

    render(<ManagerHome />);

    expect(await screen.findByText("42")).toBeInTheDocument();
    expect(await screen.findByText("7")).toBeInTheDocument();
    expect(screen.queryByText("Configuration")).not.toBeInTheDocument();
    expect(screen.queryByText("secondFactors")).not.toBeInTheDocument();
    expect(fetchMock).toHaveBeenCalledTimes(2);
  });

  it("shows the latest configuration", async () => {
    (window as any).links = [{ title: "conf", target: "manager.html" }];
    vi.stubGlobal(
      "fetch",
      vi.fn(async () =>
        new Response(JSON.stringify({ cfgNum: 12, cfgAuthor: "dwho", cfgLog: "Add app" }))
      )
    );

    render(<ManagerHome />);

    expect(await screen.findByText("#12")).toBeInTheDocument();
    expect(screen.getByText("dwho")).toBeInTheDocument();
    expect(screen.getByText("Add app")).toBeInTheDocument();
  });

  it("marks a counter as unavailable when its request fails", async () => {
    (window as any).links = [{ title: "sessions", target: "sessions.html" }];
    vi.stubGlobal("fetch", vi.fn(async () => new Response("Forbidden", { status: 403 })));

    render(<ManagerHome />);

    expect(await screen.findByText("unavailable")).toBeInTheDocument();
  });
});
