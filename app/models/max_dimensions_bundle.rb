class MaxDimensionsBundle < ApplicationRecord
  belongs_to :tenant
  validates :mode_of_transport, presence: true
  CustomValidations.inclusion(self, :mode_of_transport, %w(ocean rail air general))
  validates :dimension_x, :dimension_y, :dimension_z, :payload_in_kg, :chargeable_weight,
    numericality: true, allow_nil: true

  scope :aggregate,  -> { where(aggregate: true) }
  scope :unit,       -> { where(aggregate: false) }

  CARGO_ITEM_DEFAULTS = {
    general: {
      dimension_x:       "590.0",
      dimension_y:       "234.2",
      dimension_z:       "228.0",
      payload_in_kg:     "21_770.0",
      chargeable_weight: "21_770.0"
    },
    air: {
      dimension_x:       "120.0",
      dimension_y:       "80.0",
      dimension_z:       "158.0",
      payload_in_kg:     "1_500.0",
      chargeable_weight: "1_500.0"
    }
  }.map_deep_values { |v| BigDecimal.new(v) }
  
  CARGO_ITEM_AGGREGATE_DEFAULTS = {
    general: {
      dimension_x:       "0",
      dimension_y:       "0",
      dimension_z:       "0",
      payload_in_kg:     "0",
      chargeable_weight: "0"
    },
    air: {
      dimension_x:       "0",
      dimension_y:       "0",
      dimension_z:       "0",
      payload_in_kg:     "1_500.0",
      chargeable_weight: "1_500.0"
    }
  }.map_deep_values { |v| BigDecimal.new(v) }

  def self.to_max_dimensions_hash
    all.reduce({}) do |return_h, max_dimensions_bundle|
      return_h.merge(max_dimensions_bundle.to_max_dimension_hash)
    end
  end

  def self.create_defaults_for(tenant, options = {})
    return create_all_defaults_for(tenant) if options[:all]

    aggregate = !!options[:aggregate]

    defaults = aggregate ? CARGO_ITEM_AGGREGATE_DEFAULTS : CARGO_ITEM_DEFAULTS
    defaults.map do |mode_of_transport, max_dimensions_hash|
      create(max_dimensions_hash.merge(
        tenant: tenant, mode_of_transport: mode_of_transport, aggregate: aggregate
      ))
    end
  end

  def to_max_dimension_hash
    {
      mode_of_transport.to_sym => {
        dimension_x:       dimension_x,
        dimension_y:       dimension_y,
        dimension_z:       dimension_z,
        payload_in_kg:     payload_in_kg,
        chargeable_weight: chargeable_weight
      }
    }
  end

  private

  def self.create_all_defaults_for(tenant)
    [
      create_defaults_for(tenant),
      create_defaults_for(tenant, aggregate: true),
    ]
  end
end
