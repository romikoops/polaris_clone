# frozen_string_literal: true

class CargoItemType < Legacy::CargoItemType
  has_many :cargo_items

  before_save :set_description

  validates :category, presence: true

  private

  def set_description
    dimensions_prefix = width && length ? "#{width}cm × #{length}cm " : ''
    area_suffix = area ? ": #{area}" : ''
    self.description = dimensions_prefix + category + area_suffix
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
