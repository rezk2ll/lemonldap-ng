import ArrowForwardIcon from "@mui/icons-material/ArrowForward";
import GroupOutlinedIcon from "@mui/icons-material/GroupOutlined";
import NotificationsNoneOutlinedIcon from "@mui/icons-material/NotificationsNoneOutlined";
import SecurityOutlinedIcon from "@mui/icons-material/SecurityOutlined";
import SettingsOutlinedIcon from "@mui/icons-material/SettingsOutlined";
import { Card, CardActionArea, Skeleton } from "@mui/material";
import { ReactNode, useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { listNotifications } from "../features/notifications/notificationsAPI";
import { listSessions } from "../features/sessions/sessionsAPI";
import { listSfa } from "../features/2fa/twofaAPI";
import { isModuleEnabled } from "../utils/modules";
import "./ManagerHome.css";

type ConfMetadata = {
  cfgNum: number;
  cfgDate?: number;
  cfgAuthor?: string;
  cfgLog?: string;
};

const base = (): string => (window as any).scriptname || "/";

async function latestConf(): Promise<ConfMetadata> {
  const res = await fetch(`${base()}confs/latest`, {
    credentials: "same-origin",
  });
  const data = await res.json();
  if (!data.cfgNum) throw new Error(data.error || res.statusText);
  return data;
}

// The counters reuse the first query of each explorer: grouping by first
// letter returns the total number of entries at no extra cost.
// NB: the server may return it as a string
async function total(p: Promise<{ total?: number | string }>): Promise<number> {
  const n = Number((await p).total);
  if (Number.isNaN(n)) throw new Error("No total");
  return n;
}

type Loaded<T> = { state: "loading" } | { state: "error" } | { state: "ok"; value: T };

function useLoad<T>(enabled: boolean, load: () => Promise<T>): Loaded<T> {
  const [res, setRes] = useState<Loaded<T>>({ state: "loading" });
  useEffect(() => {
    if (!enabled) return;
    let cancelled = false;
    load()
      .then((value) => !cancelled && setRes({ state: "ok", value }))
      .catch(() => !cancelled && setRes({ state: "error" }));
    return () => {
      cancelled = true;
    };
    // Load once: `load` is a fresh closure on each render
  }, [enabled]);
  return res;
}

function HomeCard({
  target,
  icon,
  title,
  value,
  label,
  children,
}: {
  target: string;
  icon: ReactNode;
  title: string;
  value: Loaded<ReactNode>;
  label: string;
  children?: ReactNode;
}) {
  const { t } = useTranslation();
  return (
    <Card className="homeCard" elevation={0}>
      <CardActionArea className="homeCardAction" href={target}>
        <div className="homeCardHeader">
          <span className="homeCardIcon">{icon}</span>
          <span className="homeCardTitle">{title}</span>
          <ArrowForwardIcon className="homeCardArrow" fontSize="small" />
        </div>
        <div className="homeCardValue">
          {value.state === "loading" && (
            <Skeleton className="homeCardSkeleton" variant="text" />
          )}
          {value.state === "error" && (
            <span className="homeCardUnavailable">{t("unavailable")}</span>
          )}
          {value.state === "ok" && value.value}
        </div>
        <div className="homeCardLabel">{label}</div>
        {children}
      </CardActionArea>
    </Card>
  );
}

export function ManagerHome() {
  const { t } = useTranslation();
  const confOn = isModuleEnabled("manager.html");
  const sessionsOn = isModuleEnabled("sessions.html");
  const notifsOn = isModuleEnabled("notifications.html");
  const sfaOn = isModuleEnabled("2ndfa.html");

  const conf = useLoad(confOn, latestConf);
  const sessions = useLoad(sessionsOn, () =>
    total(listSessions("global", "groupBy=substr(_whatToTrace,1)"))
  );
  const notifs = useLoad(notifsOn, () =>
    total(listNotifications("actives", "groupBy=substr(uid,1)"))
  );
  const sfa = useLoad(sfaOn, () =>
    total(listSfa("groupBy=substr(_session_uid,1)"))
  );

  const confValue: Loaded<ReactNode> =
    conf.state === "ok" ? { state: "ok", value: `#${conf.value.cfgNum}` } : conf;

  return (
    <div className="homePage">
      <div className="homeHead">
        <strong className="title">LemonLDAP::NG</strong>
        {(window as any).version && (
          <span className="homeVersion">
            {t("version")} {(window as any).version}
          </span>
        )}
      </div>
      <div className="homeCards">
        {confOn && (
          <HomeCard
            target="manager.html"
            icon={<SettingsOutlinedIcon />}
            title={t("Configuration")}
            value={confValue}
            label={t("currentConfiguration")}
          >
            {conf.state === "ok" && (
              <dl className="homeCardDetails">
                {conf.value.cfgDate && (
                  <>
                    <dt>{t("date")}</dt>
                    <dd>{new Date(conf.value.cfgDate * 1000).toLocaleString()}</dd>
                  </>
                )}
                {conf.value.cfgAuthor && (
                  <>
                    <dt>{t("author")}</dt>
                    <dd>{conf.value.cfgAuthor}</dd>
                  </>
                )}
                {conf.value.cfgLog && (
                  <>
                    <dt>{t("cfgLog")}</dt>
                    <dd>{conf.value.cfgLog}</dd>
                  </>
                )}
              </dl>
            )}
          </HomeCard>
        )}
        {sessionsOn && (
          <HomeCard
            target="sessions.html"
            icon={<GroupOutlinedIcon />}
            title={t("sessions")}
            value={sessions}
            label={t("ssoSessions")}
          />
        )}
        {notifsOn && (
          <HomeCard
            target="notifications.html"
            icon={<NotificationsNoneOutlinedIcon />}
            title={t("notifications")}
            value={notifs}
            label={t("activeNotifications")}
          />
        )}
        {sfaOn && (
          <HomeCard
            target="2ndfa.html"
            icon={<SecurityOutlinedIcon />}
            title={t("secondFactors")}
            value={sfa}
            label={t("usersWith2F")}
          />
        )}
      </div>
    </div>
  );
}
