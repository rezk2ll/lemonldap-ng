import SecurityOutlinedIcon from "@mui/icons-material/SecurityOutlined";
import {
  Checkbox,
  Chip,
  CircularProgress,
  FormControlLabel,
  TextField,
} from "@mui/material";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { TwofaDetail } from "../components/twofaComponents/TwofaDetail";
import { TwofaTreeNode } from "../components/twofaComponents/TwofaTreeNode";
import { get2FTypes } from "../features/2fa/twofaAPI";
import {
  loadChildren,
  ROOT_CONTEXT,
  searchUsers,
  SfaNode,
} from "../features/2fa/twofaTree";
import "./SessionsExplorer.css";

export function TwofaExplorer() {
  const { t } = useTranslation();
  const [availableTypes, setAvailableTypes] = useState<string[]>([]);
  const [selectedTypes, setSelectedTypes] = useState<Set<string>>(new Set());
  const [search, setSearch] = useState("");
  const [rootChildren, setRootChildren] = useState<SfaNode[] | null>(null);
  const [total, setTotal] = useState(0);
  const [selected, setSelected] = useState<SfaNode | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    get2FTypes().then(setAvailableTypes);
  }, []);

  const typesKey = Array.from(selectedTypes).sort().join(",");

  useEffect(() => {
    let cancelled = false;
    const handle = setTimeout(() => {
      setLoading(true);
      setRootChildren(null);
      setSelected(null);
      const typesArr = typesKey ? typesKey.split(",") : [];
      const q = search.trim()
        ? searchUsers(search.trim(), typesArr)
        : loadChildren(ROOT_CONTEXT, typesArr);
      q.then(({ children, total }) => {
        if (!cancelled) {
          setRootChildren(children);
          setTotal(total);
          setLoading(false);
        }
      }).catch(() => {
        if (!cancelled) {
          setRootChildren([]);
          setLoading(false);
        }
      });
    }, 300);
    return () => {
      cancelled = true;
      clearTimeout(handle);
    };
  }, [search, typesKey]);

  const toggleType = (type: string) => {
    setSelectedTypes((s) => {
      const next = new Set(s);
      if (next.has(type)) next.delete(type);
      else next.add(type);
      return next;
    });
  };

  const typesArr = typesKey ? typesKey.split(",") : [];

  return (
    <div className="sessionsExplorer">
      <aside className="sessionsNav">
        <div className="sessionNavHeader">
          <SecurityOutlinedIcon fontSize="small" />
          <span>{t("secondFactors")}</span>
        </div>
        <TextField
          size="small"
          fullWidth
          margin="dense"
          placeholder={t("search")}
          value={search}
          onChange={(e) => setSearch(e.target.value)}
        />
        <div className="twofaTypeFilters">
          {availableTypes.map((type) => (
            <FormControlLabel
              key={type}
              control={
                <Checkbox
                  size="small"
                  checked={selectedTypes.has(type)}
                  onChange={() => toggleType(type)}
                />
              }
              label={t(type, type)}
            />
          ))}
        </div>
      </aside>

      <section className="sessionsTree">
        <div className="sessionsTreeHeader">
          <strong>{t("secondFactors")}</strong>
          <Chip size="small" label={total} />
          {loading && <CircularProgress size={16} />}
        </div>
        <div className="sessionsTreeBody">
          {(rootChildren || []).map((node) => (
            <TwofaTreeNode
              key={node.id}
              node={node}
              types={typesArr}
              depth={0}
              selectedId={selected ? selected.id : null}
              onSelect={setSelected}
            />
          ))}
          {!loading && (rootChildren || []).length === 0 && (
            <div className="sessionsEmpty">{t("noData")}</div>
          )}
        </div>
      </section>

      <section className="sessionsDetailPane">
        {selected ? (
          <TwofaDetail node={selected} />
        ) : (
          <div className="sessionsDetailPlaceholder">{t("clickToDisplay")}</div>
        )}
      </section>
    </div>
  );
}
