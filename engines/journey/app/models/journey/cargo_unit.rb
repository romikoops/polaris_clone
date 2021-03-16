# frozen_string_literal: true

module Journey
  class CargoUnit < ApplicationRecord
    CARGO_CLASSES = %w[
      lcl
      aggregated_lcl
      fcl_10
      fcl_20
      fcl_20_ot
      fcl_20_rf
      fcl_20_frs
      fcl_20_frw
      fcl_40
      fcl_40_hq
      fcl_40_ot
      fcl_40_rf
      fcl_40_hq_rf
      fcl_40_frs
      fcl_40_frw
      fcl_45
      fcl_45_hq
      fcl_45_rf
    ].freeze

    has_many :commodity_infos
    has_many :line_item_cargo_units, inverse_of: :cargo_unit
    has_many :line_items, through: :line_item_cargo_units
    belongs_to :query

    measured_weight :weight
    measured_length :width, :length, :height

    validates :quantity, presence: true, numericality: {greater_than: 0}
    validates :weight, measured: {units: :kg, greater_than: 0}
    validates :width, :length, :height, measured: {units: :m}
    validates :width, :length, :height, measured: {greater_than: 0}, if: :lcl?

    validates_inclusion_of :cargo_class, in: CARGO_CLASSES

    enum colli_type: {
      container: "container", # When cargo class is fcl
      barrel: "barrel",
      bottle: "bottle",
      carton: "carton",
      case: "case",
      crate: "crate",
      drum: "drum",
      package: "package",
      pallet: "pallet",
      roll: "roll",
      skid: "skid",
      stack: "stack",
      room_temp_reefer: "room_temp_reefer",
      low_temp_reefer: "low_temp_reefer"
    }

    def lcl?
      cargo_class.downcase.match?(/lcl/)
    end

    def volume
      Measured::Volume.new(width_value * length_value * height_value, "m3")
    end

    def total_volume
      volume.scale(quantity)
    end

    def total_weight
      weight.scale(quantity)
    end
  end
end

# == Schema Information
#
# Table name: journey_cargo_units
#
#  id           :uuid             not null, primary key
#  cargo_class  :string           not null
#  colli_type   :enum
#  height_unit  :string           default("m"), not null
#  height_value :decimal(20, 5)   default(0.0), not null
#  length_unit  :string           default("m"), not null
#  length_value :decimal(20, 5)   default(0.0), not null
#  quantity     :integer          default(1), not null
#  stackable    :boolean          not null
#  weight_unit  :string           default("kg"), not null
#  weight_value :decimal(20, 5)   default(0.0), not null
#  width_unit   :string           default("m"), not null
#  width_value  :decimal(20, 5)   default(0.0), not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  query_id     :uuid
#
# Indexes
#
#  index_journey_cargo_units_on_query_id  (query_id)
#
# Foreign Keys
#
#  fk_rails_...  (query_id => journey_queries.id) ON DELETE => cascade
#
