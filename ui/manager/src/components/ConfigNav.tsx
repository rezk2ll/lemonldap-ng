import AccountTreeOutlinedIcon from "@mui/icons-material/AccountTreeOutlined";
import CategoryOutlinedIcon from "@mui/icons-material/CategoryOutlined";
import HomeOutlinedIcon from "@mui/icons-material/HomeOutlined";
import TuneOutlinedIcon from "@mui/icons-material/TuneOutlined";
import WidgetsOutlinedIcon from "@mui/icons-material/WidgetsOutlined";
import { ReactNode } from "react";
import { useTranslation } from "react-i18next";
import { push } from "redux-first-history";
import { useAppDispatch, useAppSelector } from "../app/hooks";
import SaveButton from "./SaveButton";
import "./ConfigNav.css";

// Left navigation for the configuration app: the "dashboards" (applications,
// categories, authentication parameters), the tree view (all parameters,
// including advanced ones the dashboards do not expose) and a way back to the
// home page. Mirrors the per-app left rail the sessions explorer already has.
const NAV_ITEMS: {
  key: string;
  hash: string;
  icon: ReactNode;
  // route "types" (first hash segment) that should light this entry up
  match: string[];
}[] = [
  {
    key: "home",
    hash: "",
    icon: <HomeOutlinedIcon fontSize="small" />,
    match: [""],
  },
  {
    key: "applications",
    hash: "#conf/latest",
    icon: <WidgetsOutlinedIcon fontSize="small" />,
    // drilling into an application or an issuer stays under "applications"
    match: ["conf", "app", "issuer"],
  },
  {
    key: "applicationList",
    hash: "#catandapp",
    icon: <CategoryOutlinedIcon fontSize="small" />,
    match: ["catandapp"],
  },
  {
    key: "authParams",
    hash: "#authParams/latest",
    icon: <TuneOutlinedIcon fontSize="small" />,
    match: ["authParams"],
  },
  {
    key: "advancedConfiguration",
    hash: "#tree/latest",
    icon: <AccountTreeOutlinedIcon fontSize="small" />,
    match: ["tree"],
  },
];

export default function ConfigNav() {
  const { t } = useTranslation();
  const dispatch = useAppDispatch();
  const type = useAppSelector(
    (state) => (state.router.location?.hash.replace("#", "").split("/")[0] || "")
  );

  return (
    <aside className="configNav">
      <nav className="configNavMenu">
        {NAV_ITEMS.map((item) => (
          <div
            key={item.key}
            className={"configNavItem" + (item.match.includes(type) ? " active" : "")}
            onClick={() => dispatch(push(item.hash))}
          >
            {item.icon}
            <span>{t(item.key)}</span>
          </div>
        ))}
      </nav>
      <div className="configNavSave">
        <SaveButton sidebar />
      </div>
    </aside>
  );
}
