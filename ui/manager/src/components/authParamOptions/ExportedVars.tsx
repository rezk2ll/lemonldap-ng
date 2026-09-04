import AddCircleIcon from "@mui/icons-material/AddCircle";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import { Accordion, AccordionSummary, IconButton } from "@mui/material";
import { t } from "i18next";
import { useAppDispatch, useAppSelector } from "../../app/hooks";
import {
  delModuleOpt,
  newModuleOpt,
  updateModuleOpt,
} from "../../features/config/configSlice";
import { llngConfig } from "../../utils/types";
import { TableVars } from "../applicationsComponents/TableVars";

// Manage a userDB "exported variables" hash (ldapExportedVars, dbiExportedVars,
// ...) as a collapsible section, consistent with the LDAP simple view's other
// accordions. Made reusable so the LDAP and AD+Kerberos simple views expose
// their exported variables the same way the Demo view already did.
export function ExportedVars({ param }: { param: keyof llngConfig }) {
  const dispatch = useAppDispatch();
  const vars = useAppSelector((state) => state.config.data.config[param]) as
    | Record<string, string>
    | undefined;
  const id = String(param);
  return (
    <Accordion>
      <AccordionSummary expandIcon={<ExpandMoreIcon />}>
        {t("exportedVars")}
      </AccordionSummary>
      <table id={id}>
        <thead>
          <tr>
            <th>{t("keys")}</th>
            <th>{t("values")}</th>
            <th>
              <IconButton
                className="plus"
                onClick={() => dispatch(newModuleOpt(param))}
              >
                <AddCircleIcon color="success" />
              </IconButton>
            </th>
          </tr>
        </thead>
        <TableVars
          appName={id}
          vars={vars || {}}
          tableID={id}
          dispatch={dispatch}
          delFunction={delModuleOpt}
          updateFunction={updateModuleOpt}
        />
      </table>
    </Accordion>
  );
}
