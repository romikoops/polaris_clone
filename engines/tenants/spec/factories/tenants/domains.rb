FactoryBot.define do
  factory :tenants_domain, class: 'Domain' do
    tenant_id { "" }
    domain { "MyString" }
    default { false }
  end
end
