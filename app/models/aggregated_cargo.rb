# frozen_string_literal: true

class AggregatedCargo < Legacy::AggregatedCargo
  belongs_to :shipment
  before_validation :set_chargeable_weight!
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

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

# == Schema Information
#
# Table name: aggregated_cargos
#
#  id                :bigint           not null, primary key
#  weight            :decimal(, )
#  volume            :decimal(, )
#  chargeable_weight :decimal(, )
#  shipment_id       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#
