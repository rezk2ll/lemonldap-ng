import EditIcon from "@mui/icons-material/Edit";
import FormatListBulletedIcon from "@mui/icons-material/FormatListBulleted";
import HelpOutlineIcon from "@mui/icons-material/HelpOutline";
import KeyboardArrowDownIcon from "@mui/icons-material/KeyboardArrowDown";
import KeyboardArrowRightIcon from "@mui/icons-material/KeyboardArrowRight";
import { Box, CircularProgress, Link } from "@mui/material";
import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { NodeApi, NodeRendererProps, Tree, TreeApi } from "react-arborist";
import useResizeObserver from "use-resize-observer";
import { TreeNode, recursTree, treeFormat } from "../utils/recursTree";
import { llngConfig } from "../utils/types";
import "./Tree.css";
import { TreeNodeType } from "./TreeNode";
import { t } from "i18next";

export default function TreeRender({
  tree,
  config,
}: {
  tree?: TreeNode[];
  config: llngConfig;
}) {
  const treeRef = useRef<TreeApi<treeFormat>>(null);
  // Children are built lazily (see recursTree), so rebuilding the roots on a
  // configuration change is cheap. Open state is kept by react-arborist, keyed
  // by node id.
  const items = useMemo(
    () => tree?.map((el: TreeNode) => recursTree(el, config, "root")),
    [tree, config]
  );
  const [selectedItem, setSelectedItem] = useState<NodeApi<treeFormat> | null>(
    null
  );
  const { ref, width, height = 1 } = useResizeObserver();
  // A configuration change rebuilds the nodes: point the detail pane at the
  // new instance of the selected one (react-arborist has updated by now).
  useEffect(() => {
    setSelectedItem((prev) => (prev && treeRef.current?.get(prev.id)) || prev);
  }, [items]);

  // react-arborist rebuilds its whole node tree on each update (every
  // open/close). Only hand it the children of visible nodes: those of an open
  // node, and one level more so that the selected node's children are known
  // to the detail pane (simpleInputContainer, container forms). Closed
  // internal nodes get an empty list, which keeps them displayed as folders.
  const childrenAccessor = useCallback((d: treeFormat) => {
    if (!("children" in d)) return null;
    const api = treeRef.current;
    if (
      d.parent === "root" ||
      (api && (api.isOpen(d.id) || (d.parent && api.isOpen(d.parent))))
    ) {
      return d.children || [];
    }
    return [];
  }, []);
  const onFocus = useCallback(
    (node: NodeApi<treeFormat>) => setSelectedItem(node),
    []
  );

  if (tree) {
    return (
      <>
        <div className="treeHeader">
          <strong className="title">{t("advancedConfiguration")}</strong>
          {selectedItem?.data?.name && (
            <span className="treeBreadcrumb">{selectedItem.data.name}</span>
          )}
          {selectedItem?.data.help && (
            <Link
              className="treeHelp"
              target="blank"
              href={
                config.managerDn +
                "/doc/pages/documentation/current/" +
                selectedItem?.data.help
              }
            >
              <HelpOutlineIcon />
            </Link>
          )}
        </div>
        <div className="treePage">
          <div className="tree" ref={ref}>
            <Tree
              disableDrag={true}
              rowHeight={34}
              ref={treeRef}
              height={height}
              width={width}
              onFocus={onFocus}
              data={items}
              childrenAccessor={childrenAccessor}
              openByDefault={false}
            >
              {Node}
            </Tree>
          </div>
          <div className="treeDetail">
            <div className="nodeContent">
              {selectedItem?.data?.type && (
                <table>
                  <tbody>
                    <TreeNodeType node={selectedItem} config={config} />
                  </tbody>
                </table>
              )}
            </div>
          </div>
        </div>
      </>
    );
  } else {
    return (
      <Box sx={{ display: "flex" }}>
        <CircularProgress />
      </Box>
    );
  }
}

// Leaf node types that edit a collection of keys/values (a "hash" parameter,
// like macros) rather than a single value — they get a distinct icon. The tree
// already tells them apart through the type since it renders a different form
// for each, so no separate lookup is needed.
const MULTI_VALUE_TYPES = new Set([
  "keyTextContainer",
  "grantContainer",
  "ruleContainer",
  "postContainer",
  "blackWhiteList",
  "doubleHash",
  "samlAttributeContainer",
  "oidcAttributeContainer",
  "authChoiceContainer",
  "cmbModuleContainer",
  "sfExtraContainer",
]);

function Node({ node, style }: NodeRendererProps<treeFormat>) {
  const isLeaf = !node.isInternal;
  const isMultiValue = isLeaf && MULTI_VALUE_TYPES.has(node.data.type || "");
  const Icon = node.isInternal
    ? node.isOpen
      ? KeyboardArrowDownIcon
      : KeyboardArrowRightIcon
    : isMultiValue
      ? FormatListBulletedIcon
      : EditIcon;

  return (
    // `style` carries react-arborist row positioning; React applies it through
    // the CSSOM, which the Content-Security-Policy allows (unlike a literal
    // style attribute). The per-level indent is added the same way.
    <div
      className={"treeitem" + (node.isSelected ? " selected" : "")}
      style={style}
      onClick={() => {
        if (node.data.type !== "simpleInputContainer") {
          node.toggle();
        }
      }}
    >
      <div className="treeitemInner" style={{ paddingLeft: node.level * 16 + 8 }}>
        <Icon
          fontSize="small"
          className={
            isMultiValue
              ? "treeMultiIcon"
              : isLeaf
                ? "treeLeafIcon"
                : "treeToggleIcon"
          }
        />
        <span className="treeitemLabel">{node?.data.name}</span>
      </div>
    </div>
  );
}
