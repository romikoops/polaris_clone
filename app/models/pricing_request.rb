class PricingRequest < ApplicationRecord
  belongs_to :user
  belongs_to :tenant
  belongs_to :pricing
end
