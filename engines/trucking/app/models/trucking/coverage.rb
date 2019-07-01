# frozen_string_literal: true

module Trucking
  class Coverage < ApplicationRecord
    belongs_to :hub, class_name: 'Legacy::Hub'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true
    has_many :truckings, through: :hub

    before_validation :generate_bounds
    after_save :write_bounds_to_s3

    def geojson
      RGeo::GeoJSON.encode(RGeo::GeoJSON::Feature.new(bounds))
    end

    def write_bounds_to_disk
      File.open(Rails.root.join('tmp', "#{hub.name}_coverage.geojson"), 'w') { |f| f.puts geojson.to_json }
    end

    def write_bounds_to_s3
      s_3 = Aws::S3::Client.new
      f = Tempfile.new("#{hub.id}_coverage")
      f.write geojson.to_json
      f.rewind
      f.close
      s_3.put_object(
        bucket: 'assets.itsmycargo.com',
        key: "data/#{hub.tenant.subdomain}/trucking_coverage/#{hub.name}_coverage.geojson",
        body: f,
        content_type: 'application/json', acl: 'private'
      )
    end

    private

    def generate_bounds
      self.bounds = Locations::Location
                    .where(
                      id: Location.joins(:truckings).where(trucking_truckings: { hub_id: hub.id }).select(:location_id)
                    )
                    .pluck('ST_Collect(bounds)').first
    rescue => e
      puts e
    end
  end
end



# == Schema Information
#
# Table name: trucking_coverages
#
#  id         :uuid             not null, primary key
#  hub_id     :integer
#  bounds     :geometry({:srid= geometry, 0
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
