class Nexus < ApplicationRecord
  has_many :hubs
  belongs_to :tenant

  def self.migrate_from_location
    hubs = Hub.all
    hubs.each do |hub|
      old_nexus = Location.find(hub.nexus_id)
      new_nexus = Nexus.find_by(name: old_nexus.name, tenant_id: hub.tenant_id)
      if !new_nexus
        new_nexus = Nexus.create!(
          name: old_nexus.name,
          latitude: old_nexus.latitude,
          latitude: old_nexus.latitude,
          longitude: old_nexus.longitude,
          photo: old_nexus.photo,
          tenant_id: hub.tenant_id
        )
      end
      if !new_nexus
        byebug
      end
      hub.nexus_id = new_nexus.id
      hub.save!
    end
  end
end
