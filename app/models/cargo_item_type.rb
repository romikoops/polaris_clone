# frozen_string_literal: true

class CargoItemType < ApplicationRecord
  has_many :cargo_items

  before_save :set_description

  validates :category, presence: true

  private

  def set_description
    dimensions_prefix = dimension_x && dimension_y ? "#{dimension_x}cm × #{dimension_y}cm " : ""
    area_suffix = area ? ": #{area}" : ""
    self.description = dimensions_prefix + category + area_suffix
  end
end
