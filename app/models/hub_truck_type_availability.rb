class HubTruckTypeAvailability < ApplicationRecord
  belongs_to :hub
  belongs_to :truck_type_availability
end
