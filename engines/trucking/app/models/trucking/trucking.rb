# frozen_string_literal: true

require 'will_paginate'

module Trucking
  class Trucking < ApplicationRecord
    LCL_TRUCK_TYPES = %w[default].freeze
    FCL_TRUCK_TYPES = %w[chassis side_lifter].freeze

    belongs_to :hub, class_name: 'Legacy::Hub'
    belongs_to :tenant_vehicle, class_name: 'Legacy::TenantVehicle'
    belongs_to :hub, class_name: 'Legacy::Hub'
    belongs_to :organization, class_name: 'Organizations::Organization'
    belongs_to :location, class_name: 'Trucking::Location'
    validates :hub_id, :location_id, presence: true
    belongs_to :group, class_name: 'Groups::Group', optional: true
    validates :hub_id,
              uniqueness: {
                scope: %i(
                  carriage
                  load_type
                  cargo_class
                  location_id
                  user_id
                  modifier
                  organization_id
                  truck_type
                  group_id
                  tenant_vehicle_id
                ),
                message: lambda { |obj, _msg|
                  "#{obj.truck_type} taken for '#{obj.carriage}-carriage', #{obj.load_type}"
                }
              }

    acts_as_paranoid

    def self.delete_existing_truckings(hub)
      where(hub_id: hub.id).destroy_all
    end

    def self.find_by_hub_id(hub_id:, options: {})
      find_by_hub_ids(hub_ids: [hub_id], options: options)
    end

    def self.find_by_hub_ids(hub_ids:, options: {})
      args = options.merge(hub_ids: hub_ids)
      result = ::Trucking::Queries::FindByHubIds.new(args.merge(klass: self)).perform
      result = result.paginate(page: options[:page], per_page: options[:per_page] || 20) if options[:paginate]

      result
    end

    # Instance Methods
    def nexus_id
      hub.nexus_id
    end

    def as_index_result
      {
        'truckingPricing' => as_json,
        'countryCode' => location&.country_code,
        'courier' => tenant_vehicle&.name
      }.merge(location_info)
    end

    def location_info
      return {} if location.nil?

      if location&.zipcode
        { 'zipCode' => location.zipcode }
      elsif location&.distance
        { 'distance' => location.distance }
      else
        { 'city' => location.city_name || location&.location&.name }
      end
    end
  end
end

# == Schema Information
#
# Table name: trucking_truckings
#
#  id                  :uuid             not null, primary key
#  cargo_class         :string
#  carriage            :string
#  cbm_ratio           :integer
#  deleted_at          :datetime
#  fees                :jsonb
#  identifier_modifier :string
#  load_meterage       :jsonb
#  load_type           :string
#  metadata            :jsonb
#  modifier            :string
#  rates               :jsonb
#  truck_type          :string
#  validity            :daterange
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  courier_id          :uuid
#  group_id            :uuid
#  hub_id              :integer
#  legacy_user_id      :integer
#  location_id         :uuid
#  organization_id     :uuid
#  parent_id           :uuid
#  rate_id             :uuid
#  sandbox_id          :uuid
#  tenant_id           :integer
#  tenant_vehicle_id   :integer
#  user_id             :uuid
#
# Indexes
#
#  index_truckings_on_cargo_class        (cargo_class)
#  index_truckings_on_carriage           (carriage)
#  index_truckings_on_deleted_at         (deleted_at)
#  index_truckings_on_group_id           (group_id)
#  index_truckings_on_hub_id             (hub_id)
#  index_truckings_on_load_type          (load_type)
#  index_truckings_on_location_id        (location_id)
#  index_truckings_on_organization_id    (organization_id)
#  index_truckings_on_tenant_vehicle_id  (tenant_vehicle_id)
#  index_truckings_on_validity           (validity) USING gist
#  trucking_upsert                       (hub_id,carriage,load_type,cargo_class,location_id,organization_id,truck_type,group_id,tenant_vehicle_id,validity) WHERE (deleted_at IS NULL) USING gist
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations_organizations.id)
#  fk_rails_...  (user_id => users_users.id)
#
