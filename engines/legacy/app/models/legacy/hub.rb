# frozen_string_literal: true

module Legacy
  class Hub < ApplicationRecord
    self.table_name = 'hubs'
    has_paper_trail
    belongs_to :tenant, class_name: 'Legacy::Tenant'
    belongs_to :nexus
    belongs_to :address, class_name: 'Legacy::Address'
    belongs_to :sandbox, class_name: 'Tenants::Sandbox', optional: true

    has_many :addons
    has_many :stops,    dependent: :destroy
    has_many :layovers, through: :stops
    has_many :hub_truckings
    has_many :trucking_pricings, -> { distinct }, through: :hub_truckings
    has_many :local_charges
    has_many :customs_fees
    has_many :notes, dependent: :destroy
    has_many :hub_truck_type_availabilities
    has_many :truck_type_availabilities, through: :hub_truck_type_availabilities
    has_many :trucking_hub_availabilities, class_name: 'Trucking::HubAvailability'
    has_many :truckings, class_name: 'Trucking::Trucking'
    has_many :rates, -> { distinct }, through: :truckings
    belongs_to :mandatory_charge, optional: true

    def point_wkt
      "Point (#{address.longitude} #{address.latitude})"
    end
  end
end

# == Schema Information
#
# Table name: hubs
#
#  id                  :bigint(8)        not null, primary key
#  tenant_id           :integer
#  address_id          :integer
#  name                :string
#  hub_type            :string
#  latitude            :float
#  longitude           :float
#  hub_status          :string           default("active")
#  hub_code            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  trucking_type       :string
#  photo               :string
#  nexus_id            :integer
#  mandatory_charge_id :integer
#  sandbox_id          :uuid
#
