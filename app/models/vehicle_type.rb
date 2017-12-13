class VehicleType < ApplicationRecord
  has_many :transport_types
  has_many :schedules
  include PricingTools
   def test
    r = get_hub_route_user_pricings(1, 2)
    byebug
  end
end
