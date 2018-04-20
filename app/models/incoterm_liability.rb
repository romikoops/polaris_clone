class IncotermLiability < ApplicationRecord
  has_many :incoterms
  def self.create_all!
		[true, false].repeated_permutation(4).to_a.each do |values|
      attributes = IncotermLiability.given_attribute_names.zip(values).to_h
		  IncotermLiability.find_or_create_by!(attributes)
		end
	end
end
