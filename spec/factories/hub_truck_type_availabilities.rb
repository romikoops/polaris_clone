FactoryBot.define do
  factory :hub_truck_type_availability do
    hub :association
    truck_type_availability :association
  end
end
