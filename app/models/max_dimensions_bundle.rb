# frozen_string_literal: true

class MaxDimensionsBundle < ApplicationRecord
  belongs_to :tenant
  belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
  validates :mode_of_transport, presence: true, uniqueness: {
    scope: %i(tenant_id aggregate),
    message: lambda do |obj, _|
      max_dimensions_name = "max#{aggregate ? '_aggregate' : ''}_dimensions"

      "'#{obj.mode_of_transport}' already exists"
    end
  }
  CustomValidations.inclusion(self, :mode_of_transport, %w(ocean rail air truck truck_carriage general))
  validates :dimension_x, :dimension_y, :dimension_z, :payload_in_kg, :chargeable_weight,
            numericality: true, allow_nil: true

  scope :aggregate,  -> { where(aggregate: true) }
  scope :unit,       -> { where(aggregate: false) }

  CARGO_ITEM_DEFAULTS = {
    general: {
      dimension_x: 590.0,
      dimension_y: 234.2,
      dimension_z: 228.0,
      payload_in_kg: 21_770.0,
      chargeable_weight: 21_770.0
    },
    air: {
      dimension_x: 120.0,
      dimension_y: 100.0,
      dimension_z: 150.0,
      payload_in_kg: 1_000.0,
      chargeable_weight: 1_000.0
    }
  }.freeze

  CARGO_ITEM_AGGREGATE_DEFAULTS = {
    general: {
      dimension_x: 0,
      dimension_y: 0,
      dimension_z: 0,
      payload_in_kg: 0,
      chargeable_weight: 0
    },
    air: {
      dimension_x: 0,
      dimension_y: 0,
      dimension_z: 0,
      payload_in_kg: 1_000.0,
      chargeable_weight: 1_000.0
    }
  }.freeze

  def self.to_max_dimensions_hash
    all.reduce({}) do |return_h, max_dimensions_bundle|
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
        tenant: tenant, mode_of_transport: mode_of_transport, aggregate: aggregate
      ).update(max_dimensions_hash)
    end.compact
  end

  def to_max_dimension_hash
    {
      mode_of_transport.to_sym => {
        dimension_x: dimension_x,
        dimension_y: dimension_y,
        dimension_z: dimension_z,
        payload_in_kg: payload_in_kg,
        chargeable_weight: chargeable_weight
      }
    }
  end

  private

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

# == Schema Information
#
# Table name: max_dimensions_bundles
#
#  id                :bigint           not null, primary key
#  mode_of_transport :string
#  tenant_id         :integer
#  aggregate         :boolean
#  dimension_x       :decimal(, )
#  dimension_y       :decimal(, )
#  dimension_z       :decimal(, )
#  payload_in_kg     :decimal(, )
#  chargeable_weight :decimal(, )
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  sandbox_id        :uuid
#
