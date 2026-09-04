import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import Backend from "i18next-http-backend";
import LanguageDetector from "i18next-browser-languagedetector";

// psgi.js (loaded before this bundle) defines these globals. Fall back to
// sensible defaults so the tests, which do not load psgi.js, still work.
const staticPrefix = (window as any).staticPrefix || "/static/";
const availableLanguages = (window as any).availableLanguages;

i18n
  .use(initReactI18next)
  .use(Backend)
  // Pick the language like the legacy manager does: the "llnglanguage" cookie
  // first (so a language chosen in either interface is kept across a switch),
  // then the browser languages, then English.
  .use(LanguageDetector)
  .init({
    fallbackLng: "en",
    supportedLngs: Array.isArray(availableLanguages)
      ? availableLanguages
      : undefined,
    // Match "fr" for a "fr-FR" browser locale, as the legacy manager did
    load: "languageOnly",
    nonExplicitSupportedLngs: true,
    detection: {
      order: ["cookie", "navigator"],
      lookupCookie: "llnglanguage",
      // Persist the choice in the same cookie the legacy manager reads
      caches: ["cookie"],
      cookieMinutes: 365 * 24 * 60,
    },
    backend: {
      // Served from the deployment's static directory, not a hardcoded /static
      loadPath: `${staticPrefix}languages/{{lng}}.json`,
    },
  });

export default i18n;
