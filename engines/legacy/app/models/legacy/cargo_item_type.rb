# frozen_string_literal: true

module Legacy
  class CargoItemType < ApplicationRecord
    self.table_name = "cargo_item_types"
    has_many :cargo_items, class_name: "Legacy::CargoItem"
    has_many :tenant_cargo_item_types, class_name: "Legacy::TenantCargoItemType"
  end
end

# == Schema Information
#
# Table name: cargo_item_types
#
#  id          :bigint           not null, primary key
#  area        :string
#  category    :string
#  description :string
#  dimension_x :decimal(, )
#  dimension_y :decimal(, )
#  length      :decimal(, )
#  width       :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
