import { Suspense, useState } from "react";
import { useTranslation } from "react-i18next";
import Navbar from "./components/Navbar";
import { NotificationsExplorer } from "./dashboards/NotificationsExplorer";
import "./App.css";

export default function NotificationsApp({ htmlName }: { htmlName: string }) {
  useTranslation();
  const [open, setOpen] = useState(window.outerWidth > 950);
  return (
    <Suspense fallback="loading">
      <Navbar htmlName={htmlName} open={open} toggleNavbar={() => setOpen(!open)} />
      <div className={open ? "open" : "closed"}>
        <NotificationsExplorer />
      </div>
    </Suspense>
  );
}
