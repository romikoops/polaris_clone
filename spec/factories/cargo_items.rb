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

# == Schema Information
#
# Table name: cargo_items
#
#  id                 :bigint(8)        not null, primary key
#  shipment_id        :integer
#  payload_in_kg      :decimal(, )
#  dimension_x        :decimal(, )
#  dimension_y        :decimal(, )
#  dimension_z        :decimal(, )
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  dangerous_goods    :boolean
#  cargo_class        :string
#  hs_codes           :string           default([]), is an Array
#  cargo_item_type_id :integer
#  customs_text       :string
#  chargeable_weight  :decimal(, )
#  stackable          :boolean          default(TRUE)
#  quantity           :integer
#  unit_price         :jsonb
#
