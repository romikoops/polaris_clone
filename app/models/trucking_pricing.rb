class TruckingPricing < ApplicationRecord
  has_many :shipments
  belongs_to :courier
  has_many :hub_truckings
  has_many :hubs, through: :hub_truckings
  extend MongoTools
  # Validations

  # Class methods
  def self.update_data
    TruckingPricing.all.each do |tp|
      tp.modifier = 'kg'
      tp.save!
    end
  end
end
