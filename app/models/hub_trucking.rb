class HubTrucking < ApplicationRecord
  has_many :trucking_pricings
  has_one :courier
end
