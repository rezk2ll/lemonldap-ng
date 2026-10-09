import CloudUploadIcon from "@mui/icons-material/CloudUpload";
import FormatIndentIncreaseIcon from "@mui/icons-material/FormatIndentIncrease";
import { Button, TextField } from "@mui/material";
import { t } from "i18next";
import { ChangeEvent } from "react";
import { URLLoader } from "../components/managerComponents/URLLoader";
import { VisuallyHiddenInput } from "../components/managerComponents/VisuallyHiddenInput";
import { attributes } from "../metadata";
import { indentDocument } from "../utils/indentDocument";
import { handleChangeFile } from "../utils/readFiles";
export default function FileForm({
  value,
  fieldName,
  updateFunc,
}: {
  value: string;
  fieldName: string;
  updateFunc: Function;
}) {
  const attribute = attributes[fieldName as keyof typeof attributes];
  // Explicit action: indenting changes the stored text (and would break a
  // signed metadata document)
  const indented = value ? indentDocument(value) : null;
  return (
    <>
      <th className="title2">{t(fieldName)}</th>
      <td>
        <div>
          <TextField
            size="small"
            margin="normal"
            multiline
            fullWidth
            rows={12}
            // XML/JSON/PEM documents: keep their layout, like <pre>
            inputProps={{ "aria-label": t(fieldName), wrap: "off" }}
            sx={{
              "& textarea": {
                fontFamily: "monospace",
                whiteSpace: "pre",
                overflowX: "auto",
              },
            }}
            placeholder={t(fieldName)}
            onChange={(e) => updateFunc(e.target.value)}
            value={value || ""}
          />
        </div>
        <div>
          <Button
            sx={{ margin: "5px" }}
            component="label"
            role={undefined}
            variant="contained"
            tabIndex={-1}
            startIcon={<CloudUploadIcon />}
          >
            {t("upload")}
            <VisuallyHiddenInput
              type="file"
              onChange={(e) => {
                if (e.target instanceof HTMLInputElement) {
                  handleChangeFile(e as ChangeEvent<HTMLInputElement>).then(
                    (fileContent) => {
                      console.debug("File content:", fileContent);
                      updateFunc(fileContent);
                    }
                  );
                }
              }}
            />
          </Button>
          <Button
            sx={{ margin: "5px" }}
            variant="outlined"
            startIcon={<FormatIndentIncreaseIcon />}
            disabled={indented === null || indented === value}
            onClick={() => updateFunc(indented)}
          >
            {t("indent")}
          </Button>
        </div>
        <URLLoader appName={fieldName} loadFunction={updateFunc} />
      </td>
    </>
  );
}
