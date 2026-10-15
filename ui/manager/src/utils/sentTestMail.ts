import { apiUrl } from "./urls";
export async function sendTestMail(dest: string) {
  try {
    const response = await fetch(apiUrl("confs//sendTestMail"), {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ dest }),
    });

    const result = await response.json();
    return result;
  } catch (error) {
    console.error("Error sending test mail:", error);
    throw new Error(JSON.stringify(error));
  }
}
