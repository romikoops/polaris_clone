class Schedule < ApplicationRecord
  belongs_to :route
  belongs_to :starthub, class_name: "Hub"
  belongs_to :endhub, class_name: "Hub"

  def get_pickup_date(truck_seconds)
    self.etd - truck_seconds - 1.hour
  end

  def departure_date
    self.etd
  end
  
  def get_service_charges(direction)
    case direction
    when "import"
      hub = self.endhub
    when "export"
      hub = self.starthub
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
end
