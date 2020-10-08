# frozen_string_literal: true

class CargoItem < Legacy::CargoItem
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
#  deleted_at         :datetime
#  dimension_x        :decimal(, )
#  dimension_y        :decimal(, )
#  dimension_z        :decimal(, )
#  height             :decimal(, )
#  hs_codes           :string           default([]), is an Array
#  length             :decimal(, )
#  payload_in_kg      :decimal(, )
#  quantity           :integer
#  stackable          :boolean          default(TRUE)
#  unit_price         :jsonb
#  width              :decimal(, )
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
