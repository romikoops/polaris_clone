class MaxDimensionsBundle < ApplicationRecord
  belongs_to :tenant
  validates :mode_of_transport, presence: true
  CustomValidations.inclusion(self, :mode_of_transport, %w(ocean rail air general))
  validates :dimension_x, :dimension_y, :dimension_z, :payload_in_kg, :chargeable_weight,
    numericality: true, allow_nil: true

end
