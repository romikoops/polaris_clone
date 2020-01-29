# frozen_string_literal: true

FactoryBot.define do
  factory :cargo_item do
    association :shipment
    association :cargo_item_type, factory: :cargo_item_type

    payload_in_kg { 200 }
    dimension_x { 20 }
    dimension_y { 20 }
    dimension_z { 20 }
    quantity { 1 }
    dangerous_goods { false }
    stackable { true }
    cargo_class { 'lcl' }
  end
end

# == Schema Information
#
# Table name: cargo_items
#
#  id                 :bigint           not null, primary key
#  cargo_class        :string
#  chargeable_weight  :decimal(, )
#  customs_text       :string
#  dangerous_goods    :boolean
#  dimension_x        :decimal(, )
#  dimension_y        :decimal(, )
#  dimension_z        :decimal(, )
#  hs_codes           :string           default([]), is an Array
#  payload_in_kg      :decimal(, )
#  quantity           :integer
#  stackable          :boolean          default(TRUE)
#  unit_price         :jsonb
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  cargo_item_type_id :integer
#  sandbox_id         :uuid
#  shipment_id        :integer
#
# Indexes
#
#  index_cargo_items_on_sandbox_id  (sandbox_id)
#
