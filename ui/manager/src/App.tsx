import { Suspense, useState } from "react";
import { useTranslation } from "react-i18next";
import { Navigate, Route, Routes } from "react-router-dom";
import { HistoryRouter as Router } from "redux-first-history/rr6";
import "./App.css";
import { useAppSelector } from "./app/hooks";
import { history } from "./app/store";
import Navbar from "./components/Navbar";
import { Configuration } from "./pages/Configuration";
import { PartialConfiguration } from "./pages/PartialConfiguration";

function App({ htmlName }: { htmlName: string }) {
  useTranslation();
  const location = useAppSelector((state) => state.router.location);
  const infos = location?.hash.replace("#", "").split("/");
  const partial = htmlName === "partial.html" ? 1 : 0;
  // `open` now only drives the mobile section-links drawer (see Navbar), so
  // it stays closed by default regardless of viewport width.
  const [open, setOpen] = useState(false);
  const toggleNavbar = () => {
    setOpen(!open);
  };
  return (
    <Suspense fallback="loading">
      <Router history={history}>
        <Navbar htmlName={htmlName} open={open} toggleNavbar={toggleNavbar} />
        <Routes>
          <Route
            path={htmlName}
            element={
              partial ? (
                <div className="pageContent">
                  <PartialConfiguration
                    location={{
                      type: infos ? infos[0] : "",
                      info: infos
                        ? {
                            name: infos.length === 3 ? infos[2] : infos[1],
                            type: infos.length === 3 ? infos[1] : "",
                          }
                        : { name: "", type: "" },
                    }}
                  />
                </div>
              ) : (
                <div className="pageContent">
                  <Configuration
                    location={{
                      type: infos ? infos[0] : "",
                      info: infos
                        ? {
                            name: infos.length === 3 ? infos[2] : infos[1],
                            type: infos.length === 3 ? infos[1] : "",
                          }
                        : { name: "", type: "" },
                    }}
                  />
                </div>
              )
            }
          />
          {/* The server also serves this page on other paths (e.g. "/" for
              the default route): redirect to the canonical URL, otherwise no
              route matches and the page stays empty. */}
          <Route
            path="*"
            element={
              <Navigate
                replace
                to={{
                  pathname: `/${htmlName}`,
                  search: location?.search,
                  hash: location?.hash,
                }}
              />
            }
          />
        </Routes>
      </Router>
    </Suspense>
  );
}

export default App;
