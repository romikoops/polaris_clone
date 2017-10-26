class Pricing < ActiveRecord::Base
  belongs_to :customer, class_name: "User"
  belongs_to :origin, class_name: "Location"
  belongs_to :destination, class_name: "Location"

  def self.all_open
    where(customer_id: nil)
  end

  def self.all_dedicated
    where.not(customer_id: nil)
  end

  def self.all_this_user(user)
    where(customer_id: user.id)    
  end

  def self.for_locations(origin, destination)
    starthub, starthub_dist = origin.closest_hub_with_distance
    endhub, endhub_dist = destination.closest_hub_with_distance
    if starthub_dist > 300 || endhub_dist > 300
      starthub = endhub = nil
    end
    where(origin: starthub, destination: endhub)
  end

  def lcl_price(cargo)
    cargo.weight_or_volume * lcl_m3_ton_price    
  end

  def fcl_price(container)
    case container.size_class    
    when "20_dc"
      fcl_20f_price
    when "40_dc"
      fcl_40f_price
    when "40_hq"
      fcl_40f_hq_price
    else
      raise "Unknown container size class!"
    end
  end
end
