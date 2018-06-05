# frozen_string_literal: true

class AggregatedCargo < ApplicationRecord
  belongs_to :shipment
  before_validation :set_chargeable_weight!

  def set_chargeable_weight!
    return nil if shipment.itinerary.nil?

    self.chargeable_weight = calc_chargeable_weight(shipment.itinerary.mode_of_transport)
  end

  def calc_chargeable_weight(mot)
    [volume * CargoItem::EFFECTIVE_TONNAGE_PER_CUBIC_METER[mot.to_sym] * 1000, weight].max
  end

  def dangerous_goods?
    false
  end
end
