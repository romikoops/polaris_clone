module Journey
  class LineItem < ApplicationRecord
    has_many :line_item_cargo_units, dependent: :destroy, inverse_of: :line_item
    has_many :cargo_units, through: :line_item_cargo_units
    belongs_to :line_item_set, inverse_of: :line_items
    belongs_to :route_section
    belongs_to :route_point
    has_one :result, through: :line_item_set
    
    monetize :total_cents
    monetize :unit_price_cents

    validates :wm_rate, presence: true
    validates :fee_code, presence: true
    validates :units, numericality: {greater_than: 0}
    validates :unit_price_cents, numericality: true
    validates :total_cents, numericality: true
  end
end

# == Schema Information
#
# Table name: journey_line_items
#
#  id                  :uuid             not null, primary key
#  description         :string           default(""), not null
#  fee_code            :string           not null
#  included            :boolean          default(FALSE)
#  note                :string           default(""), not null
#  optional            :boolean          default(FALSE)
#  order               :integer          not null
#  total_cents         :integer
#  total_currency      :string
#  unit_price_cents    :integer
#  unit_price_currency :string
#  units               :integer          not null
#  wm_rate             :decimal(, )      not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  line_item_set_id    :uuid
#  route_point_id      :uuid
#  route_section_id    :uuid
#
# Indexes
#
#  index_journey_line_items_on_line_item_set_id  (line_item_set_id)
#  index_journey_line_items_on_route_point_id    (route_point_id)
#  index_journey_line_items_on_route_section_id  (route_section_id)
#
# Foreign Keys
#
#  fk_rails_...  (line_item_set_id => journey_line_item_sets.id) ON DELETE => cascade
#  fk_rails_...  (route_point_id => journey_route_points.id) ON DELETE => cascade
#  fk_rails_...  (route_section_id => journey_route_sections.id) ON DELETE => cascade
#
