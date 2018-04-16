class Pricing < ApplicationRecord
  belongs_to :itinerary
  belongs_to :tenant
  belongs_to :transport_category
  belongs_to :user, optional: true
  has_many :pricing_details, as: :priceable, dependent: :destroy
  has_many :pricing_exceptions, dependent: :destroy
end

