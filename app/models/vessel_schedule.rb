class VesselSchedule < ActiveRecord::Base
  def departure_date
    self.ets
  end

  def get_pickup_date(truck_seconds)
    self.ets - truck_seconds - 1.hour
  end
end
