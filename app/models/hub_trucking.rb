class HubTrucking < ApplicationRecord
  belongs_to :trucking_pricing
  has_one :courier
end
