FactoryBot.define do
  factory :max_dimensions_bundle do
    mode_of_transport "MyString"
    tenant_id 1
    aggregate false
    dimension_x "9.99"
    dimension_y "9.99"
    dimension_z "9.99"
    payload_in_kg "9.99"
    chargeable_weight "9.99"
  end
end
