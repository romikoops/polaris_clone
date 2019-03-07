FactoryBot.define do
  factory :trucking_scope, class: 'Trucking::Scope' do
    load_type { 'cargo_item' }
    cargo_class { 'lcl' }
    truck_type { 'default' }
    carriage { 'pre' }
    association :courier, factory: :trucking_courier
  end
end
