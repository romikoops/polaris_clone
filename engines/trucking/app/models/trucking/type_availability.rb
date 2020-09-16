# frozen_string_literal: true

module Trucking
  class TypeAvailability < ApplicationRecord
    enum query_method: {distance: 1, zipcode: 2, location: 3, not_set: 0}

    TRUCK_TYPES = %w[default chassis side_lifter].freeze
    QUERY_METHODS = %i[distance zipcode location not_set].freeze

    has_many :hub_availabilities
    belongs_to :country, class_name: "Legacy::Country", optional: true
    validates :truck_type,
      uniqueness: {
        scope: %i[carriage load_type query_method country_id],
        message: lambda { |obj, _msg|
          "#{obj.truck_type} taken for '#{obj.carriage}-carriage', #{obj.load_type} in #{obj.country.name}"
        }
      }
  end
end

# == Schema Information
#
# Table name: trucking_type_availabilities
#
#  id           :uuid             not null, primary key
#  carriage     :string
#  deleted_at   :datetime
#  load_type    :string
#  query_method :integer
#  truck_type   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  country_id   :bigint
#  sandbox_id   :uuid
#
# Indexes
#
#  index_trucking_type_availabilities_on_country_id    (country_id)
#  index_trucking_type_availabilities_on_deleted_at    (deleted_at)
#  index_trucking_type_availabilities_on_load_type     (load_type)
#  index_trucking_type_availabilities_on_query_method  (query_method)
#  index_trucking_type_availabilities_on_sandbox_id    (sandbox_id)
#  index_trucking_type_availabilities_on_truck_type    (truck_type)
#  trucking_type_availabilities_unique_index           (carriage,load_type,country_id,truck_type,query_method) UNIQUE WHERE (deleted_at IS NULL)
#
