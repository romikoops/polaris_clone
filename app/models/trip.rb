# frozen_string_literal: true

class Trip < ApplicationRecord
  has_many :layovers, dependent: :destroy
  belongs_to :tenant_vehicle
  belongs_to :itinerary
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

  def self.clear_dupes
    Trip.all.each do |trip|
      t = trip.as_json
      t.delete('id')
      dupes = Trip.where(t)
      dupes.each do |d|
        d.destroy if d.id != trip.id
      end
    end
  end

  def vehicle
    tenant_vehicle.vehicle
  end
end
