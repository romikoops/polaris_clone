# frozen_string_literal: true

module Routing
  class Location < ApplicationRecord
    has_many :terminals, class_name: 'Routing::Terminal'
  end
end

# == Schema Information
#
# Table name: routing_locations
#
#  id           :uuid             not null, primary key
#  locode       :string
#  center       :geometry({:srid= geometry, 0
#  bounds       :geometry({:srid= geometry, 0
#  name         :string
#  country_code :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
