import AddCircleIcon from "@mui/icons-material/AddCircle";
import RemoveCircleIcon from "@mui/icons-material/RemoveCircle";
import { IconButton, TextField, Tooltip } from "@mui/material";
import { t } from "i18next";
import Markdown from "markdown-to-jsx";
import { definitions } from "../metadata";

export default function KeyTextContainerForm({
  value,
  fieldName,
  updateFunc,
}: {
  value: Record<string, string>;
  fieldName: string;
  updateFunc: Function;
}) {
  return (
    <>
      <th className="title2">{t(fieldName)}</th>
      <td>
        <table id={fieldName}>
          <thead>
            <tr>
              <th>{t("keys")}</th>
              <Tooltip
                title={
                  <Markdown>
                    {definitions[fieldName as keyof typeof definitions] + ""}
                  </Markdown>
                }
              >
                <th>{t("values")}</th>
              </Tooltip>
              <th>
                <IconButton
                  className="plus"
                  onClick={() =>
                    updateFunc(addHeader(fieldName, fieldName))
                  }
                >
                  <AddCircleIcon color="success" />
                </IconButton>
              </th>
            </tr>
          </thead>
          <tbody>
            {Object.keys(value).map((key, index) => {
              const i = index + 1;
              return (
                <tr key={fieldName + i}>
                  <td>
                    <TextField
                      size="small"
                      margin="normal"
                      variant="filled"
                      className="form"
                      onChange={() =>
                        updateFunc(updateHeaders(fieldName))
                      }
                      type="text"
                      value={key}
                    />
                  </td>
                  <td>
                    <TextField
                      size="small"
                      margin="normal"
                      variant="filled"
                      className="form"
                      onChange={() =>
                        updateFunc(updateHeaders(fieldName))
                      }
                      type="text"
                      value={value[key]}
                    />
                  </td>

                  <td>
                    <IconButton
                      className="minus"
                      onClick={() =>
                        updateFunc(removeHeader(fieldName, i))
                      }
                    >
                      <RemoveCircleIcon color="error" />
                    </IconButton>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
        <IconButton
          className="plus"
          onClick={() => updateFunc(addHeader(fieldName, fieldName))}
        >
          <AddCircleIcon color="success" />
        </IconButton>
      </td>
    </>
  );
}

export function updateHeaders(tableID: string) {
  const headerList: Record<string, string> = {};

  const table = document.getElementById(tableID);
  const rows = table?.getElementsByTagName("tr");
  if (rows) {
    for (let i = 1; i < rows.length; i++) {
      const cells = rows[i].getElementsByTagName("td");
      const key = cells[0].querySelector("input")?.value;
      const values = cells[1].querySelector("input")?.value;
      if (key) {
        headerList[key] = values ? values : "";
      }
    }
  }
  return headerList;
}

function addHeader(tableID: string, fieldName: string) {
  const headerList: Record<string, string> = {};
  const table = document.getElementById(tableID);
  const rows = table?.getElementsByTagName("tr");
  if (rows) {
    for (let i = 1; i < rows.length; i++) {
      const cells = rows[i].getElementsByTagName("td");
      const key = cells[0].querySelector("input")?.value;
      const values = cells[1].querySelector("input")?.value;
      if (key) {
        headerList[key] = values ? values : "";
      }
    }
  }
  headerList["new"] = "";
  return headerList;
}
function removeHeader(tableID: string, id: number) {
  const headerList: Record<string, string> = {};
  const table = document.getElementById(tableID);
  const rows = table?.getElementsByTagName("tr");
  if (rows) {
    for (let i = 1; i < rows.length; i++) {
      if (i !== id) {
        const cells = rows[i].getElementsByTagName("td");
        const key = cells[0].querySelector("input")?.value;
        const values = cells[1].querySelector("input")?.value;
        if (key) {
          headerList[key] = values ? values : "";
        }
      }
    }
  }
  return headerList;
}
