class Pricing < ApplicationRecord
  extend PricingTools
  validates :tenant_id, presence: true

  belongs_to :route

  def self.get_open
    find_by(customer_id: nil)
  end

  def self.get_dedicated(user)
    find_by(customer_id: user.id)
  end


  def self.lcl_price(cargo, pathKey, user)
    pricing = get_user_price(pathKey, user)
    min = pricing["wm"]["min"] * pricing["wm"]["rate"]
    tmp_val = cargo.weight_or_volume * pricing["wm"]["rate"]
    if tmp_val > min
      return {value: tmp_val, currency: pricing["wm"]["currency"]}
    else
      return {value: min, currency: pricing["wm"]["currency"]}
    end
  end

  def self.fcl_price(container, pathKey, user)
    pricing = get_user_price(pathKey, user)
    return {value: pricing["wm"]["rate"], currency: pricing["wm"]["currency"]}
  end
end
