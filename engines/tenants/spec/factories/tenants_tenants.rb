FactoryBot.define do
  factory :tenants_tenant, class: 'Tenants::Tenant' do
    subdomain { "MyString" }
    legacy_id { "" }
  end
end
