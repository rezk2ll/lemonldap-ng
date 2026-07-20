import { Suspense, useState } from "react";
import { useTranslation } from "react-i18next";
import Navbar from "./components/Navbar";
import { NotificationsExplorer } from "./dashboards/NotificationsExplorer";
import "./App.css";

export default function NotificationsApp({ htmlName }: { htmlName: string }) {
  useTranslation();
  // `open` only drives the mobile section-links drawer (see Navbar).
  const [open, setOpen] = useState(false);
  return (
    <Suspense fallback="loading">
      <Navbar htmlName={htmlName} open={open} toggleNavbar={() => setOpen(!open)} />
      <div className="pageContent">
        <NotificationsExplorer />
      </div>
    </Suspense>
  );
}
