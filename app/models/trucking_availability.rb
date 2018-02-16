class TruckingAvailability < ApplicationRecord
  def self.create_all!
    attr_names = TruckingAvailability.given_attribute_names

    [true, false].repeated_permutation(attr_names.size).each do |values|
      attributes = attr_names.zip(values).to_h
      TruckingAvailability.create!(attributes)
    end
  end

  def self.given_attribute_names
    attribute_names - %w(id created_at updated_at)
  end
end
