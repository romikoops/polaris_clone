class TruckingPricingScope < ApplicationRecord
  has_many :trucking_pricings
  belongs_to :courier
end
