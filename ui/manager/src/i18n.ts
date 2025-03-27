import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import Backend from "i18next-http-backend";

i18n
  // pass the i18n instance to react-i18next.
  .use(initReactI18next)
  .use(Backend) // Use the backend to load translations

  // init i18next
  // for all options read: https://www.i18next.com/overview/configuration-options
  .init({
    lng: "en",
    fallbackLng: 'en', // Use fallback language if translation is missing
    backend: {
      // The API URL for translations
      loadPath: "/static/languages/{{lng}}.json", // Adjust this to your API path
    },
  });

export default i18n;
