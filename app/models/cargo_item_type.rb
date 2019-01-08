# frozen_string_literal: true

class CargoItemType < ApplicationRecord
  has_many :cargo_items

  before_save :set_description

  validates :category, presence: true

  private

  def set_description
    dimensions_prefix = dimension_x && dimension_y ? "#{dimension_x}cm × #{dimension_y}cm " : ''
    area_suffix = area ? ": #{area}" : ''
    self.description = dimensions_prefix + category + area_suffix
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
