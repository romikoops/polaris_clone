FactoryBot.define do
  factory :trucking_type_availability, class: 'TypeAvailability' do
    load_type  { 'cargo_item' }
    carriage   { 'pre' }
    truck_type { 'default' }
  end
end
