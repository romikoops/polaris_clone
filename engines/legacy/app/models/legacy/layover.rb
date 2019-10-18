# frozen_string_literal: true

module Legacy
  class Layover < ApplicationRecord
    self.table_name = 'layovers'
    belongs_to :stop, class_name: 'Legacy::Stop'
    belongs_to :itinerary, class_name: 'Legacy::Itinerary'
    belongs_to :trip, class_name: 'Legacy::Trip'
    delegate :hub_id, :hub, to: :stop
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    scope :hub_id, ->(hub_id) { joins(:stop).where('stops.hub_id': hub_id) }

  end
end

# == Schema Information
#
# Table name: layovers
#
#  id           :bigint           not null, primary key
#  stop_id      :integer
#  eta          :datetime
#  etd          :datetime
#  stop_index   :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  itinerary_id :integer
#  trip_id      :integer
#  closing_date :datetime
#  sandbox_id   :uuid
#
