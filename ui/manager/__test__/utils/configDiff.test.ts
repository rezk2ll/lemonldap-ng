import { configDiff } from "../../src/utils/configDiff";

describe("configDiff", () => {
  it("returns nothing for identical configurations", () => {
    const conf = { portal: "https://auth.example.com/", locationRules: { a: { default: "accept" } } };
    expect(configDiff(conf, structuredClone(conf))).toEqual([]);
  });

  it("lists added, removed and changed leaves", () => {
    expect(
      configDiff(
        { portal: "a", timeout: 72000, locationRules: { "a.com": { default: "accept" } } },
        { portal: "b", locationRules: { "a.com": { default: "accept", "^/admin": "deny" } }, newParam: 1 }
      )
    ).toEqual([
      { path: ["locationRules", "a.com", "^/admin"], kind: "added", after: "deny" },
      { path: ["newParam"], kind: "added", after: 1 },
      { path: ["portal"], kind: "changed", before: "a", after: "b" },
      { path: ["timeout"], kind: "removed", before: 72000 },
    ]);
  });

  it("lists the leaves of an added or removed application", () => {
    expect(
      configDiff(
        { oidcRPMetaDataOptions: { old: { clientId: "x" } } },
        { oidcRPMetaDataOptions: { new: { clientId: "y", public: 1 } } }
      )
    ).toEqual([
      { path: ["oidcRPMetaDataOptions", "new", "clientId"], kind: "added", after: "y" },
      { path: ["oidcRPMetaDataOptions", "new", "public"], kind: "added", after: 1 },
      { path: ["oidcRPMetaDataOptions", "old", "clientId"], kind: "removed", before: "x" },
    ]);
  });

  it("ignores type-only and empty changes, and save metadata", () => {
    expect(
      configDiff(
        { cfgNum: 3, cfgLog: "a", issuerDBSAMLActivation: 1, empty: "", list: [1, 2] },
        { cfgNum: 4, cfgLog: "b", issuerDBSAMLActivation: "1", vhostOptions: { a: {} }, list: [1, 2] }
      )
    ).toEqual([]);
  });

  it("compares arrays as a whole", () => {
    expect(configDiff({ list: [1, 2] }, { list: [2, 1] })).toEqual([
      { path: ["list"], kind: "changed", before: [1, 2], after: [2, 1] },
    ]);
  });
});
