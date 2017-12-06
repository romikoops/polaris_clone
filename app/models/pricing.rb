class Pricing < ApplicationRecord
  validates :tenant_id, presence: true

  belongs_to :route

  def self.get_open
    find_by(customer_id: nil)
  end

  def self.get_dedicated(user)
    find_by(customer_id: user.id)
  end

  def lcl_price(cargo)
    # cargo.weight_or_volume * lcl_m3_ton_price    
    min = self.lcl["wm_min"] * self.lcl["wm_rate"]
    tmp_val = cargo.weight_or_volume * self.lcl["wm_rate"]
    if tmp_val > min
      return {value: tmp_val, currency: self.lcl["currency"]}
    else
      return {value: min, currency: self.lcl["currency"]}
    end
  end

  def fcl_price(container)
    case container.size_class    
    when "20_dc"
      container_rate = self.fcl_20f
    when "40_dc"
      container_rate = self.fcl_40f
    when "40_hq"
      container_rate = self.fcl_40f_hq
    else
      raise "Unknown container size class!"
    end
    return {value: container_rate["rate"], currency: container_rate["currency"]}
  end

  def route_h
    route_h = route.attributes
    route_h[:modes_of_transport] = route.modes_of_transport
    route_h[:next_departure]     = route.next_departure
    route_h
  end

  def self.private(user = nil)
    user ? Pricing.where(customer_id: user.id) : Pricing.where.not(customer_id: nil)
  end

  def self.public
    Pricing.where(customer_id: nil)
  end
end
