class TruckingPricing < ApplicationRecord
  has_many :shipments

  # Validations

  # Class methods
  def self.all_quotes
    # Has to be changed
    TruckingPricing.all
  end

  # Instance methods
  def trucker_info
    info = []
    info << "trucker_info deprecated..!"
  end

  def has_steptable?
    steptable != nil
  end

  def price_fcl(km, container_count)
    self.price_per_km * km * container_count
  end

  def price_lcl(km, cargo_item)
    self.price_per_km * km * 1 ########
  end

  def total_price(km, weight_in_tons, volume_in_cm3, units)
    trucking_rules_price_machine = TruckingPriceRulesMachine.new(self, km, weight_in_tons, volume_in_cm3, units)

    total_price = trucking_rules_price_machine.total_price
    total_price.round(2)
  end

  def self.calc_final_price(destination, cargo_item, km, hub)
    if hub && hub.trucking_type
      case hub.trucking_type
      when 'zipcode'
        return TruckingPricing.calc_by_zipcode(destination, cargo_item.payload_in_kg, km)
      when 'city'
        return TruckingPricing.calc_by_city(hub, destination, km, cargo_item)
      end
    else
      return {value: 1.25 * km, currency: "EUR"}
    end
  end

  def self.calc_by_zipcode(destination, weight, km)
    zc = destination.get_zip_code
    zip_int = zc.gsub!(" ", "").to_i
    tps = TruckingPricing.find_by("? < upper_zip AND ? > lower_zip", zip_int, zip_int)

    @selected_rate
    if tps
      tps.rate_table.each do |rate|
        if weight >= rate["min"] && weight <= rate["max"]
          @selected_rate = rate
        end
      end

      price = (weight / 100) * @selected_rate["value"]
      if price > @selected_rate["min_value"]
        return {value:price, currency: tps.currency}
      else
        return {value: @selected_rate["min_value"], currency: tps.currency}
      end
    else
      return {value: 1.25 * km, currency: "EUR"}
    end
  end

  def self.calc_by_city(hub, destination, km, cargo_item)
    cbm = (cargo_item.dimension_x * cargo_item.dimension_y * cargo_item.dimension_z) / 1000
    hub.trucking_pricings.each do |tps|
      if destination.geocoded_address.include?(tps.city) && destination.geocoded_address.include?(tps.province)
        @trucking_pricing = tps
      end
    end
    # tps = TruckingPricing.find_by("city LIKE ?", "%#{destination.city}%")
    @selected_rate
    if @trucking_pricing
      @trucking_pricing.rate_table.each do |rate|
        if weight >= rate["min"] && weight <= rate["max"]
          @selected_rate = rate
        end
      end
      price = ((weight) * @selected_rate["value"]) + @selected_rate["pickup_fee"] + @selected_rate["delivery_fee"]
      if price > @selected_rate["min_value"]
        return {value:price, currency: @trucking_pricing.currency}
      else
        return {value: @selected_rate["min_value"], currency: @trucking_pricing.currency}
      end
    else
      return {value: 1.25 * km, currency: "EUR"}
    end
  end
end
