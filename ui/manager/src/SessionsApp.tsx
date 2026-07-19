import { Suspense, useState } from "react";
import { useTranslation } from "react-i18next";
import Navbar from "./components/Navbar";
import { SessionsExplorer } from "./dashboards/SessionsExplorer";
import "./App.css";

export default function SessionsApp({ htmlName }: { htmlName: string }) {
  useTranslation();
  const [open, setOpen] = useState(window.outerWidth > 950);
  return (
    <Suspense fallback="loading">
      <Navbar htmlName={htmlName} open={open} toggleNavbar={() => setOpen(!open)} />
      <div className={open ? "open" : "closed"}>
        <SessionsExplorer />
      </div>
    </Suspense>
  );
}
