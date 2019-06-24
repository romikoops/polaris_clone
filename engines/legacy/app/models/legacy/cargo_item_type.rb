# frozen_string_literal: true

module Legacy
  class CargoItemType < ApplicationRecord
    self.table_name = 'cargo_item_types'
    has_many :cargo_items, class_name: 'Legacy::CargoItem'
  end
end

# == Schema Information
#
# Table name: cargo_item_types
#
#  id          :bigint(8)        not null, primary key
#  dimension_x :decimal(, )
#  dimension_y :decimal(, )
#  description :string
#  area        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  category    :string
#
