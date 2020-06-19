# frozen_string_literal: true

module Legacy
  class MaxDimensionsBundle < ApplicationRecord
    MODES_OF_TRANSPORT = %w[ocean rail air truck truck_carriage general].freeze

    self.table_name = 'max_dimensions_bundles'

    belongs_to :tenant
    belongs_to :tenant_vehicle, optional: true
    belongs_to :itinerary, optional: true
    belongs_to :carrier, optional: true
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    validates :mode_of_transport, presence: true, uniqueness: {
      scope: %i[tenant_id aggregate tenant_vehicle_id carrier_id cargo_class itinerary_id],
      message: lambda do |obj, _|
        max_dimensions_name = "max#{aggregate ? '_aggregate' : ''}_dimensions"

        "'#{obj.mode_of_transport}' already exists"
      end
    }
    validates :mode_of_transport,
              inclusion: {
                in: MODES_OF_TRANSPORT,
                message: "must be included in #{MODES_OF_TRANSPORT}"
              },
              allow_nil: true
    validates :payload_in_kg, numericality: { greater_than: 0 }
    validates :chargeable_weight, numericality: { greater_than: 0 }, if: :lcl?
    validates :width, :length, :height,
              numericality: { greater_than: 0 }, if: :dimensions_required?
    validates :cargo_class, presence: true

    has_paper_trail

    scope :aggregate,  -> { where(aggregate: true, cargo_class: 'lcl') }
    scope :unit,       -> { where(aggregate: false, cargo_class: 'lcl') }

    CARGO_ITEM_DEFAULTS = {
      general: {
        width: 590.0,
        length: 234.2,
        height: 228.0,
        payload_in_kg: 21_770.0,
        chargeable_weight: 21_770.0
      },
      air: {
        width: 120.0,
        length: 100.0,
        height: 150.0,
        payload_in_kg: 1_000.0,
        chargeable_weight: 1_000.0
      }
    }.freeze

    CARGO_ITEM_AGGREGATE_DEFAULTS = {
      general: {
        width: 590,
        length: 590,
        height: 590,
        payload_in_kg: 40_000,
        chargeable_weight: 40_000
      },
      air: {
        width: 590,
        length: 590,
        height: 590,
        payload_in_kg: 1_000.0,
        chargeable_weight: 1_000.0
      }
    }.freeze

    def self.to_max_dimensions_hash
      where(cargo_class: 'lcl').reduce({}) do |return_h, max_dimensions_bundle|
        return_h.merge(max_dimensions_bundle.to_max_dimension_hash)
      end
    end

    def self.create_defaults_for(tenant, options = {})
      return create_all_defaults_for(tenant, options) if options.delete(:all)

      aggregate = !!options[:aggregate]

      defaults = aggregate ? CARGO_ITEM_AGGREGATE_DEFAULTS : CARGO_ITEM_DEFAULTS
      defaults.map do |mode_of_transport, max_dimensions_hash|
        next if excluded_in_options?(options, mode_of_transport)

        find_or_initialize_by(
          tenant: tenant, mode_of_transport: mode_of_transport, aggregate: aggregate, cargo_class: 'lcl'
        ).update(max_dimensions_hash)
      end.compact
    end

    def to_max_dimension_hash
      {
        mode_of_transport.to_sym => {
          width: width,
          length: length,
          height: height,
          payload_in_kg: payload_in_kg,
          chargeable_weight: chargeable_weight
        }
      }
    end

    private

    def dimensions_required?
      aggregate.blank? && cargo_class == 'lcl'
    end

    def lcl?
      cargo_class == 'lcl'
    end

    def self.excluded_in_options?(options, mode_of_transport)
      return false if options[:modes_of_transport].nil?

      modes_of_transport = [options[:modes_of_transport]].flatten.compact
      modes_of_transport.exclude?(mode_of_transport)
    end

    def self.create_all_defaults_for(tenant, options)
      [
        create_defaults_for(tenant, options),
        create_defaults_for(tenant, options.merge(aggregate: true))
      ]
    end
  end
end

# == Schema Information
#
# Table name: max_dimensions_bundles
#
#  id                :bigint           not null, primary key
#  aggregate         :boolean
#  cargo_class       :string
#  chargeable_weight :decimal(, )
#  dimension_x       :decimal(, )
#  dimension_y       :decimal(, )
#  dimension_z       :decimal(, )
#  height            :decimal(, )
#  length            :decimal(, )
#  mode_of_transport :string
#  payload_in_kg     :decimal(, )
#  volume            :decimal(, )      default(1000.0)
#  width             :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  carrier_id        :bigint
#  itinerary_id      :bigint
#  sandbox_id        :uuid
#  tenant_id         :integer
#  tenant_vehicle_id :bigint
#
# Indexes
#
#  index_max_dimensions_bundles_on_cargo_class        (cargo_class)
#  index_max_dimensions_bundles_on_carrier_id         (carrier_id)
#  index_max_dimensions_bundles_on_itinerary_id       (itinerary_id)
#  index_max_dimensions_bundles_on_mode_of_transport  (mode_of_transport)
#  index_max_dimensions_bundles_on_sandbox_id         (sandbox_id)
#  index_max_dimensions_bundles_on_tenant_id          (tenant_id)
#  index_max_dimensions_bundles_on_tenant_vehicle_id  (tenant_vehicle_id)
#
