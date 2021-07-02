# frozen_string_literal: true

class CleanLocationsLocationsTableWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker
  FailedCleaning = Class.new(StandardError)

  def perform
    nil_locations = Locations::Location.where(name: nil, country_code: "")
    nil_locations.where(id: Locations::Name.select(:location_id)).find_each do |nil_location|
      location_name = Locations::Name.find_by(location: nil_location)
      next if location_name.country_code.blank?

      nil_location.update(name: location_name.name, country_code: location_name.country_code.downcase)
    end

    Locations::Location.where(name: nil, country_code: "").destroy_all # Not attached to any Trucking::Locations and cant update the name
    ActiveRecord::Base.connection.execute("DELETE FROM locations_locations WHERE deleted_at IS NOT NULL;") # Permanently delete the Locations we arent using

    raise FailedCleaning unless duplicates.empty?
  end

  def duplicates
    Locations::Location.where("(select count(*) from locations_locations inr where inr.name = locations_locations.name AND inr.country_code = locations_locations.country_code AND inr.deleted_at = locations_locations.deleted_at) > 1")
  end
end
