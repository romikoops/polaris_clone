# frozen_string_literal: true

class IncotermScope < ApplicationRecord
  has_many :incoterms
  def self.create_all!
    [true, false].repeated_permutation(2).to_a.each do |values|
      attributes = IncotermScope.given_attribute_names.zip(values).to_h
      IncotermScope.find_or_create_by!(attributes)
    end
  end
end

# == Schema Information
#
# Table name: incoterm_scopes
#
#  id                :bigint(8)        not null, primary key
#  pre_carriage      :boolean
#  on_carriage       :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  mode_of_transport :boolean
#
