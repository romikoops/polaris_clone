class TruckingAvailability < ApplicationRecord
  has_many :nexus_trucking_availabilities, dependent: :destroy

  validates given_attribute_names.first.to_sym,
    uniqueness: {
      scope: given_attribute_names[1..-1],
      message: 'is a duplicate (all attributes match an existing record in the DB)'
    }

  def self.create_all!
    [true, false].repeated_permutation(given_attribute_names.size).each do |values|
      create!(given_attribute_names.zip(values).to_h)
    end
  end

  def self.update_hubs_trucking_availability!(tenant, trucking_availability_settings)
    if trucking_availability_settings.nil?
      puts "No trucking availability set for tenant #{tenant.subdomain}"
      return
    end

    trucking_availability_settings.each do |setting|
      hubs_to_update(tenant, setting).each do |hub|
        hub.trucking_availability = find_trucking_availability(setting, hub.trucking_availability)
        hub.save!
      end
    end
  end

  private

  def self.find_trucking_availability(setting, previous_trucking_availability = nil)
    if (load_type = setting.dig(:options, :load_type)).nil?      
      trucking_availability_attr = { container: true, cargo_item: true }
    else
      trucking_availability_attr =
        previous_trucking_availability.try(:given_attributes) ||
        { container: false, cargo_item: false }

      trucking_availability_attr[load_type] = true
    end

    find_by(trucking_availability_attr)
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
end
