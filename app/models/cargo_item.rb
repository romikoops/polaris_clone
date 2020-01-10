# frozen_string_literal: true

class CargoItem < Legacy::CargoItem
end

# == Schema Information
#
# Table name: cargo_items
#
#  id                 :bigint           not null, primary key
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
#  sandbox_id         :uuid
#
