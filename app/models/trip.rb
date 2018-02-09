class Trip < ApplicationRecord
  has_many :layovers
  belongs_to :vehicle
  def self.update_times
    trips = Trip.all
    trips.each do |t|
      layovers = t.layovers.order(:stop_index)
      p layovers.first.etd
      p layovers.last.eta
      t.end_date = layovers.last.eta
      t.save!
    end
  end
end
