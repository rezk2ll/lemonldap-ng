import { apiUrl, staticUrl } from "../../src/utils/urls";

describe("URL helpers", () => {
  afterEach(() => {
    delete (window as any).scriptname;
    delete (window as any).staticPrefix;
  });

  it("default to a manager served at the root", () => {
    expect(apiUrl("confs/latest")).toBe("/confs/latest");
    expect(staticUrl("nstruct.json")).toBe("/static/nstruct.json");
  });

  it("follow the paths given by psgi.js", () => {
    (window as any).scriptname = "/manager.psgi/";
    (window as any).staticPrefix = "/llng-static/";
    expect(apiUrl("confs/latest")).toBe("/manager.psgi/confs/latest");
    expect(staticUrl("nstruct.json")).toBe("/llng-static/nstruct.json");
  });
});
