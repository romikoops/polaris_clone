# frozen_string_literal: true

module Legacy
  class AggregatedCargo < ApplicationRecord
    self.table_name = 'aggregated_cargos'
    belongs_to :shipment, class_name: 'Legacy::Shipment'
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
end

# == Schema Information
#
# Table name: aggregated_cargos
#
#  id                :bigint(8)        not null, primary key
#  weight            :decimal(, )
#  volume            :decimal(, )
#  chargeable_weight :decimal(, )
#  shipment_id       :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
