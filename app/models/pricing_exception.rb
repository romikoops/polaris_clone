class PricingException < ApplicationRecord
  belongs_to :tenant
  belongs_to :pricing
  has_many :pricing_details, as: :priceable, dependent: :destroy
end

