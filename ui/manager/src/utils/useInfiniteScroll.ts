import { useEffect, useRef, useState } from "react";

// Show a long list by batches: the next batch is appended when the sentinel
// element (rendered after the list while hasMore is true) gets close to the
// viewport. Changing resetKey (search, sort) starts again from the first
// batch; other list changes (an edited application) keep what is shown.
export function useInfiniteScroll<T>(
  items: T[],
  batch: number,
  resetKey: string
) {
  const [count, setCount] = useState(batch);
  const sentinel = useRef<HTMLDivElement>(null);
  const hasMore = count < items.length;

  useEffect(() => setCount(batch), [batch, resetKey]);

  useEffect(() => {
    const el = sentinel.current;
    if (!el || !hasMore || typeof IntersectionObserver === "undefined") return;
    // Recreated after each batch: its first callback reports whether the
    // sentinel is still visible (tall screen), which loads one more batch.
    const observer = new IntersectionObserver(
      (entries) => {
        if (entries.some((entry) => entry.isIntersecting)) {
          setCount((c) => c + batch);
        }
      },
      { rootMargin: "300px" }
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, [batch, count, hasMore]);

  return { shown: items.slice(0, count), sentinel, hasMore };
}
