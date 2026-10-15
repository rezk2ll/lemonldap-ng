// Indent an XML or JSON document (SAML metadata, JWKS...) so its structure
// shows. Returns null when the text is neither valid XML nor valid JSON.
export function indentDocument(text: string): string | null {
  const trimmed = text.trim();
  if (/^[[{]/.test(trimmed)) {
    try {
      return JSON.stringify(JSON.parse(trimmed), null, 2);
    } catch {
      return null;
    }
  }
  if (trimmed.startsWith("<")) {
    const doc = new DOMParser().parseFromString(trimmed, "application/xml");
    if (doc.getElementsByTagName("parsererror").length) return null;
    return indentXml(trimmed);
  }
  return null;
}

// Only whitespace between tags is changed: text content (certificates...) is
// kept as is.
function indentXml(xml: string): string {
  let depth = 0;
  return xml
    .replace(/>\s*</g, ">\0<")
    // keep empty elements (<a ...></a>) on one line
    .replace(/(<([\w:.-]+)(?:\s[^<>]*[^/<>])?)>\0<\/\2>/g, "$1></$2>")
    .split("\0")
    .map((node) => {
      const isClosing = node.startsWith("</");
      const isOpening =
        !isClosing &&
        !/^<[?!]/.test(node) &&
        !node.endsWith("/>") &&
        !node.includes("</");
      if (isClosing) depth = Math.max(depth - 1, 0);
      const line = "  ".repeat(depth) + node;
      if (isOpening) depth++;
      return line;
    })
    .join("\n");
}
