module Legacy
  class Hub < ApplicationRecord
    self.table_name = 'hubs'
    has_paper_trail
    belongs_to :tenant, class_name: 'Legacy::Tenant'
    belongs_to :nexus
    belongs_to :address, class_name: 'Legacy::Address'

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
  end
end
