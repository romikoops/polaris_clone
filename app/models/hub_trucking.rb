class HubTrucking < ApplicationRecord
  belongs_to :trucking_pricing
  belongs_to :hub
  belongs_to :trucking_destination
  has_one :courier
end
