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
    // Shared CI runners are much slower than a workstation (and may expose
    // more CPUs than their quota): the 5s default makes rendering-heavy
    // dashboard tests time out there.
    testTimeout: 30000,
    css: false,
    coverage: {
      provider: "v8",
      include: ["src/**"],
    },
  },
});
