# frozen_string_literal: true

class BackfillTruckingLocationIdentifierWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform
    # Remove 2 invalid and old locations
    trucking_locations_without_identifier.where(data: [nil, "４７４５００"]).destroy_all

    # rubocop:disable Rails/SkipsModelValidations

    # Update location and string based postal codes
    trucking_locations_without_identifier.where(query: "postal_code").update_all(identifier: "postal_code")
    trucking_locations_without_identifier.where(query: "location").where.not(zipcode: nil).update_all(identifier: "postal_code")
    trucking_locations_without_identifier.where(query: "location").where("data ~ '^[0-9]{3}-[0-9]{4}$'").update_all(identifier: "postal_code")
    trucking_locations_without_identifier.where(query: "location").where("data ~ '^[0-9]{4,8}$'").update_all(identifier: "postal_code")
    trucking_locations_without_identifier.where(query: "location").where("data ~ '^[A-Z]{1,2}[0-9]{0,2}$'").update_all(identifier: "postal_code")

    # Update Distance locations
    trucking_locations_without_identifier.where(query: "distance").update_all(identifier: "distance")
    trucking_locations_without_identifier.where.not(distance: nil).update_all(identifier: "distance")

    # Update locode locations
    trucking_locations_without_identifier.where("data ~ '^[A-Z]{5}$'").update_all(identifier: "locode")

    # Update city locations
    Trucking::Location.where(identifier: nil, query: "location").update_all(identifier: "city")

    # rubocop:enable Rails/SkipsModelValidations
  end

  def trucking_locations_without_identifier
    @trucking_locations_without_identifier ||= Trucking::Location.where(identifier: nil)
  end
end
