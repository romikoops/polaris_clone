# frozen_string_literal: true

module Legacy
  class AggregatedCargo < ApplicationRecord
    self.table_name = 'aggregated_cargos'

    acts_as_paranoid

    belongs_to :shipment, class_name: 'Legacy::Shipment'
    before_validation :set_chargeable_weight!
    DEFAULT_HEIGHT = 130
    DIMENSIONS = %i[weight volume chargeable_weight].freeze
    AGGREGATE_DIMENSION_MAP = {
      weight: 'payload_in_kg',
      chargeable_weight: 'chargeable_weight'
    }.freeze

    delegate :organization, to: :shipment

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

    def cargo_class
      'lcl'
    end
  end
end

# == Schema Information
#
# Table name: aggregated_cargos
#
#  id                :bigint           not null, primary key
#  chargeable_weight :decimal(, )
#  deleted_at        :datetime
#  volume            :decimal(, )
#  weight            :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#  shipment_id       :integer
#
# Indexes
#
#  index_aggregated_cargos_on_sandbox_id  (sandbox_id)
#
