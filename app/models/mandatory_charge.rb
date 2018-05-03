class MandatoryCharge < ApplicationRecord
  has_many :hubs
   def self.create_all!
		[true, false].repeated_permutation(4).to_a.each do |values|
      attributes = MandatoryCharge.given_attribute_names.zip(values).to_h
		  MandatoryCharge.find_or_create_by!(attributes)
		end
	end
end
