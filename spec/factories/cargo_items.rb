FactoryBot.define do
  factory :cargo_item do
    association :shipment
    association :cargo_item_type, factory: :cargo_item_type

    payload_in_kg 200
    dimension_x 20
    dimension_y 20
    dimension_z 20
    quantity 1
    dangerous_goods false
    stackable true
    cargo_class "lcl"
  end
end