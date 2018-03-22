class TruckingPricing < ApplicationRecord
  has_many :shipments
  belongs_to :courier
  has_many :hub_trucking
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
