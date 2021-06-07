# frozen_string_literal: true

class CleanNexusTableWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  DedupingFailed = Class.new(StandardError)

  def perform
    add_locode_to_locodeless
    duplicates = Legacy::Nexus.where.not(locode: nil).where("(select count(*) from nexuses inr where inr.locode = nexuses.locode AND inr.organization_id = nexuses.organization_id) > 1")
    locode_organization_pairs = duplicates.select(:locode, :organization_id).distinct
    total locode_organization_pairs.length

    locode_organization_pairs.each_with_index do |record, index|
      nexuses = Legacy::Nexus.where(locode: record.locode, organization_id: record.organization_id).sort_by { |nexus| -Legacy::Itinerary.where(origin_hub: nexus.hubs).or(Legacy::Itinerary.where(destination_hub: nexus.hubs)).count }
      valid_nexus = nexuses.shift
      invalid_nexuses = nexuses
      ActiveRecord::Base.transaction do
        # rubocop:disable Rails/SkipsModelValidations

        Legacy::Shipment.where(origin_nexus: invalid_nexuses).update_all(origin_nexus_id: valid_nexus.id)
        Legacy::Shipment.where(destination_nexus: invalid_nexuses).update_all(destination_nexus_id: valid_nexus.id)

        Quotations::Quotation.where(origin_nexus: invalid_nexuses).update_all(origin_nexus_id: valid_nexus.id)
        Quotations::Quotation.where(destination_nexus: invalid_nexuses).update_all(destination_nexus_id: valid_nexus.id)

        Legacy::Hub.where(nexus: invalid_nexuses).update_all(nexus_id: valid_nexus.id)
        # rubocop:enable Rails/SkipsModelValidations
        invalid_nexuses.map(&:destroy!)
      end
      at index + 1, "Nexus #{[valid_nexus.name, valid_nexus.locode].join(' - ')} #{index + 1} / #{locode_organization_pairs.length} done"
    end

    Legacy::Nexus.where(locode: nil).destroy_all
    raise DedupingFailed unless Legacy::Nexus.where.not(locode: nil).where("(select count(*) from nexuses inr where inr.locode = nexuses.locode AND inr.organization_id = nexuses.organization_id) > 1").count.zero?
  end

  def add_locode_to_locodeless
    Legacy::Nexus.where(locode: nil).find_each do |nexus|
      next if nexus.latitude.nil? || nexus.longitude.nil?

      locode = ActiveRecord::Base.connection.execute("
        SELECT locode FROM nexuses
        WHERE locode IS NOT NULL
        ORDER BY st_SetSrid(st_MakePoint(longitude, latitude), 4326) <-> ST_GeomFromText ('POINT(#{nexus.longitude} #{nexus.latitude} )', 4326)
        LIMIT 1;
      ").to_a.first["locode"]
      nexus.update(locode: locode)
    end
  end
end
