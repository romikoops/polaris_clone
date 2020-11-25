module Journey
  class LineItemCargoUnit < ApplicationRecord
    belongs_to :line_item
    belongs_to :cargo_unit
  end
end

# == Schema Information
#
# Table name: journey_line_item_cargo_units
#
#  id            :uuid             not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  cargo_unit_id :uuid
#  line_item_id  :uuid
#
# Indexes
#
#  index_journey_line_item_cargo_units_on_cargo_unit_id  (cargo_unit_id)
#  index_journey_line_item_cargo_units_on_line_item_id   (line_item_id)
#
# Foreign Keys
#
#  fk_rails_...  (cargo_unit_id => journey_cargo_units.id) ON DELETE => cascade
#  fk_rails_...  (line_item_id => journey_line_items.id) ON DELETE => cascade
#
