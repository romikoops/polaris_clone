# frozen_string_literal: true

FactoryBot.define do
  factory :legacy_cargo_item, class: "Legacy::CargoItem" do
    association :shipment, factory: :legacy_shipment
    association :cargo_item_type, factory: :legacy_cargo_item_type

    payload_in_kg { 200 }
    width { 20 }
    length { 20 }
    height { 20 }
    quantity { 1 }
    dangerous_goods { false }
    stackable { true }
    cargo_class { "lcl" }

    factory :lcl_cargo_item
  end
end

# == Schema Information
#
# Table name: cargo_items
#
#  id                 :bigint           not null, primary key
#  cargo_class        :string
#  chargeable_weight  :decimal(, )
#  contents           :string
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
