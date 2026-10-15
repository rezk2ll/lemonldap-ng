import TuneIcon from "@mui/icons-material/Tune";
import { Breadcrumbs, IconButton, Link } from "@mui/material";
import { t } from "i18next";
import { useEffect, useState } from "react";
import { push } from "redux-first-history";
import { useAppDispatch, useAppSelector } from "../app/hooks";
import { AdvancedAuthParams } from "../dashboards/AdvancedAuthParams";
import { ApplicationDashboard } from "../dashboards/ApplicationDashboard";
import { CatAndAppList } from "../dashboards/CatAndAppList";
import { HomePage } from "../dashboards/HomePage";
import { IssuerDashboard } from "../dashboards/IssuerDashboard";
import { SimpleAuthParams } from "../dashboards/SimpleAuthParams";
import TreeRender from "../dashboards/Tree";
import { getConfigAsync } from "../features/config/configSlice";
import { getTree } from "../utils/getTree";
import Manager from "./../dashboards/Manager";
import HomeButton from "../components/HomeButton";
import ConfigNav from "../components/ConfigNav";

export function Configuration({
  location,
}: {
  location: { type: string; info: { name: string; type?: string } };
}) {
  const metadata = useAppSelector((state) => state.config.data.metadata);
  const config = useAppSelector((state) => state.config.data.config);
  const dispatch = useAppDispatch();
  const [authSimple, setAuthSimple] = useState(true);
  const [tree, setTree] = useState(null);

  useEffect(() => {
    // Pages reached directly (reload, shared link) have no config loaded yet
    if (
      !metadata.cfgNum &&
      ["app", "issuer", "catandapp", "tree"].includes(location.type)
    ) {
      dispatch(getConfigAsync());
    }
  }, [metadata.cfgNum, dispatch, location.type]);

  // The parameter tree is static: fetch it once, not on every config change
  useEffect(() => {
    if (location.type === "tree" && !tree) {
      getTree()
        .then((response) => response.json())
        .then(setTree);
    }
  }, [location.type, tree]);

  const content = (() => {
    switch (location.type) {
    case "app":
      return (
        <div className="main">
          <Breadcrumbs className="breadcrumbs">
            <Link underline="hover" color="inherit">
              <span onClick={() => dispatch(push(``))}>{t("conf")}</span>
            </Link>
            <Link underline="hover" color="inherit">
              <span onClick={() => dispatch(push(`#conf/${metadata.cfgNum}`))}>
                {metadata.cfgNum}
              </span>
            </Link>
            <Link underline="none" color="inherit">
              {location.type}
            </Link>
            <Link underline="none" color="inherit">
              {location.info.type}
            </Link>
            <Link underline="hover" color="text.primary">
              {location.info.name}
            </Link>
          </Breadcrumbs>
          <ApplicationDashboard
            name={location.info.name}
            type={location.info.type ? location.info.type : ""}
          />
        </div>
      );
    case "conf":
      return (
        <div className="main">
          <Breadcrumbs className="breadcrumbs">
            <Link underline="hover" color="inherit">
              <span onClick={() => dispatch(push(``))}>{t("conf")}</span>
            </Link>
            <Link underline="hover" color="text.primary">
              <span onClick={() => dispatch(push(`#conf/${metadata.cfgNum}`))}>
                {metadata.cfgNum}
              </span>
            </Link>
          </Breadcrumbs>
          <Manager />
        </div>
      );
    case "authParams":
      return (
        <div className="main">
          <Breadcrumbs className="breadcrumbs">
            <Link underline="hover" color="inherit">
              <span onClick={() => dispatch(push(``))}>{t("conf")}</span>
            </Link>
            <Link underline="hover" color="inherit">
              <span onClick={() => dispatch(push(`#conf/${metadata.cfgNum}`))}>
                {metadata.cfgNum}
              </span>
            </Link>
            <Link underline="none" color="text.primary">
              {t(location.type)}
            </Link>
          </Breadcrumbs>
          <div className="top">
            <HomeButton />
            <strong className="title">{t("authParams")}</strong>
            <IconButton onClick={() => setAuthSimple(!authSimple)}>
              <TuneIcon />
            </IconButton>
          </div>
          {authSimple && <SimpleAuthParams />}
          {!authSimple && <AdvancedAuthParams />}
        </div>
      );
    case "issuer":
      return (
        <div className="main">
          <Breadcrumbs className="breadcrumbs">
            <Link underline="hover" color="inherit">
              <span onClick={() => dispatch(push(``))}>{t("conf")}</span>
            </Link>
            <Link underline="hover" color="inherit">
              <span onClick={() => dispatch(push(`#conf/${metadata.cfgNum}`))}>
                {metadata.cfgNum}
              </span>
            </Link>
            <Link underline="none" color="inherit">
              {location.type}
            </Link>
            <Link underline="none" color="text.primary">
              {location.info.name}
            </Link>
          </Breadcrumbs>
          <IssuerDashboard type={location.info.name} />
        </div>
      );
    case "tree":
      return (
        <div className="main">
          <Breadcrumbs className="breadcrumbs">
            <Link underline="hover" color="inherit">
              <span onClick={() => dispatch(push(``))}>{t("conf")}</span>
            </Link>
            <Link underline="hover" color="inherit">
              <span onClick={() => dispatch(push(`#conf/${metadata.cfgNum}`))}>
                {metadata.cfgNum}
              </span>
            </Link>
            <Link underline="none" color="color.primary">
              {t(location.type)}
            </Link>
          </Breadcrumbs>
          <TreeRender tree={tree ? tree : undefined} config={config} />
        </div>
      );
    case "catandapp":
      return (
        <div className="main">
          <Breadcrumbs className="breadcrumbs">
            <Link underline="hover" color="inherit">
              <span onClick={() => dispatch(push(``))}>{t("conf")}</span>
            </Link>
            <Link underline="hover" color="inherit">
              <span onClick={() => dispatch(push(`#conf/${metadata.cfgNum}`))}>
                {metadata.cfgNum}
              </span>
            </Link>
            <Link underline="none" color="color.primary">
              {t("applicationList")}
            </Link>
          </Breadcrumbs>
          <CatAndAppList />
        </div>
      );
    default:
      return (
        <div className="main">
          <Breadcrumbs className="breadcrumbs">
            <Link underline="hover" color="text.primary">
              <span onClick={() => dispatch(push(``))}>{t("conf")}</span>
            </Link>
          </Breadcrumbs>
          <HomePage />
        </div>
      );
    }
  })();
  return (
    <div className="configLayout">
      <ConfigNav />
      <div className="configMain">{content}</div>
    </div>
  );
}
