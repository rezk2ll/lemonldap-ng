/// <reference types="vitest/globals" />

// The tests were written for jest and cast mocks with `as jest.Mock`. Vitest
// exposes `vi` instead of a global `jest`, so alias the type here to keep the
// existing casts type-checking without editing every test file. Runtime calls
// (jest.fn/mock/clearAllMocks) have been converted to `vi.*`.
declare namespace jest {
  type Mock = import("vitest").Mock;
}
