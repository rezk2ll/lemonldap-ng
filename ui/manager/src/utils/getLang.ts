export function getLang(lang: string) {
  try {
    const response = fetch(`/static/languages/${lang}.json`);
    return response;
  } catch (error) {
    throw new Error(JSON.stringify(error));
  }
}
