module Journey
  class CargoUnit < ApplicationRecord
    has_many :commodity_infos
    has_many :line_item_cargo_units
    has_many :line_items, through: :line_item_cargo_units
    belongs_to :query

    measured_weight :weight
    measured_length :width, :length, :height

    validates :quantity, presence: true, numericality: {greater_than: 0}
    validates :weight, measured: {units: :kg, greater_than: 0}
    validates :width, :length, :height, measured: {units: :m}
    validates :width, :length, :height, measured: {greater_than: 0}

    validates :cargo_class, presence: true
  end
end

# == Schema Information
#
# Table name: journey_cargo_units
#
#  id           :uuid             not null, primary key
#  cargo_class  :string           not null
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
