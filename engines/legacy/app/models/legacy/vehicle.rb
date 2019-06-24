# frozen_string_literal: true

module Legacy
  class Vehicle < ApplicationRecord
    self.table_name = 'vehicles'
    has_many :transport_categories
    has_many :itineraries
    has_many :tenant_vehicles
  end
end

# == Schema Information
#
# Table name: vehicles
#
#  id                :bigint(8)        not null, primary key
#  name              :string
#  mode_of_transport :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
