import SaveIcon from "@mui/icons-material/Save";
import { Alert, Button, TextField } from "@mui/material";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { createNotification } from "../../features/notifications/notificationsAPI";

const JSON_TEMPLATE = `{
  "title": "My notification",
  "subtitle": "Subtitle",
  "text": "Notification text displayed to the user.",
  "check": ["I have read this message"]
}`;

export function NotifCreateForm({ onCreated }: { onCreated: () => void }) {
  const { t } = useTranslation();
  const [uid, setUid] = useState("");
  const [reference, setReference] = useState("");
  const [date, setDate] = useState("");
  const [condition, setCondition] = useState("");
  const [content, setContent] = useState(JSON_TEMPLATE);
  const [busy, setBusy] = useState(false);
  const [feedback, setFeedback] = useState<{
    severity: "success" | "error";
    message: string;
  } | null>(null);

  const submit = async () => {
    setFeedback(null);
    if (!uid || !reference || !content) {
      setFeedback({ severity: "error", message: t("incompleteForm") });
      return;
    }
    setBusy(true);
    try {
      const res = await createNotification({
        uid,
        reference,
        condition: condition || undefined,
        date: date || undefined,
        xml: content,
      });
      if (res.result === 1) {
        setFeedback({ severity: "success", message: t("notificationCreated") });
        setReference("");
        onCreated();
      } else {
        setFeedback({
          severity: "error",
          message: `${t("notificationNotCreated")}${
            res.error ? " : " + res.error : ""
          }`,
        });
      }
    } catch (e) {
      setFeedback({
        severity: "error",
        message: `${t("notificationNotCreated")} : ${String(e)}`,
      });
    } finally {
      setBusy(false);
    }
  };

  return (
    <div className="sessionDetail">
      <div className="sessionGroupBox">
        <div className="sessionGroupHeader">{t("create")}</div>
        <div className="notifForm">
          {feedback && (
            <Alert severity={feedback.severity} sx={{ mb: 2 }}>
              {feedback.message}
            </Alert>
          )}
          <TextField
            label={t("uid")}
            size="small"
            required
            fullWidth
            margin="dense"
            value={uid}
            onChange={(e) => setUid(e.target.value)}
          />
          <TextField
            label={t("reference")}
            size="small"
            required
            fullWidth
            margin="dense"
            value={reference}
            onChange={(e) => setReference(e.target.value)}
          />
          <TextField
            label={t("date")}
            type="date"
            size="small"
            fullWidth
            margin="dense"
            InputLabelProps={{ shrink: true }}
            value={date}
            onChange={(e) => setDate(e.target.value)}
          />
          <TextField
            label={t("condition")}
            size="small"
            fullWidth
            margin="dense"
            value={condition}
            onChange={(e) => setCondition(e.target.value)}
          />
          <TextField
            label={t("content")}
            multiline
            minRows={8}
            fullWidth
            margin="dense"
            value={content}
            onChange={(e) => setContent(e.target.value)}
            InputProps={{ sx: { fontFamily: "monospace", fontSize: "0.85rem" } }}
          />
          <Alert severity="info" sx={{ mt: 1 }}>
            {t("allowedMarkups")} <code>title</code>, <code>subtitle</code>,{" "}
            <code>text</code>, <code>check[]</code>.
          </Alert>
          <div style={{ marginTop: 16 }}>
            <Button
              variant="contained"
              startIcon={<SaveIcon />}
              disabled={busy}
              onClick={submit}
            >
              {t("save")}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
