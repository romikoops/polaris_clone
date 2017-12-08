class ServiceCharge < ApplicationRecord
  belongs_to :hub
  
  # Class methods
  def self.for_export
    where(trade_direction: "export")
  end

  def self.for_import
    where(trade_direction: "import")
  end

  # Instance methods
  def total_price(trade_direction, pre_carriage, on_carriage)
    price = 0
    
    case trade_direction
    when "import"

      if pre_carriage
        pre_carriage_service_charge = self.import_drop_off_charge
      else
        pre_carriage_service_charge = 0
      end
      price += pre_carriage_service_charge

      if on_carriage
        on_carriage_service_charge = self.import_drop_off_charge
      else
        on_carriage_service_charge = 0
      end

      price += on_carriage_service_charge
      price += self.handling_documentation + self.equipment_management_charges + self.add_imo_position # hazardous_cargo charge?

    when "export"

      if pre_carriage
        pre_carriage_service_charge = self.export_pickup_charge
      else
        pre_carriage_service_charge = 0
      end
      price += pre_carriage_service_charge

      if on_carriage
        on_carriage_service_charge = self.export_pickup_charge
      else
        on_carriage_service_charge = 0
      end

      price += on_carriage_service_charge
      price += self.handling_documentation + self.carrier_security_fee + self.verified_gross_mass + self.add_imo_position # hazardous_cargo charge?

    else
      raise "Unknown trade direction"
    end

    price
  end

  def calc_export_charge(cargo)
    cbm = (cargo.dimension_x * cargo.dimension_y * cargo.dimension_z) / 1000000
    kg = cargo.payload_in_kg
    fixed_keys = ["isps" ,"exp_declaration" ,"extra_hs_code" ,"doc_fee" ,"liner_service_fee" ,"vgm_fee"]
    result = {}
    
    terminal_charge_tmp = self[:terminal_handling_cbm]["value"] * cbm
    if self[:terminal_handling_min]["value"] > terminal_charge_tmp
      result[:terminal_charge] = {value: self[:terminal_handling_min]["value"], currency: self[:terminal_handling_cbm]["currency"]}
    else
      result[:terminal_charge] = {value: terminal_charge_tmp, currency: self[:terminal_handling_cbm]["currency"]}
    end
    lcl_charge_tmp = self[:lcl_service_cbm]["value"] * cbm
    if self[:lcl_service_min]["value"] > lcl_charge_tmp
      result[:lcl_charge] = {value: self[:lcl_service_min]["value"], currency: self[:lcl_service_cbm]["currency"]}
    else
      result[:lcl_charge] = {value: lcl_charge_tmp, currency: self[:lcl_service_cbm]["currency"]}
    end
    fixed_keys.each do |key|
      result[key] = {value: self[key]["value"], currency: self[key]["currency"]}
    end
    result
  end

  def calc_import_charge(cargo)
    cbm = (cargo.dimension_x * cargo.dimension_y * cargo.dimension_z) / 1000000
    kg = cargo.payload_in_kg
    fixed_keys = ["documentation_fee" ,"handling_fee" ,"customs_clearance" ,"cfs_terminal_charges"]
    result = {}
    
    fixed_keys.each do |key|
      result[key] = {value: self[key]["value"], currency: self[key]["currency"]}
    end
    
    # currency_values = {}
    # result.each_pair do |key, charge|
    #   if !currency_values[charge[:currency]]
    #     currency_values[charge[:currency]] = charge[:value]
    #   else
    #     currency_values[charge[:currency]] += charge[:value]
    #   end
    # end
    # result[:totals] = currency_values
    result
  end
end
