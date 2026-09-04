import CheckCircleIcon from "@mui/icons-material/CheckCircle";
import DeleteForeverIcon from "@mui/icons-material/DeleteForever";
import { Button, Checkbox, FormControlLabel } from "@mui/material";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import {
  markAsDone,
  NotifType,
  NotifViewResponse,
  purgeNotification,
  viewNotification,
} from "../../features/notifications/notificationsAPI";
import { NotifNode, viewId } from "../../features/notifications/notifTree";

// Normalize the raw notification bodies (JSON strings or objects) into a
// display structure.
function parseBodies(arr?: any[]): Record<string, any>[] {
  if (!arr) return [];
  return arr.map((item) => {
    let obj: any = item;
    if (typeof item === "string") {
      try {
        obj = JSON.parse(item);
      } catch (e) {
        return { raw: item };
      }
    }
    return obj && typeof obj === "object" ? obj : { raw: String(item) };
  });
}

function renderCheck(check: any) {
  const items = Array.isArray(check) ? check : [check];
  return (
    <div>
      {items.map((c, i) => {
        const label =
          typeof c === "object" ? c.value || c.name || JSON.stringify(c) : c;
        return (
          <FormControlLabel
            key={i}
            control={<Checkbox size="small" disabled />}
            label={String(label)}
          />
        );
      })}
    </div>
  );
}

export function NotifDetail({
  type,
  node,
  onDone,
}: {
  type: NotifType;
  node: NotifNode;
  onDone: (nodeId: string) => void;
}) {
  const { t } = useTranslation();
  const [data, setData] = useState<NotifViewResponse | null>(null);
  const [busy, setBusy] = useState(false);
  const id = viewId(type, node);

  useEffect(() => {
    let cancelled = false;
    setData(null);
    viewNotification(type, id).then((d) => {
      if (!cancelled) setData(d);
    });
    return () => {
      cancelled = true;
    };
  }, [type, id]);

  const handleMarkDone = async () => {
    setBusy(true);
    try {
      await markAsDone(`${node.uid}_${node.reference}`);
      onDone(node.id);
    } finally {
      setBusy(false);
    }
  };

  const handlePurge = async () => {
    setBusy(true);
    try {
      await purgeNotification(`${node.uid}_${node.reference}_${data?.done}`);
      onDone(node.id);
    } finally {
      setBusy(false);
    }
  };

  if (!data) {
    return <div className="sessionDetail">{t("waitingForDatas")}</div>;
  }

  const bodies = parseBodies(data.notifications);

  const row = (label: string, value: any) =>
    value == null || value === "" ? null : (
      <tr key={label}>
        <th>{t(label, label)}</th>
        <td>{typeof value === "object" ? JSON.stringify(value) : String(value)}</td>
      </tr>
    );

  return (
    <div className="sessionDetail">
      <div className="sessionDetailToolbar">
        {type === "actives" ? (
          <Button
            variant="contained"
            color="primary"
            size="small"
            startIcon={<CheckCircleIcon />}
            disabled={busy}
            onClick={handleMarkDone}
          >
            {t("markAsDone")}
          </Button>
        ) : (
          <Button
            variant="contained"
            color="error"
            size="small"
            startIcon={<DeleteForeverIcon />}
            disabled={busy}
            onClick={handlePurge}
          >
            {t("deleteNotification")}
          </Button>
        )}
      </div>

      <div className="sessionGroupBox">
        <div className="sessionGroupHeader">{t("view")}</div>
        <table className="sessionAttrTable">
          <tbody>
            {row("uid", node.uid)}
            {row("reference", node.reference)}
            {row("date", node.date)}
            {row("condition", node.condition)}
            {type === "done" && row("internalReference", data.done)}
          </tbody>
        </table>
      </div>

      {bodies.map((body, i) => (
        <div className="sessionGroupBox" key={i}>
          <div className="sessionGroupHeader">
            {body.title || t("notification")}
          </div>
          <table className="sessionAttrTable">
            <tbody>
              {row("title", body.title)}
              {row("subtitle", body.subtitle)}
              {body.text != null && body.text !== "" && (
                <tr>
                  <th>{t("text")}</th>
                  <td>
                    <div style={{ whiteSpace: "pre-wrap" }}>
                      {String(body.text)}
                    </div>
                  </td>
                </tr>
              )}
              {body.check != null && (
                <tr>
                  <th>{t("checkboxes")}</th>
                  <td>{renderCheck(body.check)}</td>
                </tr>
              )}
              {body.raw != null && (
                <tr>
                  <th>{t("notification")}</th>
                  <td>
                    <pre style={{ whiteSpace: "pre-wrap", margin: 0 }}>
                      {String(body.raw)}
                    </pre>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      ))}
    </div>
  );
}
