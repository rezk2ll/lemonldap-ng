import { staticUrl } from "./urls";
export function getTree() {
  try {
    const response = fetch(staticUrl("nstruct.json"));
    return response;
  } catch (error) {
    throw new Error(JSON.stringify(error));
  }
}
