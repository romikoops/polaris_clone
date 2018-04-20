class IncotermScope < ApplicationRecord
  has_many :incoterms
  def self.create_all!
		[true, false].repeated_permutation(2).to_a.each do |values|
      attributes = IncotermScope.given_attribute_names.zip(values).to_h
		  IncotermScope.find_or_create_by!(attributes)
		end
	end
end
