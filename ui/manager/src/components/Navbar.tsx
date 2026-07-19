import ChevronLeft from "@mui/icons-material/ChevronLeft";
import  ChevronRight from "@mui/icons-material/ChevronRight"
import MenuIcon from "@mui/icons-material/Menu";
import SettingsOutlinedIcon from "@mui/icons-material/SettingsOutlined";
import GroupOutlinedIcon from "@mui/icons-material/GroupOutlined";
import NotificationsNoneOutlinedIcon from "@mui/icons-material/NotificationsNoneOutlined";
import SecurityOutlinedIcon from "@mui/icons-material/SecurityOutlined";
import {
  Button,
  ButtonGroup,
  Divider,
  Drawer,
  IconButton,
  Menu,
  MenuItem,
  Typography,
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
    target: "manager.new.html",
  },
  {
    key: "sessions",
    icon: <GroupOutlinedIcon fontSize="small" />,
    target: "sessions.new.html",
  },
  {
    key: "notifications",
    icon: <NotificationsNoneOutlinedIcon fontSize="small" />,
    target: "notifications.new.html",
  },
  {
    key: "secondFactors",
    icon: <SecurityOutlinedIcon fontSize="small" />,
    target: "2ndfa.new.html",
  },
];

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
  return (
    <>
      <Drawer
        className={`navbar ${open ? "open" : "closed"}`}
        variant="persistent"
        open={open}
        anchor="left"
        sx={{
          width: "250px",
          flexShrink: 0,
          [`& .MuiDrawer-paper`]: { width: "250px", boxSizing: "border-box" },
        }}
      >
        <div className="drawer-header">
          <IconButton color="inherit" onClick={(e) => toggleNavbar()}>
            {open ? <ChevronLeft /> : <ChevronRight />}
          </IconButton>
        </div>
        <div className="navbarOptions">
          <Typography>
            <img
              src={`static/logos/llng-logo-32.png`}
              alt="LemonLogo"
              style={{ backgroundColor: "white" }}
            />
          </Typography>
          {!partial && (
            <nav className="navMenu">
              {NAV_ITEMS.map((item) => {
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
                    }}
                  >
                    {item.icon}
                    <span>{t(item.key)}</span>
                  </div>
                );
              })}
            </nav>
          )}
          <OptionMenu />
        </div>
      </Drawer>
      <Drawer
        variant="persistent"
        className={`navbar ${!open ? "closed" : ""}`}
        open={!open}
        anchor="left"
        sx={{
          width: "40px",
          flexShrink: 0,
          [`& .MuiDrawer-paper`]: { width: "40px", boxSizing: "border-box" },
        }}
      >
        <IconButton color="inherit" onClick={(e) => toggleNavbar()}>
          {open ? <ChevronLeft /> : <ChevronRight />}
        </IconButton>
        <OptionMenu />
      </Drawer>
    </>
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
        transformOrigin={{
          vertical: "bottom",
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
        <MenuItem>
          <ButtonGroup
            variant="text"
            color="secondary"
            aria-label="Basic button group"
          >
            {(
              window as unknown as Record<string, string[]>
            ).availableLanguages.map((lang: string) => {
              return (
                <Button onClick={() => handleLanguageChange(lang)} key={lang}>
                  <img src={`static/logos/${lang}.png`} />
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
