# frozen_string_literal: true

module Legacy
  class Hub < ApplicationRecord
    include PgSearch::Model
    self.table_name = 'hubs'
    LOCAL_CHARGE_DATE_RANGE = (Date.today...2.days.from_now)

    has_paper_trail

    belongs_to :tenant, class_name: 'Legacy::Tenant'
    belongs_to :nexus, class_name: 'Legacy::Nexus'
    belongs_to :address, class_name: 'Legacy::Address'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    has_many :addons
    has_many :stops,    dependent: :destroy
    has_many :layovers, through: :stops
    has_many :hub_truckings
    has_many :local_charges
    has_many :customs_fees
    has_many :notes, dependent: :destroy
    has_many :hub_truck_type_availabilities
    has_many :truck_type_availabilities, through: :hub_truck_type_availabilities
    has_many :trucking_hub_availabilities, class_name: 'Trucking::HubAvailability'
    has_many :truckings, class_name: 'Trucking::Trucking'
    has_many :rates, -> { distinct }, through: :truckings
    belongs_to :mandatory_charge, optional: true
    has_one :country, through: :address, class_name: 'Legacy::Country'

    delegate :locode, to: :nexus

    pg_search_scope :name_search, against: %i(name), using: {
      tsearch: { prefix: true }
    }
    pg_search_scope :locode_search, against: %i(hub_code),
                                    associated_against: {
                                      nexus: %i(locode)
                                    },
                                    using: {
                                      tsearch: { prefix: true }
                                    }

    pg_search_scope :country_search,
                    associated_against: {
                      country: %i(name code)
                    },
                    using: {
                      tsearch: { prefix: true }
                    }
    scope :ordered_by, ->(col, desc = false) { order(col => desc.to_s == 'true' ? :desc : :asc) }

    pg_search_scope :list_search, against: %i(name), using: {
      tsearch: { prefix: true }
    }

    before_validation :set_point

    MOT_HUB_NAME = {
      'ocean' => 'Port',
      'air' => 'Airport',
      'rail' => 'Railway Station'
    }.freeze

    def lat_lng_string
      lat_lng_array.join(',')
    end

    def lat_lng_array
      [address.latitude, address.longitude]
    end

    def lng_lat_array
      lat_lng_array.reverse
    end

    def distance_to(loc)
      Geocoder::Calculations.distance_between([loc.latitude, loc.longitude], [address.latitude, address.longitude])
    end

    def point_wkt
      long = longitude || address.longitude
      lat = latitude || address.latitude

      "Point (#{long} #{lat})"
    end

    def set_point
      self.point = point_wkt
    end

    def earliest_expiration
      Legacy::LocalCharge.where(hub_id: id)
                         .for_dates(LOCAL_CHARGE_DATE_RANGE.first, LOCAL_CHARGE_DATE_RANGE.last)
                         .order(expiration_date: :asc).first&.expiration_date
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
#  hub_type            :string
#  latitude            :float
#  longitude           :float
#  name                :string
#  photo               :string
#  point               :geometry({:srid= geometry, 0
#  trucking_type       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  address_id          :integer
#  mandatory_charge_id :integer
#  nexus_id            :integer
#  sandbox_id          :uuid
#  tenant_id           :integer
#
# Indexes
#
#  index_hubs_on_point       (point) USING gist
#  index_hubs_on_sandbox_id  (sandbox_id)
#  index_hubs_on_tenant_id   (tenant_id)
#
