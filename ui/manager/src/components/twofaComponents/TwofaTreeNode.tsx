import ChevronRightIcon from "@mui/icons-material/ChevronRight";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import PersonOutlineIcon from "@mui/icons-material/PersonOutline";
import { Chip, CircularProgress } from "@mui/material";
import { useState } from "react";
import { loadChildren, SfaNode } from "../../features/2fa/twofaTree";

export function TwofaTreeNode({
  node,
  types,
  depth,
  selectedId,
  onSelect,
}: {
  node: SfaNode;
  types: string[];
  depth: number;
  selectedId: string | null;
  onSelect: (node: SfaNode) => void;
}) {
  const [expanded, setExpanded] = useState(false);
  const [children, setChildren] = useState<SfaNode[] | null>(null);
  const [loading, setLoading] = useState(false);

  if (node.isLeaf) {
    const selected = node.id === selectedId;
    return (
      <div
        className={"sessionLeaf" + (selected ? " selected" : "")}
        style={{ paddingLeft: depth * 16 + 22 }}
        onClick={() => onSelect(node)}
      >
        <PersonOutlineIcon fontSize="inherit" />
        <span>{node.userId}</span>
      </div>
    );
  }

  const toggle = async () => {
    if (!expanded && children === null) {
      setLoading(true);
      try {
        const { children: ch } = await loadChildren(
          {
            value: node.value ?? "",
            level: node.level,
            over: node.over,
            count: node.count,
          },
          types
        );
        setChildren(ch);
      } finally {
        setLoading(false);
      }
    }
    setExpanded(!expanded);
  };

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
        (children || []).map((c) => (
          <TwofaTreeNode
            key={c.id}
            node={c}
            types={types}
            depth={depth + 1}
            selectedId={selectedId}
            onSelect={onSelect}
          />
        ))}
    </div>
  );
}
