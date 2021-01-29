module Journey
  class CargoUnit < ApplicationRecord
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

    validates :cargo_class, presence: true

    enum colli_type: {
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
