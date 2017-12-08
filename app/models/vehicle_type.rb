class VehicleType < ApplicationRecord
  has_many :transport_types
  has_many :schedules
  include DynamoTools
  def test
    scheds = Schedule.all
    scheds.each do |s|
      hr = s.hub_route
      hrKey = "#{hr.starthub_id}-#{hr.endhub_id}"
      s.hub_route_key = hrKey
      s.save
    end
  end
end
