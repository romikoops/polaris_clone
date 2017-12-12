class Pricing < ApplicationRecord
  include DynamoTools
  validates :tenant_id, presence: true

  belongs_to :route

  def self.get_open
    find_by(customer_id: nil)
  end

  def self.get_dedicated(user)
    find_by(customer_id: user.id)
  end
  def get_user_price(pathKey, user)
    priceObj = get_item('pathPricings', 'pathKey', pathKey).item
    
    if priceObj["user_#{user.id}"]
      priceKey = priceObj["user_#{user.id}"]
    else
      priceKey = priceObj["user_open"]
    end
    
    priceHash = get_item('pricings', 'price_id', priceKey).item
    
    return priceHash
  end

  def self.lcl_price(cargo, pathKey, user)
    pricing = Pricing.new.get_user_price(pathKey, user)
    # cargo.weight_or_volume * lcl_m3_ton_price
    
    min = pricing["wm"]["min"] * pricing["wm"]["rate"]
    tmp_val = cargo.weight_or_volume * pricing["wm"]["rate"]
    if tmp_val > min
      return {value: tmp_val, currency: pricing["wm"]["currency"]}
    else
      return {value: min, currency: pricing["wm"]["currency"]}
    end
  end

  def self.fcl_price(container, pathKey, user)
    pricing = Pricing.new.get_user_price(pathKey, user)
    # case container.size_class    
    # when "20_dc"
    #   container_rate = self.fcl_20f
    # when "40_dc"
    #   container_rate = self.fcl_40f
    # when "40_hq"
    #   container_rate = self.fcl_40f_hq
    # else
    #   raise "Unknown container size class!"
    # end
    return {value: pricing["wm"]["rate"], currency: pricing["wm"]["currency"]}
  end
end
