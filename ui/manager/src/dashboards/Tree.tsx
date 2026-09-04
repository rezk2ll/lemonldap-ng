import EditIcon from "@mui/icons-material/Edit";
import FormatListBulletedIcon from "@mui/icons-material/FormatListBulleted";
import HelpOutlineIcon from "@mui/icons-material/HelpOutline";
import KeyboardArrowDownIcon from "@mui/icons-material/KeyboardArrowDown";
import KeyboardArrowRightIcon from "@mui/icons-material/KeyboardArrowRight";
import { Box, CircularProgress, Link } from "@mui/material";
import { useEffect, useRef, useState } from "react";
import { NodeApi, NodeRendererProps, Tree, TreeApi } from "react-arborist";
import useResizeObserver from "use-resize-observer";
import { TreeNode, recursTree, treeFormat } from "../utils/recursTree";
import { findElementByTitleOrValue } from "../utils/searchIntree";
import { llngConfig } from "../utils/types";
import "./Tree.css";
import { TreeNodeType } from "./TreeNode";
import { t } from "i18next";

export function ToggleConfTree(
  itemId: string,
  treeRef: React.RefObject<TreeApi<treeFormat>>,
  tree: TreeNode[],
  config: llngConfig,
  setItems: React.Dispatch<React.SetStateAction<treeFormat[] | undefined>>
): void {
  const item = treeRef.current?.get(itemId)?.data;
  if (item) {
    const updateChildren = (node: treeFormat): treeFormat => {
      if (node?.children) {
        node.children = node.children.map((child: any) => {
          const childId = child.id.split(";").at(-1) || "";
          const foundElement = findElementByTitleOrValue(
            tree,
            childId,
            child.id.split(";").at(-2)
          );
          if (foundElement) {
            child = recursTree(foundElement, config, node.id, node.app);
          }
          child = updateChildren(child);
          return child;
        });
      } else {
        const id = node.id.split(";").at(-1) || "";
        const foundElement = findElementByTitleOrValue(
          tree,
          id,
          node.id.split(";").at(-2)
        );
        if (foundElement) {
          return recursTree(foundElement, config, item.id, item.app);
        }
      }
      return node;
    };

    item.children = item.children?.map(updateChildren);

    setItems((prevItems) =>
      prevItems?.map((el) => (el.id === itemId ? { ...item } : el))
    );
  }
}

export default function TreeRender({
  tree,
  config,
}: {
  tree?: TreeNode[];
  config: llngConfig;
}) {
  const treeRef = useRef<TreeApi<treeFormat>>(null);
  const [ITEMS, setItems] = useState(
    tree?.map((el: TreeNode) => recursTree(el, config, "root"))
  );
  const [selectedItem, setSelectedItem] = useState<NodeApi<treeFormat> | null>(
    null
  );
  const { ref, width, height = 1 } = useResizeObserver();
  useEffect(() => {
    setItems(tree?.map((el: TreeNode) => recursTree(el, config, "root")));
    treeRef.current?.closeAll();
  }, [tree, config]);

  useEffect(() => {
    if (selectedItem) {
      let node = selectedItem;
      const parents = [];
      while (node?.parent) {
        node = node.parent;
        parents.push(node);
      }
      parents.reverse().forEach((parent) => {
        ToggleConfTree(parent.id, treeRef, tree || [], config, setItems);
        treeRef.current?.get(parent.id)?.open();
      });
    }
  }, [selectedItem, tree, config]);
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
              onToggle={(itemId) => {
                ToggleConfTree(itemId, treeRef, tree, config, setItems);
              }}
              height={height}
              width={width}
              onFocus={(node) => {
                setSelectedItem(node);
              }}
              data={ITEMS}
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
