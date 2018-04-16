class PricingDetail < ApplicationRecord
  belongs_to :tenant
  belongs_to :priceable, polymorphic: true

end

