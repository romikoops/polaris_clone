# frozen_string_literal: true

class Trip < ApplicationRecord
  has_paper_trail
  has_many :layovers, dependent: :destroy
  belongs_to :tenant_vehicle
  belongs_to :itinerary
  validates :itinerary_id, uniqueness: {
    scope: %i(start_date end_date closing_date tenant_vehicle_id load_type),
    message: 'Trip must be unique to add.'
  }

  scope :lastday_today, -> { where('closing_date > ?', Date.today) }
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

  def later_trips
    itinerary.trips
             .where(tenant_vehicle: tenant_vehicle)
             .where('start_date > ?', start_date)
             .order(start_date: :asc)
             .limit(5)
  end

  def last_trips
    itinerary.trips
             .where(tenant_vehicle: tenant_vehicle)
             .order(start_date: :desc)
             .limit(5)
  end

  def earlier_trips(min_date: Date.today + 5.days)
    itinerary.trips
             .where(tenant_vehicle: tenant_vehicle)
             .where('start_date < ? AND start_date > ?', start_date, min_date)
             .order(start_date: :desc)
             .limit(5)
  end

  def earliest_trips(min_date: Date.today + 5.days)
    itinerary.trips
             .where(tenant_vehicle: tenant_vehicle)
             .where('start_date > ?', min_date)
             .order(start_date: :desc)
             .limit(5)
  end
end

# == Schema Information
#
# Table name: trips
#
#  id                :bigint(8)        not null, primary key
#  itinerary_id      :integer
#  start_date        :datetime
#  end_date          :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  voyage_code       :string
#  vessel            :string
#  tenant_vehicle_id :integer
#  closing_date      :datetime
#  load_type         :string
#
