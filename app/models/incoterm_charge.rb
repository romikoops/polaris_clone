# frozen_string_literal: true

class IncotermCharge < ApplicationRecord
  has_many :incoterms
  def self.create_all!
    [true, false].repeated_permutation(4).to_a.each do |values|
      attributes = IncotermCharge.given_attribute_names.zip(values).to_h
      IncotermCharge.find_or_create_by!(attributes)
    end
  end
end
