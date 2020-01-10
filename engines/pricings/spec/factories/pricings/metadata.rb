FactoryBot.define do
  factory :pricings_metadatum, class: 'Pricings::Metadatum' do
    association :tenant, factory: :tenants_tenant
  end
end
