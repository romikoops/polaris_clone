# frozen_string_literal: true

class Trip < Legacy::Trip
  has_paper_trail
  has_many :layovers, dependent: :destroy
  belongs_to :tenant_vehicle
  belongs_to :itinerary
  validates :itinerary_id, uniqueness: {
    scope: %i(start_date end_date closing_date tenant_vehicle_id load_type),
    message: 'Trip must be unique to add.'
  }

  def self.update_times
    trips = Trip.all
    trips.each do |t|
      layovers = t.layovers.order(:stop_index)
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
#  id                :bigint           not null, primary key
#  closing_date      :datetime
#  end_date          :datetime
#  load_type         :string
#  start_date        :datetime
#  vessel            :string
#  voyage_code       :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  itinerary_id      :integer
#  sandbox_id        :uuid
#  tenant_vehicle_id :integer
#
# Indexes
#
#  index_trips_on_closing_date       (closing_date)
#  index_trips_on_itinerary_id       (itinerary_id)
#  index_trips_on_sandbox_id         (sandbox_id)
#  index_trips_on_tenant_vehicle_id  (tenant_vehicle_id)
#
