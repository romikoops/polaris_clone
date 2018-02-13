class Layover < ApplicationRecord
  belongs_to :stop
  belongs_to :itinerary
  belongs_to :trip
  def self.determine_schedules()
    schedule_obj = {}
    shipment.itineraries.each do |itin|
      schedule_obj[itin.id] = itin.first_stop.layovers.where(et)
    end
    
  end
end
