import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import VisibilityIcon from "@mui/icons-material/Visibility";
import { Chip, CircularProgress } from "@mui/material";
import { useState } from "react";
import { localeDate } from "../../features/sessions/sessionDisplay";
import { loadChildren, TreeNode } from "../../features/sessions/tree";

export function SessionTreeNode({
  type,
  sessionType,
  node,
  depth,
  selectedId,
  onSelect,
  removedIds,
}: {
  type: string;
  sessionType: string;
  node: TreeNode;
  depth: number;
  selectedId: string | null;
  onSelect: (node: TreeNode) => void;
  removedIds: Set<string>;
}) {
  const [expanded, setExpanded] = useState(false);
  const [children, setChildren] = useState<TreeNode[] | null>(null);
  const [loading, setLoading] = useState(false);

  if (node.isLeaf) {
    const selected = node.id === selectedId;
    return (
      <div
        className={"sessionLeaf" + (selected ? " selected" : "")}
        style={{ paddingLeft: depth * 16 + 22 }}
        onClick={() => onSelect(node)}
      >
        <VisibilityIcon fontSize="inherit" />
        <span>{localeDate(node.date)}</span>
      </div>
    );
  }

  const toggle = async () => {
    if (!expanded && children === null) {
      setLoading(true);
      try {
        const { children: ch } = await loadChildren(type, sessionType, {
          value: node.value ?? "",
          level: node.level,
          over: node.over,
          query: node.query,
          count: node.count,
        });
        setChildren(ch);
      } finally {
        setLoading(false);
      }
    }
    setExpanded(!expanded);
  };

  const visibleChildren = (children || []).filter((c) => !removedIds.has(c.id));

  return (
    <div>
      <div
        className="sessionGroup"
        style={{ paddingLeft: depth * 16 }}
        onClick={toggle}
      >
        {expanded ? (
          <ExpandMoreIcon fontSize="small" />
        ) : (
          <ChevronRightIcon fontSize="small" />
        )}
        <span className="sessionGroupTitle">{node.title || node.value}</span>
        {node.count != null && (
          <Chip size="small" label={node.count} className="sessionCount" />
        )}
        {loading && <CircularProgress size={12} sx={{ ml: 1 }} />}
      </div>
      {expanded &&
        visibleChildren.map((c) => (
          <SessionTreeNode
            key={c.id}
            type={type}
            sessionType={sessionType}
            node={c}
            depth={depth + 1}
            selectedId={selectedId}
            onSelect={onSelect}
            removedIds={removedIds}
          />
        ))}
    </div>
  );
}
