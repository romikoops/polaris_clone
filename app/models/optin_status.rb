class OptinStatus < ApplicationRecord
  has_many :users
  def self.create_all!
    [true, false].repeated_permutation(3).to_a.each do |values|
      attributes = OptinStatus.given_attribute_names.zip(values).to_h
		  OptinStatus.find_or_create_by!(attributes)
		end
  end
end
