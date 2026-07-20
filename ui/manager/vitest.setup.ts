import "@testing-library/jest-dom";
import { vi } from "vitest";

// Initialize i18n before tests to avoid HTTP backend issues
import i18n from "i18next";
import { initReactI18next } from "react-i18next";

i18n.use(initReactI18next).init({
  lng: "en",
  fallbackLng: "en",
  resources: {
    en: {
      translation: {},
    },
  },
  interpolation: {
    escapeValue: false,
  },
});

// Mock fetch globally
global.fetch = vi.fn((url: string) => {
  // Mock translations endpoint
  if (url.includes("/static/languages/")) {
    return Promise.resolve({
      ok: true,
      json: () => Promise.resolve({}),
      text: () => Promise.resolve("{}"),
    } as Response);
  }

  // Mock config API endpoints
  if (url.includes("/confs/")) {
    return Promise.resolve({
      ok: true,
      redirected: false,
      json: () =>
        Promise.resolve({
          prev: 13,
          cfgNum: 14,
          cfgLog: "",
          cfgDate: 1711110492,
          cfgAuthor: "anonymous",
          cfgVersion: "2.0.13",
          cfgAuthorIP: "172.30.0.1",
        }),
    } as Response);
  }

  if (url.includes("/manager.fcgi/confs/")) {
    return Promise.resolve({
      ok: true,
      json: () =>
        Promise.resolve({
          authentication: "Demo",
          userDB: "Same",
          registerDB: "Demo",
          passwordDB: "Demo",
        }),
    } as Response);
  }

  // Default mock response
  return Promise.resolve({
    ok: true,
    json: () => Promise.resolve({}),
    text: () => Promise.resolve(""),
  } as Response);
}) as unknown as typeof fetch;

// Mock XMLHttpRequest for i18next-http-backend
const mockXHR = {
  open: vi.fn(),
  send: vi.fn(),
  setRequestHeader: vi.fn(),
  readyState: 4,
  status: 200,
  responseText: "{}",
  onreadystatechange: null as (() => void) | null,
  addEventListener: vi.fn(),
  removeEventListener: vi.fn(),
};

(global as any).XMLHttpRequest = vi.fn(() => {
  const xhr = { ...mockXHR };
  setTimeout(() => {
    if (xhr.onreadystatechange) {
      xhr.onreadystatechange();
    }
  }, 0);
  return xhr;
});

// Suppress console.error for expected XHR errors in tests
const originalError = console.error;
console.error = (...args) => {
  if (typeof args[0] === "object" && args[0]?.type === "XMLHttpRequest") {
    return;
  }
  if (typeof args[0] === "string" && args[0].includes("AggregateError")) {
    return;
  }
  originalError.apply(console, args);
};
