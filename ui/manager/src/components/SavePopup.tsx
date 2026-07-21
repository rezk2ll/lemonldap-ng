import { Button, Dialog, DialogContent, DialogTitle, Divider } from "@mui/material";
import { t } from "i18next";
import { ConfigState, getConfigAsync, getPartialConfigAsync } from "../features/config/configSlice";
import "./SaveButton.css";
import { push } from "redux-first-history";

export function SavePopup({
  config,
  openSavePopup,
  setOpenSavePopup,
  dispatch,
  partial,
}: {
  config: ConfigState;
  openSavePopup: boolean;
  setOpenSavePopup: Function;
  dispatch: Function;
  partial?: boolean;
}) {
  return (
    <Dialog open={openSavePopup}>
      <DialogTitle>{t("saveReport")}</DialogTitle>
      <Divider />
      <DialogContent>
        {config.saveResponse ? (
          <>
            {!config.saveResponse.details.__errors__ && <p>{t("successfullySaved")}</p>}
            {config.saveResponse.details.__warnings__ ? (
              <>
                <strong>{t("warnings")}</strong>
                <span>
                  {config.saveResponse.details.__warnings__?.map((el: Record<string, string>) => (
                    <ul key={el.message}>{el.message}</ul>
                  ))}
                </span>
              </>
            ) : (
              ""
            )}
            {config.saveResponse.details.__errors__ ? (
              <>
                <strong>{t("errors")}</strong>
                <span>
                  {config.saveResponse.details.__errors__?.map((el: Record<string, string>) => (
                    <ul key={el.message}>{el.message}</ul>
                  ))}
                </span>
              </>
            ) : (
              ""
            )}
          </>
        ) : (
          ""
        )}
      </DialogContent>
      <Divider />

      <Button
        onClick={() => {
          if (!config.saveResponse?.details.__errors__) {
            dispatch(partial ? getPartialConfigAsync() : getConfigAsync());
            // Back to the home page (configuration overview), not the
            // applications dashboard. Partial config has no home page.
            dispatch(push(partial ? "#conf/latest" : ""));
          }
          setOpenSavePopup(false);
        }}
      >
        {t("close")}
      </Button>
    </Dialog>
  );
}
