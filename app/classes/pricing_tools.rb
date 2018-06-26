# frozen_string_literal: true

module PricingTools
  include CurrencyTools

  def get_user_price(itinerary_id, transport_category_id, user, shipment_date)
    pricing = Pricing.find_by(itinerary_id: itinerary_id, user_id: user.id, transport_category_id: transport_category_id)
    pricing ||= Pricing.find_by(itinerary_id: itinerary_id, transport_category_id: transport_category_id)

    return if pricing.nil?

    pricing_exceptions = pricing.pricing_exceptions.where("effective_date <= ? AND expiration_date >= ?", shipment_date, shipment_date)
    pricing_details =
      if pricing_exceptions.any?
        pricing_exceptions.first.pricing_details
      else
        pricing.pricing_details
      end

    final_pricing = pricing_details.map(&:as_json).reduce({}) { |hash, merged_hash| merged_hash.deep_merge(hash) }

    final_pricing.with_indifferent_access
  end

  def transport_category(cargo_unit, schedule)
    schedule.trip.tenant_vehicle.vehicle.transport_categories.find_by(
      name:              "any",
      cargo_class:       cargo_unit.try(:size_class) || "lcl",
      mode_of_transport: schedule.mode_of_transport
    )
  end

  def determine_local_charges(hub, load_type, cargos, direction, mot, tenant_vehicle_id, counterpart_hub_id, user)
    cargo_hash =  cargos.each_with_object(Hash.new(0)) do |cargo_unit, return_h|
      weight = if cargo_unit.is_a?(CargoItem)
                 cargo_unit.payload_in_kg * (cargo_unit.try(:quantity) || 1)
               elsif cargo_unit.is_a?(AggregatedCargo)
                cargo_unit.weight * (cargo_unit.try(:quantity) || 1)
               else
                 cargo_unit.payload_in_kg * (cargo_unit.quantity || 1)
               end
      return_h[:quantity] += cargo_unit.quantity unless cargo_unit.try(:quantity).nil?
      return_h[:volume]   += (cargo_unit.try(:volume) || 1) * (cargo_unit.try(:quantity)|| 1) || 0

      return_h[:weight]   += (cargo_unit.try(:weight) || weight)
    end

    lt = load_type == "cargo_item" || load_type == "lcl" ? "lcl" : cargos[0].size_class
    charge = hub.local_charges.find_by(direction: direction, load_type: lt, mode_of_transport: mot, tenant_vehicle_id: tenant_vehicle_id, counterpart_hub_id: counterpart_hub_id)
    charge = charge || hub.local_charges.find_by(direction: direction, load_type: lt, mode_of_transport: mot, tenant_vehicle_id: tenant_vehicle_id)
    return {} if charge.nil?
    totals = { "total" => {} }

    charge.fees.each do |k, fee|
      totals[k]             ||= { "value" => 0, "currency" => fee["currency"] }
      totals[k]["currency"] ||= fee["currency"]
      totals[k]["value"] += fee_value(fee, cargo_hash)
    end
    converted = sum_and_convert_cargo(totals, user.currency)
    totals["total"] = { value: converted, currency: user.currency }

    totals
  end

  def calc_customs_fees(charge, cargos, _load_type, user, mot)
    cargo_hash = cargos.each_with_object(Hash.new(0)) do |cargo_unit, return_h|
      weight = if cargo_unit.is_a?(CargoItem) || cargo_unit.is_a?(AggregatedCargo)
                 cargo_unit.calc_chargeable_weight(mot) * (cargo_unit.quantity || 1)
               else
                 cargo_unit.payload_in_kg * (cargo_unit.quantity || 1)
               end
      return_h[:quantity] += cargo_unit.quantity unless cargo_unit.quantity.nil?
      return_h[:volume]          += cargo_unit.try(:volume) * (cargo_unit.quantity || 1) || 0
      return_h[:weight]          += (cargo_unit.try(:weight) || weight)
    end

    return {} if charge.nil?
    totals = { "total" => {} }
    charge.each do |k, fee|
      totals[k]             ||= { "value" => 0, "currency" => fee["currency"] }
      totals[k]["currency"] ||= fee["currency"]

      totals[k]["value"] += fee_value(fee, cargo_hash)
    end

    converted = sum_and_convert_cargo(totals, user.currency)
    totals["total"] = { value: converted, currency: user.currency }
    totals
  end

  def determine_cargo_item_price(cargo, schedule, user, _quantity, shipment_date, mot)
    transport_category_id = transport_category(cargo, schedule)
    pricing = get_user_price(schedule.trip.itinerary.id, transport_category_id, user, shipment_date)
    
    return nil if pricing.nil?
    totals = { "total" => {} }

    pricing.keys.each do |k|
      fee = pricing[k].clone

      totals[k]             ||= { "value" => 0, "currency" => fee["currency"] }
      totals[k]["currency"] ||= fee["currency"]

      totals[k]["value"] +=
        if fee["hw_rate_basis"]
          heavy_weight_fee_value(fee, cargo)
        else
          fee_value(fee, get_cargo_hash(cargo, mot))
        end
    end
    

    converted = sum_and_convert_cargo(totals, user.currency)
    cargo.try(:unit_price=, value: converted, currency: user.currency)
    totals["total"] = { value: converted, currency: user.currency }

    totals
  end

  def determine_container_price(container, schedule, user, _quantity, shipment_date, mot)
    transport_category_id = transport_category(container, schedule)
    pricing = get_user_price(schedule.trip.itinerary.id, transport_category_id, user, shipment_date)
    return if pricing.nil?
    totals = { "total" => {} }

    pricing.each do |k, fee|
      totals[k]             ||= { "value" => 0, "currency" => fee["currency"] }
      totals[k]["currency"] ||= fee["currency"]

      totals[k]["value"] += fee_value(fee, get_cargo_hash(container, mot))
    end

    cargo_rate_value = sum_and_convert_cargo(totals, user.currency)
    return if cargo_rate_value.nil? || cargo_rate_value == 0
    container.unit_price = { value: cargo_rate_value, currency: user.currency }
    totals["total"] = { value: cargo_rate_value, currency: user.currency }
    totals
  end

  def get_tenant_pricings(tenant_id)
    Tenant.find(tenant_id).pricings.map(&:as_json)
  end

  def get_tenant_pricings_by_mot(tenant_id, mot)
    Tenant.find(tenant_id).itineraries.where(mode_of_transport: mot).flat_map { |it| it.pricings.map(&:as_json) }
  end

  def get_tenant_pricings_hash(tenant_id)
    pricings = get_tenant_pricings(tenant_id)
    pricings.each_with_object({}) do |pricing, return_h|
      return_h[pricing["id"]] = pricing
    end
  end

  def get_itinerary_pricings_array(itinerary_id, tenant_id)
    itinerary = Itinerary.find_by(id: itinerary_id, tenant_id: tenant_id)
    itinerary.pricings.map(&:as_json)
  end

  def get_user_pricings(id)
    results = {}
    User.find(id).pricings.each do |pricing|
      unless results[pricing.itinerary_id]
        results[pricing.itinerary_id] = { itinerary: pricing.itinerary.as_options_json, pricings: [] }
      end
      results[pricing.itinerary_id][:pricings] << { pricing: pricing, transport_category: pricing.transport_category }
    end
    results
  end

  def get_itinerary_pricings(itinerary_id)
    Itinerary.find(itinerary_id).pricings.map(&:as_json)
  end

  def update_pricing(id, data)
    Pricing.find(id).update(data)
  end

  def get_itinerary_pricings_hash(itinerary_id)
    itinerary = Itinerary.find(itinerary_id)
    itinerary.pricings.each_with_object({}) do |pricing, return_h|
      pricing_key = "#{itinerary.first_stop.id}_#{itinerary.last_stop.id}_#{pricing.transport_category_id}"
      open = "#{pricing_key}_#{pricing.tenant_id}"
      return_h[pricing_key] = { id: pricing_key, open: open }
    end
  end

  def pricing_delete(id)
    Pricing.destroy(id)
  end

  def handle_range_fare(fee, cargo_hash)
    weight_kg = cargo_hash[:weight]
    min = fee["min"] || 0

    case fee["rate_basis"]
    when "PER_KG_RANGE"
      fee_range = fee["range"].find do |range|
        weight_kg >= range["min"] && weight_kg <= range["max"]
      end || fee["range"].max_by { |x| x["max"] }
      value = fee_range.nil? ? 0 : fee_range["rate"] * weight_kg

      return [value, min].max
    when "PER_CONTAINER_RANGE"
      fee_range = fee["range"].find do |range|
        weight_kg >= range["min"] && weight_kg <= range["max"]
      end
      value = fee_range.nil? ? 0 : fee_range["rate"]
      return [value, min].max
    when "PER_UNIT_RANGE"
      fee_range = fee["range"].find do |range|
        weight_kg >= range["min"] && weight_kg <= range["max"]
      end
      value = fee_range.nil? ? 0 : fee_range["rate"]
      return [value, min].max
    end

    nil
  end

  def heavy_weight_fee_value(fee, cargo)
    weight_kg = cargo.try(:weight) || cargo.try(:payload_in_kg)
    quantity  = cargo.try(:quantity) || 1
    cbm = cargo.volume
    ton = weight_kg / 1000

    if fee["hw_threshold"]
      ratio = weight_kg / cbm

      if ratio > fee["hw_threshold"]
        rate_value = [cbm, ton].max * quantity * fee["rate"].to_i
        return [rate_value, fee["min"]].max
      end

      return 0
    elsif fee["range"]
      fee_range = fee["range"].find do |range|
        weight_kg >= range["min"] && weight_kg <= range["max"]
      end

      return fee_range.nil? ? 0 : fee_range["rate"] * quantity
    end

    nil
  end

  def fee_value(fee, cargo_hash)
    case fee["rate_basis"]
    when "PER_SHIPMENT", "PER_BILL"
      fee["value"].to_d
    when "PER_ITEM", "PER_CONTAINER"
      (fee["value"] || fee["rate"]).to_d * cargo_hash[:quantity]
    when "PER_CBM"
      fee["value"].to_d * cargo_hash[:volume]
    when "PER_KG"
      val = fee["value"].to_d * cargo_hash[:weight]
      min = fee["min"] || 0
      [val, min].max
    when "PER_CBM_TON"
      cbm = cargo_hash[:volume] * fee["cbm"]
      ton = (cargo_hash[:weight] / 1000) * fee["ton"]
      min = fee["min"] || 0

      [cbm, ton, min].max
    when "PER_TON"
      ton = (cargo_hash[:weight] / 1000) * fee["ton"]
      min = fee["min"] || 0
      byebug
      [ton, min].max
    when "PER_WM"
      cbm = cargo_hash[:volume] * (fee["value"] || fee["rate"])
      ton = (cargo_hash[:weight] / 1000) * (fee["value"] || fee["rate"])
      min = fee["min"] || 0
      [cbm, ton, min].max
    when /RANGE/
      handle_range_fare(fee, cargo_hash)
    end
  end

  def get_cargo_hash(cargo, mot)
    if cargo.is_a? Container
      {
        volume:   (cargo.try(:volume) || 1) * (cargo.try(:quantity) || 1),
        weight:   (cargo.try(:weight) || cargo.payload_in_kg) * (cargo.try(:quantity) || 1),
        quantity: cargo.try(:quantity) || 1
      }
    else
      chargeable_weight = cargo.calc_chargeable_weight(mot)

      {
        volume:   (cargo.try(:volume) || 1) * (cargo.try(:quantity) || 1),
        weight:   (cargo.try(:weight) || chargeable_weight) * (cargo.try(:quantity) || 1),
        quantity: cargo.try(:quantity) || 1
      }
    end
  end
end
