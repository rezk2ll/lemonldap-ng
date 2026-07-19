import AddCircleOutlineIcon from "@mui/icons-material/AddCircleOutline";
import CheckCircleOutlineIcon from "@mui/icons-material/CheckCircleOutline";
import NotificationsActiveOutlinedIcon from "@mui/icons-material/NotificationsActiveOutlined";
import { Chip, CircularProgress } from "@mui/material";
import { ReactNode, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { NotifCreateForm } from "../components/notificationsComponents/NotifCreateForm";
import { NotifDetail } from "../components/notificationsComponents/NotifDetail";
import { NotifTreeNode } from "../components/notificationsComponents/NotifTreeNode";
import { NotifType } from "../features/notifications/notificationsAPI";
import { loadChildren, NotifNode, ROOT_CONTEXT } from "../features/notifications/notifTree";
import "./SessionsExplorer.css";

type View = "actives" | "done" | "new";

function hashView(hash: string): View {
  const m = hash.match(/#?!?\/(\w+)/);
  if (!m) return "actives";
  if (m[1] === "done") return "done";
  if (m[1] === "new") return "new";
  return "actives";
}

const NAV: { key: string; hash: string; icon: ReactNode; view: View }[] = [
  { key: "actives", hash: "", icon: <NotificationsActiveOutlinedIcon fontSize="small" />, view: "actives" },
  { key: "dones", hash: "!/done", icon: <CheckCircleOutlineIcon fontSize="small" />, view: "done" },
  { key: "create", hash: "!/new", icon: <AddCircleOutlineIcon fontSize="small" />, view: "new" },
];

export function NotificationsExplorer() {
  const { t } = useTranslation();
  const [view, setView] = useState<View>(() => hashView(window.location.hash));
  const [rootChildren, setRootChildren] = useState<NotifNode[] | null>(null);
  const [total, setTotal] = useState(0);
  const [selected, setSelected] = useState<NotifNode | null>(null);
  const [removedIds, setRemovedIds] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const onHash = () => setView(hashView(window.location.hash));
    window.addEventListener("hashchange", onHash);
    return () => window.removeEventListener("hashchange", onHash);
  }, []);

  useEffect(() => {
    if (view === "new") {
      setRootChildren(null);
      setSelected(null);
      return;
    }
    let cancelled = false;
    setLoading(true);
    setRootChildren(null);
    setSelected(null);
    setRemovedIds(new Set());
    loadChildren(view as NotifType, ROOT_CONTEXT)
      .then(({ children, total }) => {
        if (!cancelled) {
          setRootChildren(children);
          setTotal(total);
          setLoading(false);
        }
      })
      .catch(() => {
        if (!cancelled) {
          setRootChildren([]);
          setLoading(false);
        }
      });
    return () => {
      cancelled = true;
    };
  }, [view]);

  const go = (hash: string) => {
    window.location.hash = hash;
  };

  const removeNode = (id: string) => {
    setRemovedIds((s) => new Set(s).add(id));
    setSelected(null);
  };

  const visibleRoot = (rootChildren || []).filter((c) => !removedIds.has(c.id));

  return (
    <div className="sessionsExplorer">
      <aside className="sessionsNav">
        <div className="sessionNavGroup">
          <div className="sessionNavHeader">
            <NotificationsActiveOutlinedIcon fontSize="small" />
            <span>{t("notifications")}</span>
          </div>
          {NAV.map((e) => (
            <div
              key={e.key}
              className={"sessionNavItem" + (view === e.view ? " active" : "")}
              onClick={() => go(e.hash)}
            >
              {e.icon}
              <span>{t(e.key)}</span>
            </div>
          ))}
        </div>
      </aside>

      {view === "new" ? (
        <section className="sessionsDetailPane">
          <NotifCreateForm onCreated={() => go("")} />
        </section>
      ) : (
        <>
          <section className="sessionsTree">
            <div className="sessionsTreeHeader">
              <strong>{t("notifications")}</strong>
              <Chip size="small" label={total} />
              {loading && <CircularProgress size={16} />}
            </div>
            <div className="sessionsTreeBody">
              {visibleRoot.map((node) => (
                <NotifTreeNode
                  key={node.id}
                  type={view as NotifType}
                  node={node}
                  depth={0}
                  selectedId={selected ? selected.id : null}
                  onSelect={setSelected}
                  removedIds={removedIds}
                />
              ))}
              {!loading && visibleRoot.length === 0 && (
                <div className="sessionsEmpty">{t("noData")}</div>
              )}
            </div>
          </section>

          <section className="sessionsDetailPane">
            {selected ? (
              <NotifDetail
                type={view as NotifType}
                node={selected}
                onDone={removeNode}
              />
            ) : (
              <div className="sessionsDetailPlaceholder">{t("clickToDisplay")}</div>
            )}
          </section>
        </>
      )}
    </div>
  );
}
