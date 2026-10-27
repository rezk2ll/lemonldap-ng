// Keys of the applications of a menu category. Besides its applications, a
// category holds "catname", "type", "order" and, when it has a translation
// key, "options": only the entries typed "application" are kept, as the
// portal does.
export function menuApplicationKeys(category: object): string[] {
  const entries = category as Record<string, unknown>;
  return Object.keys(entries).filter((key) => {
    const entry = entries[key];
    return (
      typeof entry === "object" &&
      entry !== null &&
      (entry as Record<string, unknown>).type === "application"
    );
  });
}
