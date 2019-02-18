class Hub < ApplicationRecord
  belongs_to :tenant
  belongs_to :nexus
  belongs_to :address

  has_many :addons
  has_many :stops,    dependent: :destroy
  has_many :layovers, through: :stops
  has_many :trucking_truckings
  has_many :trucking_ratess, -> { distinct }, through: :trucking_truckings
  has_many :trucking_hub_availabilities
  has_many :trucking_type_availabilities, through: :trucking_hub_availabilities
end