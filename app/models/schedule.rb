class Schedule < ApplicationRecord
  belongs_to :hub_route
  belongs_to :tenant
  belongs_to :vehicle, optional: true
  has_many :transport_categories, through: :vehicle

  def get_pickup_date(truck_seconds)
    self.etd - truck_seconds - 1.hour
  end

  def departure_date
    self.etd
  end
  
  def get_service_charges(direction)
    case direction
    when "import"
      hub = self.hub_route.endhub
    when "export"
      hub = self.hub_route.starthub 
    end
    sc = hub.service_charge
    # results = {}
    # sc.each_pair { |key, value|
    #   if value[:trade_direction] == direction
    #     results[key] = value
    #   end
    # }
    # return results
  end
  def assign_tenant
    
  end
end
