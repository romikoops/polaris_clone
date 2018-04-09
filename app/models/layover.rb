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
  def self.update_closing_date
    Layover.all.each do |l|
      if !l.itinerary
        l.destroy
        next
      end
      if l.closing_date == nil && l.eta == nil
        l.closing_date = l.etd - 4.days
        l.save!
      end
    end
  end
end
