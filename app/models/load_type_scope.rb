# frozen_string_literal: true

class LoadTypeScope < ApplicationRecord
  def self.create_all!
    [true, false].repeated_permutation(2).to_a.each do |values|
      attributes = LoadTypeScope.given_attribute_names.zip(values).to_h
      LoadTypeScope.create!(attributes)
    end
  end
end
