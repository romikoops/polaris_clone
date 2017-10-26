class TrainSchedule < ActiveRecord::Base
  def departure_date
    self.etd
  end

  def get_pickup_date(truck_seconds)
    self.etd - truck_seconds - 1.hour
  end
end
