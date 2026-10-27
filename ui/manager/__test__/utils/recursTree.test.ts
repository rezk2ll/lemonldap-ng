import { recursTree, TreeNode } from "../../src/utils/recursTree";
import { llngConfig } from "../../src/utils/types";

const tree: TreeNode[] = [
  {
    title: "generalParameters",
    _nodes: [
      { title: "portal" },
      { title: "advancedParams", _nodes: [{ title: "timeout" }] },
    ],
    _nodes_cond: [{ title: "condNode" }],
  },
  {
    title: "oidcRPMetaDataNodes",
    cnodes: [
      {
        title: "oidcRPMetaDataOptionsBasic",
        _nodes: [{ title: "oidcRPMetaDataOptionsClientID" }],
      },
    ],
  },
  { title: "applicationList", cnodes: "applicationList" } as unknown as TreeNode,
];

const config = {
  oidcRPMetaDataOptions: { rp1: {}, rp2: {} },
  applicationList: {
    "1cat": {
      catname: "Category",
      type: "category",
      order: 1,
      options: { translation: "myCategory" },
      app2: { type: "application", order: 2, options: { name: "App 2" } },
      app1: { type: "application", order: 1, options: { name: "App 1" } },
    },
  },
} as unknown as llngConfig;

describe("recursTree", () => {
  it("builds nested nodes with structural ids and parents", () => {
    const root = recursTree(tree[0], config, "root");
    expect(root.id).toBe("root;generalParameters");
    expect(root.parent).toBe("root");
    expect(root.children?.map((c) => c.id)).toEqual([
      "root;generalParameters;portal",
      "root;generalParameters;advancedParams",
      "root;generalParameters;condNode",
    ]);
    const advanced = root.children?.[1];
    expect(advanced?.children?.[0]).toMatchObject({
      id: "root;generalParameters;advancedParams;timeout",
      parent: "root;generalParameters;advancedParams",
    });
    expect("children" in (root.children?.[0] || {})).toBe(false);
  });

  it("does not alter the parameter tree", () => {
    recursTree(tree[0], config, "root").children;
    recursTree(tree[0], config, "root").children;
    expect(tree[0]._nodes).toHaveLength(2);
  });

  it("builds one subtree per application", () => {
    const rps = recursTree(tree[1], config, "root");
    expect(rps.children?.map((c) => [c.id, c.app, c.type])).toEqual([
      ["root;oidcRPMetaDataNodes;rp1", "rp1", "oidcRPMetaDataNode"],
      ["root;oidcRPMetaDataNodes;rp2", "rp2", "oidcRPMetaDataNode"],
    ]);
    expect(rps.children?.[1].children?.[0].children?.[0]).toMatchObject({
      id: "root;oidcRPMetaDataNodes;rp2;oidcRPMetaDataOptionsBasic;oidcRPMetaDataOptionsClientID",
      app: "rp2",
    });
  });

  it("keeps only applications in a category, not its options", () => {
    const list = recursTree(tree[2], config, "root");
    const cat = list.children?.[0];
    expect(cat).toMatchObject({ id: "applicationList;1cat", name: "Category" });
    expect(cat?.children?.map((c) => [c.id, c.name])).toEqual([
      ["applicationList;1cat;app1", "App 1"],
      ["applicationList;1cat;app2", "App 2"],
    ]);
  });

  it("builds children only when they are read", () => {
    const keys = vi.spyOn(Object, "keys");
    const rps = recursTree(tree[1], config, "root");
    const before = keys.mock.calls.length;
    rps.children;
    expect(keys.mock.calls.length).toBeGreaterThan(before);
    const after = keys.mock.calls.length;
    rps.children;
    expect(keys.mock.calls.length).toBe(after);
    keys.mockRestore();
  });
});
