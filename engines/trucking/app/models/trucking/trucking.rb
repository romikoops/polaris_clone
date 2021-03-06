# frozen_string_literal: true

require "will_paginate"

module Trucking
  class Trucking < ApplicationRecord
    LCL_TRUCK_TYPES = %w[default].freeze
    FCL_TRUCK_TYPES = %w[chassis side_lifter].freeze

    belongs_to :hub, class_name: "Legacy::Hub"
    belongs_to :tenant_vehicle, class_name: "Legacy::TenantVehicle"
    belongs_to :hub, class_name: "Legacy::Hub"
    belongs_to :organization, class_name: "Organizations::Organization"
    belongs_to :location, class_name: "Trucking::Location"
    validates :hub_id, :location_id, presence: true
    belongs_to :group, class_name: "Groups::Group", optional: true
    validates :hub_id,
      uniqueness: {
        scope: %i[
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
          validity
        ],
        message: lambda { |obj, _msg|
          "#{obj.truck_type} taken for '#{obj.carriage}-carriage', #{obj.load_type}"
        }
      }
    scope :current, -> { where("validity @> CURRENT_DATE") }
    MODIFIERS = %w[cbm_kg unit km unit_in_kg unit cbm wm kg].freeze

    acts_as_paranoid

    # Instance Methods
    delegate :nexus_id, to: :hub
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
#  secondary           :string
#  target              :string
#  truck_type          :string
#  validity            :daterange
#  zone                :string
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
#
