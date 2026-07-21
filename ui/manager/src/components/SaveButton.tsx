import SaveIcon from "@mui/icons-material/Save";
import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  Divider,
  Fab,
  TextField,
} from "@mui/material";
import { t } from "i18next";
import { useState } from "react";
import { useAppDispatch, useAppSelector } from "../app/hooks";
import {
  saveConfigAsync,
  savePartialConfigAsync,
} from "../features/config/configSlice";
import { ruleOIDC, ruleSAML } from "../utils/rules";
import "./SaveButton.css";
import { SavePopup } from "./SavePopup";
export default function SaveButton({
  partial,
  sidebar,
}: {
  partial?: boolean;
  sidebar?: boolean;
}) {
  const [openSavePopup, setOpenSavePopup] = useState(false);
  const [openErrorPopup, setOpenErrorPopup] = useState(false);
  const [openConfirm, setOpenConfirm] = useState(false);
  const [logMessage, setLogMessage] = useState("");
  const dispatch = useAppDispatch();
  const config = useAppSelector((state) => state.config);
  const data = useAppSelector((state) => state.config.data.config);

  // Rule validation first; a valid config opens the confirmation dialog that
  // asks for a summary (cfgLog), like the legacy manager, before saving.
  const attemptSave = function () {
    let stateOk = true;
    if (data.oidcRPMetaDataOptions) {
      Object.keys(data.oidcRPMetaDataOptions).forEach((app) => {
        if (
          !ruleOIDC(
            data.oidcRPMetaDataOptions ? data.oidcRPMetaDataOptions[app] : {}
          )
        ) {
          stateOk = false;
        }
      });
    }
    if (data.samlSPMetaDataXML) {
      Object.keys(data.samlSPMetaDataXML).forEach((app) => {
        if (
          !ruleSAML(data.samlSPMetaDataXML ? data.samlSPMetaDataXML[app] : {})
        ) {
          stateOk = false;
        }
      });
    }
    if (stateOk) {
      setLogMessage("");
      setOpenConfirm(true);
    } else {
      setOpenErrorPopup(true);
      setTimeout(() => {
        setOpenErrorPopup(false);
      }, 2000);
    }
  };

  const confirmSave = function () {
    const payload = { ...config.data.config, cfgLog: logMessage };
    dispatch(
      partial ? savePartialConfigAsync(payload) : saveConfigAsync(payload)
    );
    setOpenConfirm(false);
    setOpenSavePopup(true);
  };

  return (
    <div>
      {sidebar ? (
        <Button
          className="saveButtonSidebar"
          variant="contained"
          color="primary"
          fullWidth
          startIcon={<SaveIcon />}
          onClick={attemptSave}
        >
          {t("save")}
        </Button>
      ) : (
        <Fab className="saveButton" color="primary" onClick={attemptSave}>
          <SaveIcon fontSize="large" />
        </Fab>
      )}
      <Dialog
        open={openConfirm}
        onClose={() => setOpenConfirm(false)}
        fullWidth
        maxWidth="sm"
      >
        <DialogTitle>{t("savingConfirmation")}</DialogTitle>
        <Divider />
        <DialogContent>
          <TextField
            autoFocus
            fullWidth
            multiline
            minRows={3}
            label={t("cfgLog")}
            value={logMessage}
            onChange={(e) => setLogMessage(e.target.value)}
          />
        </DialogContent>
        <Divider />
        <DialogActions>
          <Button variant="contained" color="primary" onClick={confirmSave}>
            {t("ok")}
          </Button>
          <Button color="secondary" onClick={() => setOpenConfirm(false)}>
            {t("cancel")}
          </Button>
        </DialogActions>
      </Dialog>
      <SavePopup
        config={config}
        dispatch={dispatch}
        openSavePopup={openSavePopup}
        setOpenSavePopup={setOpenSavePopup}
        partial={partial}
      />
      <div className={`notif red ${openErrorPopup ? "visible" : "hidden"}`}>
        {t("saveWithWarnings")}
      </div>
    </div>
  );
}
