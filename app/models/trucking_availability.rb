class TruckingAvailability < ApplicationRecord
  validates given_attribute_names.first.to_sym,
    uniqueness: {
      scope: given_attribute_names[1..-1],
      message: 'is a duplicate (all attributes match an existing record in the DB)'
    }

  def self.create_all!
    attr_names = TruckingAvailability.given_attribute_names

    [true, false].repeated_permutation(attr_names.size).each do |values|
      attributes = attr_names.zip(values).to_h
      TruckingAvailability.create!(attributes)
    end
  end

def self.find_trucking_availability(setting)
  load_types = [:container, :cargo_item]
  if (load_type = load_types.delete(setting.dig(:options, :load_type))).nil?      
    trucking_availability_attr = {
      container: true,
      cargo_item: true
    }
  else
    trucking_availability_attr = {
      load_type        => true,
      load_types.first => false
    }
  end

  trucking_availability = TruckingAvailability.find_by(trucking_availability_attr)
end

def self.hubs_to_update(tenant, setting)
  if setting.dig(:options, :upload_mode) == :hub_names
    tenant.hubs.where(name: setting[:values])
  else
    nexus_ids = setting[:values].map do |value|
      if (nexus = Location.find_by(location_type: "nexus", name: value)).nil?
        puts "(!) Warning: Tenant #{tenant.subdomain} does not have Nexus #{value}"
      else
        nexus.id
      end
    end
    tenant.hubs.where(nexus_id: nexus_ids)
  end
end

def self.update_hubs_trucking_availability!(tenant, trucking_availability_settings)
  if trucking_availability_settings.nil?
    puts "No trucking availability set for tenant #{tenant.subdomain}"
    return
  end

  trucking_availability_settings.each do |setting|
    trucking_availability = find_trucking_availability(setting)

    hubs_to_update(tenant, setting).each do |hub|
      hub.trucking_availability = trucking_availability
      hub.save!
    end
  end
end

end
