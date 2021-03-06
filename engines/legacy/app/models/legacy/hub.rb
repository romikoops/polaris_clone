# frozen_string_literal: true

module Legacy
  class Hub < ApplicationRecord
    include PgSearch::Model
    self.table_name = "hubs"

    has_paper_trail

    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :nexus, class_name: "Legacy::Nexus"
    belongs_to :mandatory_charge, optional: true
    belongs_to :address, class_name: "Legacy::Address"
    has_one :country, through: :nexus, class_name: "Legacy::Country"
    has_many :addons, dependent: :destroy
    has_many :as_origin_itineraries, class_name: "Legacy::Itinerary",
                                     foreign_key: "origin_hub_id",
                                     dependent: :destroy
    has_many :as_destination_itineraries, class_name: "Legacy::Itinerary",
                                          foreign_key: "destination_hub_id",
                                          dependent: :destroy
    has_many :stops, dependent: :destroy
    has_many :layovers, through: :stops
    has_many :local_charges, class_name: "Legacy::LocalCharge", dependent: :destroy
    has_many :customs_fees, dependent: :destroy
    has_many :notes, dependent: :destroy
    has_many :trucking_hub_availabilities, class_name: "Trucking::HubAvailability", dependent: :destroy
    has_many :truckings, class_name: "Trucking::Trucking", dependent: :destroy
    has_many :rates, -> { distinct }, through: :truckings

    delegate :locode, to: :nexus

    pg_search_scope :name_search, against: %i[name], using: {
      tsearch: { prefix: true }
    }
    pg_search_scope :locode_search, against: %i[hub_code],
                                    associated_against: {
                                      nexus: %i[locode]
                                    },
                                    using: {
                                      tsearch: { prefix: true }
                                    }

    pg_search_scope :country_search,
      associated_against: {
        country: %i[name code]
      },
      using: {
        tsearch: { prefix: true }
      }
    scope :ordered_by, ->(col, desc = false) { order(col => desc.to_s == "true" ? :desc : :asc) }

    pg_search_scope :list_search, against: %i[name], using: {
      tsearch: { prefix: true }
    }
    validates :hub_code, format: { with: /\A[A-Z]{2}[A-Z\d]{3}\z/, message: "Invalid Locode" }, allow_nil: true

    before_validation :set_point

    accepts_nested_attributes_for :address

    MOT_HUB_NAME = {
      "ocean" => "Port",
      "air" => "Airport",
      "rail" => "Railway Station",
      "truck" => "Depot"
    }.freeze

    def lat_lng_string
      lat_lng_array.join(",")
    end

    def lat_lng_array
      [latitude, longitude]
    end

    def lng_lat_array
      lat_lng_array.reverse
    end

    def distance_to(loc)
      Geocoder::Calculations.distance_between([loc.latitude, loc.longitude], [latitude, longitude])
    end

    def geo_point
      geo_point_from_address || geo_point_from_lat_lon
    end

    def set_point
      self.point ||= geo_point
    end

    def earliest_expiration
      Legacy::LocalCharge.where(hub_id: id)
        .for_dates(Time.zone.today, 2.days.from_now)
        .order(expiration_date: :asc)
        .first
                         &.expiration_date
    end

    private

    def geo_point_from_address
      cached_address = address
      cached_address.geo_point if cached_address.present?
    end

    def geo_point_from_lat_lon
      latitude && longitude && RGeo::Geos.factory(srid: 4326).point(longitude, latitude)
    end
  end
end

# == Schema Information
#
# Table name: hubs
#
#  id                  :bigint           not null, primary key
#  free_out            :boolean          default(FALSE)
#  hub_code            :string
#  hub_status          :string           default("active")
#  hub_type            :enum
#  latitude            :float
#  longitude           :float
#  name                :string
#  photo               :string
#  point               :geometry         geometry, 4326
#  terminal            :string
#  terminal_code       :string
#  trucking_type       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  address_id          :integer
#  mandatory_charge_id :integer
#  nexus_id            :integer
#  organization_id     :uuid
#  sandbox_id          :uuid
#  tenant_id           :integer
#
# Indexes
#
#  hub_terminal_upsert            (nexus_id,name,hub_type,organization_id,terminal) UNIQUE
#  hub_upsert                     (nexus_id,hub_type,name,organization_id) UNIQUE WHERE (terminal IS NULL)
#  index_hubs_on_organization_id  (organization_id)
#  index_hubs_on_point            (point) USING gist
#  index_hubs_on_sandbox_id       (sandbox_id)
#  index_hubs_on_tenant_id        (tenant_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#
