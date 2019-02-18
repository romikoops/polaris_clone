FactoryBot.define do
  factory :trucking_scope, class: 'Scope' do
    load_type { 'cargo_item' }
    cargo_class { 'lcl' }
    truck_type { 'default' }
    carriage { 'pre' }
    association :courier
  end
end
