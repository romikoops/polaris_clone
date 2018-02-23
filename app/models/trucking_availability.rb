class TruckingAvailability < ApplicationRecord
  validates given_attribute_names.first.to_sym,
    uniqueness: {
      scope: given_attribute_names[1..-1],
      message: 'is a duplicate (all attributes match an existing record in the DB)'
    }

  def self.create_all!
    attr_names = TruckingAvailability.given_attribute_names

    [true, false].repeated_permutation(attr_names.size).each do |values|
      attributes = attr_names.zip(values).to_h
      TruckingAvailability.create!(attributes)
    end
  end
end
