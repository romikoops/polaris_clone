module Trucking
  class TypeAvailability < ApplicationRecord
    TRUCK_TYPES = %w(default chassis side_lifter).freeze

    has_many :hub_availabilities
    validates :truck_type,
              uniqueness: {
                scope: %i(carriage load_type),
                message: lambda { |obj|
                  "#{obj.truck_type} taken for '#{carriage}-carriage', #{load_type}"
                }
              }

    def self.create_all!
      ::Shipment::LOAD_TYPES.each do |load_type|
        %w(pre on).each do |carriage|
          TRUCK_TYPES.each do |truck_type|
            find_or_create_by(
              load_type: load_type,
              carriage: carriage,
              truck_type: truck_type
            )
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
#  id         :uuid             not null, primary key
#  load_type  :string
#  carriage   :string
#  truck_type :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
