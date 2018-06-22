FactoryBot.define do
  factory :truck_type_availability do
    load_type  "cargo_item"
    carriage   "pre"
    truck_type "default"
  end
end
