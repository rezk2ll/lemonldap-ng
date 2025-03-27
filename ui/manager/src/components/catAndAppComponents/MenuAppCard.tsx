import ArrowDownwardOutlinedIcon from "@mui/icons-material/ArrowDownwardOutlined";
import ArrowUpwardOutlinedIcon from "@mui/icons-material/ArrowUpwardOutlined";
import RemoveOutlinedIcon from "@mui/icons-material/RemoveOutlined";
import {
  Accordion,
  AccordionDetails,
  AccordionSummary,
  Card,
  CardHeader,
  FormControl,
  FormControlLabel,
  FormLabel,
  IconButton,
  MenuItem,
  Radio,
  RadioGroup,
  Select,
  TextField,
} from "@mui/material";
import { t } from "i18next";
import { useEffect, useState } from "react";
import {
  changeApplicationField,
  delApplication,
  moveApp,
} from "../../features/config/configSlice";
import ExpandMoreIcon from "@mui/icons-material/ExpandMore";
import { idText } from "typescript";

const logoOptions = [
  "attach.png",
  "bell.png",
  "bookmark.png",
  "configure.png",
  "database.png",
  "demo.png",
  "docs.png",
  "folder.png",
  "gear.png",
  "help.png",
  "llng.png",
  "mailappt.png",
  "money.png",
  "network.png",
  "terminal.png",
  "thumbnail.png",
  "tools.png",
  "tux.png",
  "web.png",
  "wheels.png",
];

export function MenuAppCard({
  app,
  cardIndex,
  catId,
  appIndex,
  portal,
  appKey,
  applications,
  dispatch,
}: {
  app: Record<string, Record<string, string>>;
  catId: string;
  portal: string;
  appKey: string;
  applications: string[];
  cardIndex: number;
  appIndex: number;
  dispatch: Function;
}) {
  const [display, setDisplay] = useState<string>("auto");
  useEffect(() => {
    setDisplay(
      app.options.display === "on" ||
        app.options.display === "off" ||
        app.options.display === "auto"
        ? app.options.display
        : "specialRule"
    );
  }, [app.options]);
  return (
    <Card key={`cat${cardIndex}app${appIndex}`}>
      <CardHeader
        avatar={
          <FormControl>
            <Select
              value={
                (app.options as Record<string, string>).logo || "network.png"
              }
              onChange={(e) =>
                dispatch(
                  changeApplicationField({
                    catid: catId,
                    id: appKey,
                    field: "logo",
                    value: e.target.value,
                  })
                )
              }
            >
              {logoOptions.map((option) => (
                <MenuItem value={option} key={option}>
                  <img
                    src={`${portal}/static/common/apps/${option}`}
                    height="30px"
                    width="30px"
                    alt={option}
                  />
                </MenuItem>
              ))}
            </Select>
          </FormControl>
        }
        title={
          <>
            <TextField
              size="small"
              value={app.options.name}
              onChange={(e) =>
                dispatch(
                  changeApplicationField({
                    catid: catId,
                    id: appKey,
                    field: "name",
                    value: e.target.value,
                  })
                )
              }
            />
            <IconButton
              onClick={() =>
                dispatch(
                  moveApp({
                    category: catId,
                    appName: appKey,
                    direction: "up",
                  })
                )
              }
              disabled={appIndex === 0}
            >
              <ArrowUpwardOutlinedIcon />
            </IconButton>
            <IconButton
              onClick={() =>
                dispatch(
                  moveApp({
                    category: catId,
                    appName: appKey,
                    direction: "down",
                  })
                )
              }
              disabled={appIndex === applications.length - 1}
            >
              <ArrowDownwardOutlinedIcon />
            </IconButton>
            <IconButton
              onClick={() =>
                dispatch(delApplication({ catid: catId, id: appKey }))
              }
            >
              <RemoveOutlinedIcon />
            </IconButton>
          </>
        }
        subheader={
          <Accordion>
            <AccordionSummary expandIcon={<ExpandMoreIcon />}>
              <span>{t("details")}</span>
            </AccordionSummary>
            <AccordionDetails>
              <FormControl>
                <FormLabel>{t("description")}</FormLabel>
                <TextField
                  size="small"
                  rows={3}
                  multiline
                  fullWidth
                  value={app.options.description}
                  onChange={(e) =>
                    dispatch(
                      changeApplicationField({
                        catid: catId,
                        id: appKey,
                        field: "description",
                        value: e.target.value,
                      })
                    )
                  }
                />
              </FormControl>
              <FormControl>
                <FormLabel>{t("URI")}</FormLabel>
                <TextField
                  value={app.options.uri}
                  onChange={(e) =>
                    dispatch(
                      changeApplicationField({
                        catid: catId,
                        id: appKey,
                        field: "uri",
                        value: e.target.value,
                      })
                    )
                  }
                />
              </FormControl>
              <FormControl>
                <FormLabel>{t("applicationDisplay")}</FormLabel>
                <RadioGroup
                  row
                  value={display}
                  onChange={(e) => {
                    dispatch(
                      changeApplicationField({
                        catid: catId,
                        id: appKey,
                        field: "display",
                        value: e.target.value,
                      })
                    );
                    setDisplay(e.target.value);
                  }}
                >
                  <FormControlLabel
                    value={"on"}
                    control={<Radio />}
                    label={t("on")}
                  />
                  <FormControlLabel
                    value={"off"}
                    control={<Radio />}
                    label={t("off")}
                  />
                  <FormControlLabel
                    value={"auto"}
                    control={<Radio />}
                    label={t("auto")}
                  />
                  <FormControlLabel
                    value={"specialRule"}
                    control={<Radio />}
                    label={t("specialRule")}
                  />
                </RadioGroup>
                {display === "specialRule" && (
                  <TextField
                    size="small"
                    fullWidth
                    variant="filled"
                    onChange={(e) =>
                      dispatch(
                        changeApplicationField({
                          catid: catId,
                          id: appKey,
                          field: "display",
                          value: e.target.value,
                        })
                      )
                    }
                    value={app.options.display}
                  />
                )}
              </FormControl>
            </AccordionDetails>
          </Accordion>
        }
      />
    </Card>
  );
}
