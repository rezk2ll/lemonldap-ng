import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import VisibilityIcon from "@mui/icons-material/Visibility";
import { Chip, CircularProgress } from "@mui/material";
import { useState } from "react";
import { NotifType } from "../../features/notifications/notificationsAPI";
import {
  formatNotifDate,
  loadChildren,
  NotifNode,
} from "../../features/notifications/notifTree";

export function NotifTreeNode({
  type,
  node,
  depth,
  selectedId,
  onSelect,
  removedIds,
}: {
  type: NotifType;
  node: NotifNode;
  depth: number;
  selectedId: string | null;
  onSelect: (node: NotifNode) => void;
  removedIds: Set<string>;
}) {
  const [expanded, setExpanded] = useState(false);
  const [children, setChildren] = useState<NotifNode[] | null>(null);
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
        <span>
          {node.reference}
          {node.date ? ` (${formatNotifDate(node.date)})` : ""}
        </span>
      </div>
    );
  }

  const toggle = async () => {
    if (!expanded && children === null) {
      setLoading(true);
      try {
        const { children: ch } = await loadChildren(type, {
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
        <span className="sessionGroupTitle">{node.value}</span>
        {node.count != null && (
          <Chip size="small" label={node.count} className="sessionCount" />
        )}
        {loading && <CircularProgress size={12} sx={{ ml: 1 }} />}
      </div>
      {expanded &&
        visibleChildren.map((c) => (
          <NotifTreeNode
            key={c.id}
            type={type}
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
