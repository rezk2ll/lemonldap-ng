import DeleteIcon from "@mui/icons-material/Delete";
import { Button } from "@mui/material";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { deleteDevice, getSfaSession } from "../../features/2fa/twofaAPI";
import { Device, localeDate, parseDevices } from "../../features/2fa/twofaDevices";
import { SfaNode } from "../../features/2fa/twofaTree";

export function TwofaDetail({ node }: { node: SfaNode }) {
  const { t } = useTranslation();
  const [devices, setDevices] = useState<Device[] | null>(null);
  const [busy, setBusy] = useState(false);
  const sessionId = node.session as string;

  useEffect(() => {
    let cancelled = false;
    setDevices(null);
    getSfaSession(sessionId).then((s) => {
      if (!cancelled) setDevices(parseDevices(s));
    });
    return () => {
      cancelled = true;
    };
  }, [sessionId]);

  const handleDelete = async (d: Device) => {
    setBusy(true);
    try {
      await deleteDevice(sessionId, d.type, d.epoch);
      setDevices((devs) =>
        (devs || []).filter((x) => !(x.type === d.type && x.epoch === d.epoch))
      );
    } finally {
      setBusy(false);
    }
  };

  if (!devices) {
    return <div className="sessionDetail">{t("waitingForDatas")}</div>;
  }

  return (
    <div className="sessionDetail">
      <div className="sessionGroupBox">
        <div className="sessionGroupHeader">{node.userId}</div>
        <table className="sessionAttrTable">
          <tbody>
            <tr>
              <th>{t("uid")}</th>
              <td>{node.userId}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <div className="sessionGroupBox">
        <div className="sessionGroupHeader">{t("sfaTitle")}</div>
        <table className="sessionAttrTable">
          <tbody>
            <tr className="attrHeader">
              <th>{t("type")}</th>
              <th>{t("name")}</th>
              <th>{t("date")}</th>
              <th />
            </tr>
            {devices.map((d, i) => (
              <tr key={i}>
                <td>{d.type}</td>
                <td>{d.name}</td>
                <td>{localeDate(d.epoch)}</td>
                <td>
                  <Button
                    size="small"
                    color="error"
                    startIcon={<DeleteIcon />}
                    disabled={busy}
                    onClick={() => handleDelete(d)}
                  >
                    {t("delete")}
                  </Button>
                </td>
              </tr>
            ))}
            {devices.length === 0 && (
              <tr>
                <td colSpan={4}>{t("noData")}</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
