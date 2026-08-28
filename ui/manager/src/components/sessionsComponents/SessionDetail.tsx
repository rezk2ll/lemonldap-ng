import DeleteIcon from "@mui/icons-material/Delete";
import LogoutIcon from "@mui/icons-material/Logout";
import { Button } from "@mui/material";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import {
  DetailGroup,
  DetailRow,
  localeDate,
  SessionDetail as SessionDetailData,
  transformSession,
} from "../../features/sessions/sessionDisplay";
import {
  deleteOIDCConsent,
  deleteSession,
  getSession,
  globalLogout,
} from "../../features/sessions/sessionsAPI";
import { TreeNode } from "../../features/sessions/tree";

function renderValue(value: any) {
  if (Array.isArray(value)) return value.join(", ");
  if (value && typeof value === "object") return JSON.stringify(value);
  return String(value);
}

export function SessionDetail({
  sessionType,
  node,
  onDeleted,
}: {
  sessionType: string;
  node: TreeNode;
  onDeleted: (nodeId: string) => void;
}) {
  const { t } = useTranslation();
  const [detail, setDetail] = useState<SessionDetailData | null>(null);
  const [busy, setBusy] = useState(false);
  const sessionId = node.session as string;

  useEffect(() => {
    let cancelled = false;
    setDetail(null);
    getSession(sessionType, sessionId).then((raw) => {
      if (!cancelled) setDetail(transformSession(raw));
    });
    return () => {
      cancelled = true;
    };
  }, [sessionType, sessionId]);

  const handleDelete = async () => {
    setBusy(true);
    try {
      await deleteSession(sessionType, sessionId);
      onDeleted(node.id);
    } finally {
      setBusy(false);
    }
  };

  const handleGlobalLogout = async () => {
    setBusy(true);
    try {
      await globalLogout(sessionType, sessionId);
      onDeleted(node.id);
    } finally {
      setBusy(false);
    }
  };

  const handleConsentDelete = async (rp: string, epoch: string | number) => {
    await deleteOIDCConsent(sessionType, sessionId, rp, epoch);
    // Reload the session to reflect the removed consent.
    const raw = await getSession(sessionType, sessionId);
    setDetail(transformSession(raw));
  };

  if (!detail) {
    return <div className="sessionDetail">{t("waitingForDatas")}</div>;
  }

  const renderRow = (group: DetailGroup, row: DetailRow, index: number) => {
    // Header row of a 2FA-devices / OIDC-consents table.
    if (row.td === "0") {
      return (
        <tr key={index} className="attrHeader">
          <th>{row.title}</th>
          <th>{row.value}</th>
          <th>{row.epoch}</th>
          <th />
        </tr>
      );
    }
    // 2FA device.
    if (row.td === "1") {
      return (
        <tr key={index}>
          <td>{t(row.title, row.title)}</td>
          <td>{renderValue(row.value)}</td>
          <td>{localeDate(row.epoch)}</td>
          <td />
        </tr>
      );
    }
    // OIDC consent (deletable).
    if (row.td === "2") {
      return (
        <tr key={index}>
          <td>{row.title}</td>
          <td>{renderValue(row.value)}</td>
          <td>{localeDate(row.epoch)}</td>
          <td>
            <Button
              size="small"
              color="error"
              onClick={() => handleConsentDelete(row.title, row.epoch ?? "")}
            >
              {t("delete")}
            </Button>
          </td>
        </tr>
      );
    }
    // Regular attribute / login-history row.
    return (
      <tr key={index}>
        <th>{t(row.title, row.title)}</th>
        <td colSpan={3}>{renderValue(row.value)}</td>
      </tr>
    );
  };

  return (
    <div className="sessionDetail">
      <div className="sessionDetailToolbar">
        <Button
          variant="contained"
          color="error"
          size="small"
          startIcon={<DeleteIcon />}
          disabled={busy}
          onClick={handleDelete}
        >
          {t("deleteSession")}
        </Button>
        <Button
          variant="outlined"
          color="error"
          size="small"
          startIcon={<LogoutIcon />}
          disabled={busy}
          onClick={handleGlobalLogout}
        >
          {t("globalLogout")}
        </Button>
      </div>
      {detail.nodes.map((group) => (
        <div className="sessionGroupBox" key={group.title}>
          <div className="sessionGroupHeader">{t(group.title, group.title)}</div>
          <table className="sessionAttrTable">
            <tbody>
              {group.nodes.map((row, i) => renderRow(group, row, i))}
            </tbody>
          </table>
        </div>
      ))}
    </div>
  );
}
