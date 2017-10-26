class ServiceCharge < ActiveRecord::Base
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
end