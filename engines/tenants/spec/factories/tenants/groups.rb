FactoryBot.define do
  factory :tenants_group, class: 'Tenants::Group' do
    association :tenant, factory: :tenants_tenants
  end
end
