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

    def self.determine_schedules
      schedule_obj = {}
      shipment.itineraries.each do |itin|
        schedule_obj[itin.id] = itin.first_stop.layovers.where(et)
      end
    end

    def self.update_closing_date
      Layover.all.each do |l|
        unless l.itinerary
          l.destroy
          next
        end
        if l.closing_date.nil? && l.eta.nil?
          l.closing_date = l.etd - 4.days
          l.save!
        end
      end
    end
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
