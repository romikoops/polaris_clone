# frozen_string_literal: true

module Legacy
  class Layover < ApplicationRecord
    self.table_name = "layovers"
    belongs_to :stop, class_name: "Legacy::Stop"
    belongs_to :itinerary, class_name: "Legacy::Itinerary"
    belongs_to :trip, class_name: "Legacy::Trip"
    delegate :hub_id, :hub, to: :stop

    scope :hub_id, ->(hub_id) { joins(:stop).where('stops.hub_id': hub_id) }
  end
end

# == Schema Information
#
# Table name: layovers
#
#  id           :bigint           not null, primary key
#  closing_date :datetime
#  eta          :datetime
#  etd          :datetime
#  stop_index   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  itinerary_id :integer
#  sandbox_id   :uuid
#  stop_id      :integer
#  trip_id      :integer
#
# Indexes
#
#  index_layovers_on_sandbox_id  (sandbox_id)
#  index_layovers_on_stop_id     (stop_id)
#
