import { defineConfig } from "vitest/config";

// Tests run under vitest (esbuild-based), which is much faster than jest.
// No SVG/asset imports exist in src, so no asset stubbing is needed; CSS
// imports are disabled (css: false) to mirror the former jest css stub.
export default defineConfig({
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: ["./vitest.setup.ts"],
    include: ["__test__/**/*.test.{ts,tsx}"],
    clearMocks: true,
    css: false,
    coverage: {
      provider: "v8",
      include: ["src/**"],
    },
  },
});
