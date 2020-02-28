# frozen_string_literal: true

module Legacy
  class AggregatedCargo < ApplicationRecord
    self.table_name = 'aggregated_cargos'
    belongs_to :shipment, class_name: 'Legacy::Shipment'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    before_validation :set_chargeable_weight!
    DEFAULT_HEIGHT = 130
    DIMENSIONS = %i[weight volume chargeable_weight].freeze
    DIMENSION_MAP = {
      weight: 'payload_in_kg',
      chargeable_weight: 'chargeable_weight'
    }.freeze

    delegate :tenant, to: :shipment

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

    def valid_for_mode_of_transport?(mode_of_transport)
      mode_of_transport ||= shipment.itinerary.try(:mode_of_transport)
      self.chargeable_weight = calc_chargeable_weight(mode_of_transport)
      max_dimensions = max_dimension(tenant_id: tenant.id, mode_of_transport: mode_of_transport)
      exceeded_dimensions = DIMENSION_MAP.reject do |attribute, validating|
        self[attribute] <= max_dimensions[validating]
      end
      self.chargeable_weight = nil

      exceeded_dimensions.empty?
    end

    private

    def max_dimension(tenant_id:, mode_of_transport:)
      bundle = MaxDimensionsBundle.find_by(tenant_id: tenant_id, mode_of_transport: mode_of_transport, aggregate: true)
      bundle || MaxDimensionsBundle.find_by(tenant_id: tenant_id, mode_of_transport: 'general', aggregate: true)
    end
  end
end

# == Schema Information
#
# Table name: aggregated_cargos
#
#  id                :bigint           not null, primary key
#  chargeable_weight :decimal(, )
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
