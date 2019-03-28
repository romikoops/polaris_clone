# frozen_string_literal: true

module Trucking
  class TypeAvailability < ApplicationRecord
    enum query_method: { distance: 1, zipcode: 2, location: 3, not_set: 0 }

    TRUCK_TYPES = %w(default chassis side_lifter).freeze
    QUERY_METHODS = %i(distance zipcode location not_set).freeze

    has_many :hub_availabilities
    validates :truck_type,
              uniqueness: {
                scope: %i(carriage load_type query_method),
                message: lambda { |obj, _msg|
                  "#{obj.truck_type} taken for '#{obj.carriage}-carriage', #{obj.load_type}"
                }
              }

    def self.create_all!
      Legacy::Shipment::LOAD_TYPES.each do |load_type|
        %w(pre on).each do |carriage|
          TRUCK_TYPES.each do |truck_type|
            QUERY_METHODS.each do |enum|
              find_or_create_by(
                load_type: load_type,
                carriage: carriage,
                truck_type: truck_type,
                query_method: enum
              )
            end
          end
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: trucking_type_availabilities
#
#  id           :uuid             not null, primary key
#  load_type    :string
#  carriage     :string
#  truck_type   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  query_method :integer
#
