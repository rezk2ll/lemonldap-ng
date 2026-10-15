import { indentDocument } from "../../src/utils/indentDocument";

describe("indentDocument", () => {
  it("indents single-line XML, keeping text content", () => {
    const xml =
      '<?xml version="1.0"?><md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" entityID="x">' +
      '<md:SPSSODescriptor><md:KeyDescriptor use="signing"><X509Certificate>MIIC\nabc</X509Certificate>' +
      '</md:KeyDescriptor><md:NameIDFormat>email</md:NameIDFormat><md:SingleLogoutService Location="y"/>' +
      '<md:AssertionConsumerService index="0"></md:AssertionConsumerService>' +
      "</md:SPSSODescriptor></md:EntityDescriptor>";
    expect(indentDocument(xml)).toBe(
      [
        '<?xml version="1.0"?>',
        '<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" entityID="x">',
        "  <md:SPSSODescriptor>",
        '    <md:KeyDescriptor use="signing">',
        "      <X509Certificate>MIIC\nabc</X509Certificate>",
        "    </md:KeyDescriptor>",
        "    <md:NameIDFormat>email</md:NameIDFormat>",
        '    <md:SingleLogoutService Location="y"/>',
        '    <md:AssertionConsumerService index="0"></md:AssertionConsumerService>',
        "  </md:SPSSODescriptor>",
        "</md:EntityDescriptor>",
      ].join("\n")
    );
  });

  it("is stable on already indented XML", () => {
    const xml = "<a>\n  <b>c</b>\n</a>";
    expect(indentDocument(xml)).toBe(xml);
  });

  it("keeps empty elements on one line", () => {
    expect(indentDocument("<a><b></b><a/></a>")).toBe(
      "<a>\n  <b></b>\n  <a/>\n</a>"
    );
  });

  it("indents JSON", () => {
    expect(indentDocument('{"keys":[{"kty":"RSA"}]}')).toBe(
      '{\n  "keys": [\n    {\n      "kty": "RSA"\n    }\n  ]\n}'
    );
  });

  it("rejects invalid documents", () => {
    expect(indentDocument("<a><b></a>")).toBeNull();
    expect(indentDocument("{oops")).toBeNull();
    expect(indentDocument("-----BEGIN CERTIFICATE-----")).toBeNull();
  });
});
