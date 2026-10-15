import { act, renderHook } from "@testing-library/react";
import { useInfiniteScroll } from "../../src/utils/useInfiniteScroll";

let trigger: (visible: boolean) => void = () => {};

beforeEach(() => {
  (global as any).IntersectionObserver = class {
    constructor(cb: (entries: { isIntersecting: boolean }[]) => void) {
      trigger = (visible) => cb([{ isIntersecting: visible }]);
    }
    observe() {}
    disconnect() {}
  };
});

afterEach(() => {
  delete (global as any).IntersectionObserver;
});

const list = Array.from({ length: 50 }, (_, i) => i);

function setup(items: number[], key: string) {
  return renderHook(
    ({ items, key }) => {
      const r = useInfiniteScroll(items, 20, key);
      // Attach the sentinel ref as a rendered element would
      (r.sentinel as any).current ??= document.createElement("div");
      return r;
    },
    { initialProps: { items, key } }
  );
}

describe("useInfiniteScroll", () => {
  it("shows the first batch, then more when the sentinel is visible", () => {
    const { result, rerender } = setup(list, "");
    expect(result.current.shown).toHaveLength(20);
    // The observer is created once the sentinel ref is attached
    rerender({ items: list, key: "" });
    act(() => trigger(true));
    expect(result.current.shown).toHaveLength(40);
    act(() => trigger(true));
    expect(result.current.shown).toHaveLength(50);
    expect(result.current.hasMore).toBe(false);
  });

  it("starts again from the first batch when the reset key changes", () => {
    const { result, rerender } = setup(list, "");
    rerender({ items: list, key: "" });
    act(() => trigger(true));
    expect(result.current.shown).toHaveLength(40);
    rerender({ items: list.filter((i) => i % 2), key: "odd" });
    expect(result.current.shown).toHaveLength(20);
  });

  it("keeps what is shown when the list changes with the same key", () => {
    const { result, rerender } = setup(list, "");
    rerender({ items: list, key: "" });
    act(() => trigger(true));
    rerender({ items: [...list], key: "" });
    expect(result.current.shown).toHaveLength(40);
  });
});
