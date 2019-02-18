FactoryBot.define do
  factory :trucking_courier, class: 'Trucking::Courier' do
    name { 'example courier' }
    association :tenant, factory: :legacy_tenant
  end
end
