import GroupOutlinedIcon from "@mui/icons-material/GroupOutlined";
import HourglassEmptyIcon from "@mui/icons-material/HourglassEmpty";
import LockOutlinedIcon from "@mui/icons-material/LockOutlined";
import PersonOutlineIcon from "@mui/icons-material/PersonOutline";
import PublicIcon from "@mui/icons-material/Public";
import ReportProblemOutlinedIcon from "@mui/icons-material/ReportProblemOutlined";
import ScheduleIcon from "@mui/icons-material/Schedule";
import UpdateIcon from "@mui/icons-material/Update";
import { Chip, CircularProgress } from "@mui/material";
import { ReactNode, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { SessionDetail } from "../components/sessionsComponents/SessionDetail";
import { SessionTreeNode } from "../components/sessionsComponents/SessionTreeNode";
import { loadChildren, ROOT_CONTEXT, TreeNode } from "../features/sessions/tree";
import "./SessionsExplorer.css";

function hashView(hash: string): { type: string; sessionType: string } {
  const m = hash.match(/#?!?\/(\w+)/);
  if (!m) return { type: "_whatToTrace", sessionType: "global" };
  if (m[1] === "persistent" || m[1] === "offline") {
    return { type: "_session_uid", sessionType: m[1] };
  }
  return { type: m[1], sessionType: "global" };
}

// Left-navigation entries (mirror the legacy sessions.tpl dropdown + links).
const SSO_SUBVIEWS: { key: string; hash: string; icon: ReactNode }[] = [
  { key: "users", hash: "", icon: <PersonOutlineIcon fontSize="small" /> },
  { key: "ipAddresses", hash: "!/ipAddr", icon: <PublicIcon fontSize="small" /> },
  { key: "multiIp", hash: "!/doubleIp", icon: <ReportProblemOutlinedIcon fontSize="small" /> },
  { key: "_startTime", hash: "!/_startTime", icon: <ScheduleIcon fontSize="small" /> },
  { key: "_updateTime", hash: "!/_updateTime", icon: <UpdateIcon fontSize="small" /> },
];
const TOP_VIEWS: { key: string; hash: string; icon: ReactNode }[] = [
  { key: "persistentSessions", hash: "!/persistent", icon: <LockOutlinedIcon fontSize="small" /> },
  { key: "offlineSessions", hash: "!/offline", icon: <HourglassEmptyIcon fontSize="small" /> },
];

export function SessionsExplorer() {
  const { t } = useTranslation();
  const [view, setView] = useState(() => hashView(window.location.hash));
  const [rootChildren, setRootChildren] = useState<TreeNode[] | null>(null);
  const [total, setTotal] = useState(0);
  const [selected, setSelected] = useState<TreeNode | null>(null);
  const [removedIds, setRemovedIds] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const onHash = () => setView(hashView(window.location.hash));
    window.addEventListener("hashchange", onHash);
    return () => window.removeEventListener("hashchange", onHash);
  }, []);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    setRootChildren(null);
    setSelected(null);
    setRemovedIds(new Set());
    loadChildren(view.type, view.sessionType, ROOT_CONTEXT)
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
  }, [view.type, view.sessionType]);

  const go = (hash: string) => {
    window.location.hash = hash;
  };

  const isActive = (hash: string) => {
    const v = hashView(hash);
    return v.type === view.type && v.sessionType === view.sessionType;
  };

  const removeNode = (id: string) => {
    setRemovedIds((s) => new Set(s).add(id));
    setSelected(null);
  };

  const visibleRoot = (rootChildren || []).filter((c) => !removedIds.has(c.id));

  const navItem = (
    entry: { key: string; hash: string; icon: ReactNode },
    sub: boolean
  ) => (
    <div
      key={entry.key}
      className={
        "sessionNavItem" +
        (sub ? " sub" : "") +
        (isActive(entry.hash) ? " active" : "")
      }
      onClick={() => go(entry.hash)}
    >
      {entry.icon}
      <span>{t(entry.key)}</span>
    </div>
  );

  return (
    <div className="sessionsExplorer">
      <aside className="sessionsNav">
        <div className="sessionNavGroup">
          <div className="sessionNavHeader">
            <GroupOutlinedIcon fontSize="small" />
            <span>{t("ssoSessions")}</span>
          </div>
          {SSO_SUBVIEWS.map((e) => navItem(e, true))}
        </div>
        {TOP_VIEWS.map((e) => navItem(e, false))}
      </aside>

      <section className="sessionsTree">
        <div className="sessionsTreeHeader">
          <strong>{t("sessions")}</strong>
          <Chip size="small" label={total} />
          {loading && <CircularProgress size={16} />}
        </div>
        <div className="sessionsTreeBody">
          {visibleRoot.map((node) => (
            <SessionTreeNode
              key={node.id}
              type={view.type}
              sessionType={view.sessionType}
              node={node}
              depth={0}
              selectedId={selected ? selected.id : null}
              onSelect={setSelected}
              removedIds={removedIds}
            />
          ))}
          {!loading && visibleRoot.length === 0 && (
            <div className="sessionsEmpty">{t("noSession") || "—"}</div>
          )}
        </div>
      </section>

      <section className="sessionsDetailPane">
        {selected ? (
          <SessionDetail
            sessionType={view.sessionType}
            node={selected}
            onDeleted={removeNode}
          />
        ) : (
          <div className="sessionsDetailPlaceholder">{t("clickToDisplay")}</div>
        )}
      </section>
    </div>
  );
}
