class TruckingAvailability < ApplicationRecord
    def self.create_all!
    [true, false].repeated_permutation(6).to_a.each do |values|
      attributes = TruckingAvailability.given_attribute_names.zip(values).to_h
      p attributes
      # TruckingAvailability.create!(attributes)
    end
  end

  def self.given_attribute_names
    attribute_names - %w(id created_at updated_at)
  end
end
