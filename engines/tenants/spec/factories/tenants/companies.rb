FactoryBot.define do
  factory :tenants_company, class: 'Tenants::Company' do
    name { 'ItsyCargo GmbH' }
    vat_number { '123456789' }
    association :tenant, factory: :tenants_tenant
  end
end
