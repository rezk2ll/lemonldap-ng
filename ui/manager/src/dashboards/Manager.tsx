import ArrowBackIcon from "@mui/icons-material/ArrowBack";
import ArrowForwardIcon from "@mui/icons-material/ArrowForward";
import CachedIcon from "@mui/icons-material/Cached";
import { Button, Divider, Menu, MenuItem, Pagination } from "@mui/material";
import { ChangeEvent, useEffect, useMemo, useState } from "react";
import { useTranslation } from "react-i18next";
import { useLocation } from "react-router-dom";
import { push } from "redux-first-history";
import { useAppDispatch, useAppSelector } from "../app/hooks";
import AddApp from "../components/managerComponents/AddApp";
import AppCard from "../components/managerComponents/AppCard";
import FilterToggle from "../components/managerComponents/Filters";
import Issuers from "../components/managerComponents/Issuers";
import {
  getConfigAsync,
  removeError,
  setError,
} from "../features/config/configSlice";
import { ruleCAS, ruleOIDC, ruleSAML } from "../utils/rules";
import "./Manager.css";
import HomeButton from "../components/HomeButton";

export default function Manager() {
  const dispatch = useAppDispatch();
  const { t } = useTranslation();
  const config = useAppSelector((state) => state.config);
  const configNum = useAppSelector((state) =>
    state.router.location?.hash.replace("#conf/", "")
  );
  const [filters, setFilters] = useState({ alpha: false, search: "" });
  const location = useLocation();
  const [page, setPage] = useState(1);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const handleClick = (event: React.MouseEvent<HTMLButtonElement>) => {
    setAnchorEl(event.currentTarget);
  };
  const [configPresent, setConfigPresent] = useState<boolean>(
    Boolean(config.data.metadata && !config.loading && !config.error.has)
  );

  useEffect(() => {
    if (!configPresent) {
      setConfigPresent(true);
      dispatch(
        getConfigAsync(configNum === "latest" ? undefined : Number(configNum))
      );
    } else {
      if (
        configNum !== "latest" &&
        Number(configNum) !== Number(config.data.metadata.cfgNum)
      ) {
        dispatch(
          getConfigAsync(configNum === "latest" ? undefined : Number(configNum))
        );
      } else if (configNum === "latest" && config.data.metadata.next) {
        dispatch(getConfigAsync());
      }
    }
  }, [dispatch, configNum, config.data.metadata, location, configPresent]);

  // Derive the application list from the config as plain data (memoized), so a
  // large configuration is walked once per config/filter change instead of on
  // every render, and only the visible page is turned into <AppCard> elements
  // below (the rule* validators then run for those cards only).
  type AppItem = {
    key: string;
    type: string;
    config: Record<string, boolean | number | string>;
    issuer?: boolean | number;
  };
  const items = useMemo<AppItem[]>(() => {
    const cfg = config.data.config;
    const list: AppItem[] = [];
    const add = (
      src: Record<string, unknown> | undefined,
      type: string,
      cfgFor: (key: string) => Record<string, boolean | number | string>,
      issuer?: boolean | number
    ) => {
      if (!src) return;
      for (const key of Object.keys(src)) {
        list.push({ key, type, config: cfgFor(key), issuer });
      }
    };
    add(
      cfg.locationRules,
      "native",
      (key) => (cfg.vhostOptions ? cfg.vhostOptions[key] : {}) || {}
    );
    add(
      cfg.samlSPMetaDataXML,
      "SPsaml",
      (key) => (cfg.samlSPMetaDataXML ? cfg.samlSPMetaDataXML[key] : {}) || {},
      cfg.issuerDBSAMLActivation
    );
    add(
      cfg.oidcRPMetaDataOptions,
      "RPoidc",
      (key) =>
        (cfg.oidcRPMetaDataOptions ? cfg.oidcRPMetaDataOptions[key] : {}) || {},
      cfg.issuerDBOpenIDConnectActivation
    );
    add(
      cfg.casAppMetaDataOptions,
      "AppCas",
      (key) =>
        (cfg.casAppMetaDataOptions ? cfg.casAppMetaDataOptions[key] : {}) || {},
      cfg.issuerDBCASActivation
    );
    return list;
  }, [config.data.config]);

  const visibleApps = useMemo<AppItem[]>(() => {
    let r = items.filter((it) => it.key.includes(filters.search));
    if (filters.alpha) {
      r = [...r].sort((a, b) => (a.key > b.key ? 1 : -1));
    }
    return r;
  }, [items, filters.search, filters.alpha]);

  const ruleFor = (it: AppItem): boolean =>
    it.type === "SPsaml"
      ? ruleSAML(it.config as Record<string, string>)
      : it.type === "RPoidc"
        ? ruleOIDC(it.config)
        : it.type === "AppCas"
          ? ruleCAS(it.config)
          : true;

  try {
    if (config.loading) {
      return (
        <div>
          <strong className="title"> {t("currentConfiguration")} </strong>
          {t("loading")}
        </div>
      );
    } else if (config.error.has) {
      return (
        <div>
          <strong className="title"> {t("currentConfiguration")} </strong>
          <strong>{t("failedLoading")}</strong>
          <span>{config.error.errorContent}</span>
        </div>
      );
    } else {
      const pageLimit = 6;
      const pageNb = Math.ceil(visibleApps.length / pageLimit);
      const pageItems = visibleApps.slice(
        (page - 1) * pageLimit,
        page * pageLimit
      );
      const handleChangePage = (event: ChangeEvent<unknown>, value: number) => {
        setPage(value);
      };

      return (
        <>
          <div className="top">
            <div className="topIdentity">
              <strong className="title"> {t("currentConfiguration")}</strong>
              <Button
                variant="contained"
                disableElevation
                size="small"
                className="cfgNum"
                color={config.data.metadata.next ? "warning" : "success"}
                onClick={(e) => {
                  handleClick(e);
                }}
              >
                {config.data.metadata.cfgNum}
              </Button>
            </div>
            <Divider orientation="vertical" flexItem className="topDivider" />
            <AddApp />
          </div>
          <Issuers />
          <FilterToggle filters={filters} setFilters={setFilters} />
          <div className="grid">
            {pageItems.map((it) => (
              <AppCard
                key={it.key}
                type={it.type}
                info={{ name: it.key, config: it.config }}
                issuer={it.issuer}
                rule={ruleFor(it)}
              />
            ))}
          </div>
          <Pagination
            sx={{
              justifyContent: "center",
              display: "flex",
              margin: "15px",
            }}
            count={pageNb}
            page={page}
            onChange={handleChangePage}
            showFirstButton
            showLastButton
          />
          <Menu
            id="del-menu"
            anchorEl={anchorEl}
            open={anchorEl ? true : false}
            onClose={() => {
              setAnchorEl(null);
            }}
          >
            <MenuItem
              onClick={() => {
                dispatch(push(`#conf/${config.data.metadata.prev}`));
                setAnchorEl(null);
              }}
            >
              <ArrowBackIcon sx={{ marginRight: "15px" }} />
              {t("previous")}
            </MenuItem>
            <Divider />
            <MenuItem
              disabled={!config.data.metadata.next}
              onClick={() => {
                dispatch(push(`#conf/${config.data.metadata.next}`));
                setAnchorEl(null);
              }}
            >
              <ArrowForwardIcon sx={{ marginRight: "15px" }} />
              {t("next")}
            </MenuItem>
            <Divider />
            <MenuItem
              onClick={() => {
                dispatch(push(`#conf/latest`));
                setAnchorEl(null);
              }}
            >
              <CachedIcon sx={{ marginRight: "15px" }} />
              {t("latest")}
            </MenuItem>
          </Menu>
        </>
      );
    }
  } catch (e) {
    console.debug(e);
    if (e instanceof Error) {
      dispatch(setError(`${e.name} : ${e.message}`));
      dispatch(removeError());
    }
    return <div className="main">{config.error.errorContent}</div>;
  }
}
