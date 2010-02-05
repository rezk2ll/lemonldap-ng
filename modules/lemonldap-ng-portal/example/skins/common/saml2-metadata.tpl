<?xml version="1.0"?>
<EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
    entityID="<TMPL_VAR NAME="samlIdentityID">">

  <IDPSSODescriptor
      WantAuthnRequestsSigned="<TMPL_VAR NAME="samlIDPSSODescriptorWantAuthnRequestsSigned">"
      protocolSupportEnumeration="<TMPL_VAR NAME="samlIDPSSODescriptorProtocolSupportEnumeration">">
    <KeyDescriptor use="signing">
      <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
        <ds:KeyValue>
          <TMPL_VAR NAME="samlIDPSSODescriptorKeyDescriptorSigning">
        </ds:KeyValue>
      </ds:KeyInfo>
    </KeyDescriptor>
    <KeyDescriptor use="encryption">
      <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
        <ds:KeyValue>
          <TMPL_VAR NAME="samlServicePrivateKey">
        </ds:KeyValue>
      </ds:KeyInfo>
    </KeyDescriptor>
    <ArtifactResolutionService
      isDefault="<TMPL_VAR NAME="samlIDPSSODescriptorArtifactResolutionServiceArtifactDefault">"
      index="<TMPL_VAR NAME="samlIDPSSODescriptorArtifactResolutionServiceArtifactIndex">"
      Binding="<TMPL_VAR NAME="samlIDPSSODescriptorArtifactResolutionServiceArtifactBinding">"
      Location="<TMPL_VAR NAME="samlIDPSSODescriptorArtifactResolutionServiceArtifactLocation">" />
    <SingleLogoutService
      Binding="<TMPL_VAR NAME="samlIDPSSODescriptorSingleLogoutServiceSOAPBinding">"
      Location="<TMPL_VAR NAME="samlIDPSSODescriptorSingleLogoutServiceSOAPLocation">" />
    <SingleLogoutService
      Binding="<TMPL_VAR NAME="samlIDPSSODescriptorSingleLogoutServiceHTTPBinding">"
      Location="<TMPL_VAR NAME="samlIDPSSODescriptorSingleLogoutServiceHTTPLocation">"
      <TMPL_IF NAME="samlIDPSSODescriptorSingleLogoutServiceHTTPResponseLocation">
      ResponseLocation="<TMPL_VAR NAME="samlIDPSSODescriptorSingleLogoutServiceHTTPResponseLocation">" />
      </TMPL_IF>
    <ManageNameIDService
      Binding="<TMPL_VAR NAME="samlIDPSSODescriptorManageNameIDServiceSOAPBinding">"
      Location="<TMPL_VAR NAME="samlIDPSSODescriptorManageNameIDServiceSOAPLocation">" />
    <ManageNameIDService
      Binding="<TMPL_VAR NAME="samlIDPSSODescriptorManageNameIDServiceHTTPBinding">"
      Location="<TMPL_VAR NAME="samlIDPSSODescriptorManageNameIDServiceHTTPLocation">"
      <TMPL_IF NAME="samlIDPSSODescriptorManageNameIDServiceHTTPResponseLocation">
      ResponseLocation="<TMPL_VAR NAME="samlIDPSSODescriptorManageNameIDServiceHTTPResponseLocation">" />
      </TMPL_IF>
    <SingleSignOnService
      Binding="<TMPL_VAR NAME="samlIDPSSODescriptorSingleSignOnServiceSOAPBinding">"
      Location="<TMPL_VAR NAME="samlIDPSSODescriptorSingleSignOnServiceSOAPLocation">" />
    <SingleSignOnService
      Binding="<TMPL_VAR NAME="samlIDPSSODescriptorSingleSignOnServiceHTTPBinding">"
      Location="<TMPL_VAR NAME="samlIDPSSODescriptorSingleSignOnServiceHTTPLocation">" />
  </IDPSSODescriptor>

  <SPSSODescriptor
      AuthnRequestsSigned="<TMPL_VAR NAME="samlSPSSODescriptorAuthnRequestsSigned">"
      protocolSupportEnumeration="<TMPL_VAR NAME="samlSPSSODescriptorProtocolSupportEnumeration">">
    <KeyDescriptor use="signing">
      <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
        <ds:KeyValue>
          <TMPL_VAR NAME="samlSPSSODescriptorKeyDescriptorSigning">
        </ds:KeyValue>
      </ds:KeyInfo>
    </KeyDescriptor>
    <KeyDescriptor use="encryption">
      <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
        <ds:KeyValue>
          <TMPL_VAR NAME="samlServicePrivateKey">
        </ds:KeyValue>
      </ds:KeyInfo>
    </KeyDescriptor>
    <SingleLogoutService
      Binding="<TMPL_VAR NAME="samlSPSSODescriptorSingleLogoutServiceSOAPBinding">"
      Location="<TMPL_VAR NAME="samlSPSSODescriptorSingleLogoutServiceSOAPLocation">" />
    <SingleLogoutService
      Binding="<TMPL_VAR NAME="samlSPSSODescriptorSingleLogoutServiceHTTPBinding">"
      Location="<TMPL_VAR NAME="samlSPSSODescriptorSingleLogoutServiceHTTPLocation">"
      <TMPL_IF NAME="samlSPSSODescriptorSingleLogoutServiceHTTPResponseLocation">
      ResponseLocation="<TMPL_VAR NAME="samlSPSSODescriptorSingleLogoutServiceHTTPResponseLocation">" />
      </TMPL_IF>
    <AssertionConsumerService
      isDefault="<TMPL_VAR NAME="samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactDefault">"
      index="<TMPL_VAR NAME="samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactIndex">"
      Binding="<TMPL_VAR NAME="samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactBinding">"
      Location="<TMPL_VAR NAME="samlSPSSODescriptorAssertionConsumerServiceHTTPArtifactLocation">" />
    <AssertionConsumerService
      isDefault="<TMPL_VAR NAME="samlSPSSODescriptorAssertionConsumerServiceHTTPPostDefault">"
      index="<TMPL_VAR NAME="samlSPSSODescriptorAssertionConsumerServiceHTTPPostIndex">"
      Binding="<TMPL_VAR NAME="samlSPSSODescriptorAssertionConsumerServiceHTTPPostBinding">"
      Location="<TMPL_VAR NAME="samlSPSSODescriptorAssertionConsumerServiceHTTPPostLocation">" />
    <AssertionConsumerService
      isDefault="<TMPL_VAR NAME="samlSPSSODescriptorAssertionConsumerServiceHTTPRedirectDefault">"
      index="<TMPL_VAR NAME="samlSPSSODescriptorAssertionConsumerServiceHTTPRedirectIndex">"
      Binding="<TMPL_VAR NAME="samlSPSSODescriptorAssertionConsumerServiceHTTPRedirectBinding">"
      Location="<TMPL_VAR NAME="samlSPSSODescriptorAssertionConsumerServiceHTTPRedirectLocation">" />
  </SPSSODescriptor>

  <Organization>
    <OrganizationName xml:lang="en">
      <TMPL_VAR NAME="samlOrganizationName">
    </OrganizationName>
    <OrganizationDisplayName xml:lang="en">
      <TMPL_VAR NAME="samlOrganizationDisplayName">
    </OrganizationDisplayName>
    <OrganizationURL xml:lang="en">
      <TMPL_VAR NAME="samlOrganizationURL">
    </OrganizationURL>
  </Organization>

</EntityDescriptor>
