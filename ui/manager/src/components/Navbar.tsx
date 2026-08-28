import ChevronLeft from "@mui/icons-material/ChevronLeft";
import MenuIcon from "@mui/icons-material/Menu";
import SettingsOutlinedIcon from "@mui/icons-material/SettingsOutlined";
import GroupOutlinedIcon from "@mui/icons-material/GroupOutlined";
import NotificationsNoneOutlinedIcon from "@mui/icons-material/NotificationsNoneOutlined";
import SecurityOutlinedIcon from "@mui/icons-material/SecurityOutlined";
import {
  AppBar,
  Button,
  ButtonGroup,
  Divider,
  Drawer,
  IconButton,
  Menu,
  MenuItem,
  Toolbar,
} from "@mui/material";
import { ReactNode, useState } from "react";
import { useTranslation } from "react-i18next";
import i18n from "../i18n";
import "./NavBar.css";

// Each manager section is a separate SPA (separate HTML page + bundle).
// Navigating between them is a full page load, like the legacy manager.
// Items without a `target` are placeholders not implemented yet.
const NAV_ITEMS: { key: string; icon: ReactNode; target?: string }[] = [
  {
    key: "Configuration",
    icon: <SettingsOutlinedIcon fontSize="small" />,
    target: "manager.html",
  },
  {
    key: "sessions",
    icon: <GroupOutlinedIcon fontSize="small" />,
    target: "sessions.html",
  },
  {
    key: "notifications",
    icon: <NotificationsNoneOutlinedIcon fontSize="small" />,
    target: "notifications.html",
  },
  {
    key: "secondFactors",
    icon: <SecurityOutlinedIcon fontSize="small" />,
    target: "2ndfa.html",
  },
];

// The global nav lives in a top AppBar; `open`/`toggleNavbar` now only drive
// the temporary Drawer used on narrow screens (< ~950px) to hold the section
// links, instead of the old wide/narrow persistent left rail. Per-app pages
// keep their own `.optionNavbar` left column, so we don't want a second
// permanent left rail from the global nav.
function Navbar({
  htmlName,
  open,
  toggleNavbar,
}: {
  htmlName: string;
  open: boolean;
  toggleNavbar: Function;
}) {
  const { t } = useTranslation();
  const partial = htmlName == "partial.html";

  const renderNavItems = (closeDrawerOnClick: boolean) =>
    NAV_ITEMS.map((item) => {
      const active = item.target === htmlName;
      return (
        <div
          key={item.key}
          className={
            "navItem" +
            (active ? " active" : "") +
            (item.target ? "" : " disabled")
          }
          onClick={() => {
            if (item.target) window.location.assign(item.target);
            if (closeDrawerOnClick) toggleNavbar();
          }}
        >
          {item.icon}
          <span>{t(item.key)}</span>
        </div>
      );
    });

  return (
    <>
      <AppBar position="sticky" color="transparent" elevation={0} className="topNav">
        <Toolbar className="topNavToolbar" disableGutters>
          <img
            className="brandLogo"
            src={`static/logos/llng-logo-32.png`}
            alt="LemonLogo"
          />
          {!partial && (
            <nav className="navMenu navMenuDesktop">
              {renderNavItems(false)}
              <LegacyUiSwitch />
            </nav>
          )}
          <div className="topNavSpacer" />
          {!partial && (
            <IconButton
              className="navBurger"
              aria-label="open navigation menu"
              color="inherit"
              onClick={() => toggleNavbar()}
            >
              <MenuIcon />
            </IconButton>
          )}
          <OptionMenu />
        </Toolbar>
      </AppBar>
      {!partial && (
        <Drawer
          className="navDrawerMobile"
          anchor="left"
          open={open}
          onClose={() => toggleNavbar()}
        >
          <div className="navDrawerHeader">
            <IconButton
              aria-label="close navigation menu"
              onClick={() => toggleNavbar()}
            >
              <ChevronLeft />
            </IconButton>
          </div>
          <nav className="navMenu">
            {renderNavItems(true)}
            <LegacyUiSwitch />
          </nav>
        </Drawer>
      )}
    </>
  );
}

// Leave the beta interface: dropping the cookie sends the user back to the
// historical manager, which is served by the same routes.
function LegacyUiSwitch() {
  const { t } = useTranslation();
  return (
    <div
      className="navItem legacyUiSwitch"
      onClick={() => {
        // Clear at the canonical path and at the current directory, to also
        // drop a cookie left over at another path by an earlier session
        for (const path of ["/", location.pathname.replace(/[^/]*$/, "")]) {
          document.cookie = `llngmanagerbeta=; path=${path}; SameSite=Lax; Max-Age=0; expires=Thu, 01 Jan 1970 00:00:00 GMT`;
        }
        window.location.reload();
      }}
    >
      <ChevronLeft fontSize="small" />
      <span>{t("backToLegacyManager")}</span>
    </div>
  );
}

function OptionMenu() {
  const { t } = useTranslation();
  const [menuOpen, setMenuOpen] = useState(false);
  const handleLanguageChange = (language: string) => {
    i18n.changeLanguage(language);
    console.debug(`Language changed to ${language}`);
  };
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);

  return (
    <>
      <IconButton
        edge="end"
        className={`menuBurger`}
        aria-label="menu burger"
        aria-controls="menu-appbar"
        aria-haspopup="true"
        onClick={(e) => {
          setMenuOpen(true);
          setAnchorEl(e.currentTarget);
        }}
        color="inherit"
      >
        <MenuIcon />
      </IconButton>
      <Menu
        id="menu-appbar"
        anchorEl={anchorEl}
        keepMounted
        anchorOrigin={{
          vertical: "bottom",
          horizontal: "right",
        }}
        transformOrigin={{
          vertical: "top",
          horizontal: "right",
        }}
        open={menuOpen}
        onClose={() => setMenuOpen(false)}
      >
        <MenuItem
          onClick={() => {
            (window as any).menulinks.map(
              (el: { title: string; target: string }) => {
                if (el.title === "backtoportal") {
                  window.location.assign(el.target);
                }
              }
            );
          }}
        >
          {t("backtoportal")}
        </MenuItem>
        <MenuItem
          onClick={() => {
            (window as any).menulinks.map(
              (el: { title: string; target: string }) => {
                if (el.title === "logout") {
                  window.location.assign(el.target);
                }
              }
            );
          }}
        >
          {t("logout")}
        </MenuItem>
        <Divider />
        <MenuItem disableRipple>
          <ButtonGroup
            variant="text"
            color="secondary"
            aria-label="language selection"
            sx={{ flexWrap: "wrap" }}
          >
            {(
              (window as unknown as Record<string, string[]>)
                .availableLanguages || []
            ).map((lang: string) => {
              return (
                <Button
                  onClick={() => handleLanguageChange(lang)}
                  key={lang}
                  title={lang}
                  sx={{ minWidth: 0, px: 0.5, py: 0.25 }}
                >
                  {/* Flags live in the deployment's static directory, like in
                      the legacy manager; go through staticPrefix, not a
                      hardcoded /static */}
                  <img
                    src={`${
                      (window as any).staticPrefix || "/static/"
                    }logos/${lang}.png`}
                    alt={lang}
                    width={20}
                    height={14}
                  />
                </Button>
              );
            })}
          </ButtonGroup>
        </MenuItem>
        <Divider />
        <MenuItem>{t("version")} 0.0.1</MenuItem>
      </Menu>
    </>
  );
}

export default Navbar;
