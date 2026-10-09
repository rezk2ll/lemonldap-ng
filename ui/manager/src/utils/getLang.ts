import { staticUrl } from "./urls";
export function getLang(lang: string) {
  try {
    const response = fetch(staticUrl(`languages/${lang}.json`));
    return response;
  } catch (error) {
    throw new Error(JSON.stringify(error));
  }
}
