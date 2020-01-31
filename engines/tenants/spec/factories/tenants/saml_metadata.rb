# frozen_string_literal: true

FactoryBot.define do
  factory :tenants_saml_metadatum, class: 'Tenants::SamlMetadatum' do
    association :tenant, factory: :tenants_tenant
    content do
      <<-METADATA
      <?xml version="1.0" encoding="UTF-8" standalone="no"?>
      <md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" entityID="https://accounts.google.com/o/saml2?idpid=C03um7o22" validUntil="2024-08-25T19:46:29.000Z">
        <md:IDPSSODescriptor WantAuthnRequestsSigned="false" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
          <md:KeyDescriptor use="signing">
            <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
              <ds:X509Data>
                <ds:X509Certificate>MIIDdDCCAlygAwIBAgIGAWzUnZscMA0GCSqGSIb3DQEBCwUAMHsxFDASBgNVBAoTC0dvb2dsZSBJ
                  bmMuMRYwFAYDVQQHEw1Nb3VudGFpbiBWaWV3MQ8wDQYDVQQDEwZHb29nbGUxGDAWBgNVBAsTD0dv
                  b2dsZSBGb3IgV29yazELMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWEwHhcNMTkwODI3
                  MTk0NjI5WhcNMjQwODI1MTk0NjI5WjB7MRQwEgYDVQQKEwtHb29nbGUgSW5jLjEWMBQGA1UEBxMN
                  TW91bnRhaW4gVmlldzEPMA0GA1UEAxMGR29vZ2xlMRgwFgYDVQQLEw9Hb29nbGUgRm9yIFdvcmsx
                  CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
                  MIIBCgKCAQEAxBpww5gQNwb85ifj6lH4qwyJKNnr0ZJWxzalyx7KdH2M1mPf7u3wyGtNyKOuhw+h
                  w0fQEVhgCMq0ZWy9c3WPCw8WwhOIuJ5STwqvpak0cWmo8UqGSH2xffEMJ45FBb/EL7n/WZTkCr2F
                  dHkScL9JORaqcWSA2Q9jEhuKP/quj5T6CkQoHCaoU5DVtZiNT0fym7uQ1RetmSdkxhxi0ZmjNEC2
                  ydgxShO1BHdms0kNVn+sNPOvVxKoz707fib7DHAogCvGhDV0BObcafgInuRFcGG8CKS93GvV+6bG
                  SyRl4MWkOcQVn75pfhl1Cd7bQA8nmsAkaFnMEXklhRC01x/RvQIDAQABMA0GCSqGSIb3DQEBCwUA
                  A4IBAQBqlJ/V797FTbBV41HT+Ntu1Q65mrmK5IUmgs9bF04apcKeaqzvpDwH8q+u5Uu9x2GUzXwe
                  5N/kE2vrRPkOZUQfupgRTmiMNt9e32i65lIMmwqWtjcNi6dL6katoxxpbqM4W/TFTkKjvnvUKNOr
                  Msu/2a4sOew8w9sowElGJ3fZO1iHgvwlIlWgL7LvC8gnOp7n8JchrSWfQsI9tsP+j/H0cO7Lbsdf
                  7bJeRhuMsfqzrOGdrYyJ8F4ohNnpXhhLw4t0v5qZ0cJq7Wj10o6491TPyeQbEXqWqtf/Es8Cccja
                  bD4ubiCfPexvKQh4TDhQhXqPOi0d7N4/+R0+OrwHoFi2</ds:X509Certificate>
              </ds:X509Data>
            </ds:KeyInfo>
          </md:KeyDescriptor>
          <md:NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</md:NameIDFormat>
          <md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://accounts.google.com/o/saml2/idp?idpid=C03um7o22"/>
          <md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://accounts.google.com/o/saml2/idp?idpid=C03um7o22"/>
        </md:IDPSSODescriptor>
      </md:EntityDescriptor>
      METADATA
    end
  end
end
