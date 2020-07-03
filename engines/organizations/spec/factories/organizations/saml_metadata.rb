FactoryBot.define do
  factory :organizations_saml_metadatum, class: 'SamlMetadatum' do
    organization { nil }
    content { "MyText" }
  end
end
