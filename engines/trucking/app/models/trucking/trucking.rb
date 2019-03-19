# frozen_string_literal: true
require 'will_paginate'

module Trucking
  class Trucking < ApplicationRecord
    belongs_to :rate, class_name: 'Trucking::Rate', optional: true
    belongs_to :hub, class_name: 'Legacy::Hub'
    belongs_to :tenant, class_name: 'Legacy::Tenant'
    belongs_to :location, class_name: 'Trucking::Location'
    belongs_to :courier, class_name: 'Trucking::Courier'
    validates :hub_id, :location_id, presence: true

    def self.delete_existing_truckings(hub)
      where(hub_id: hub.id).destroy_all
    end

    def self.find_by_filter(args = {})
      ::Trucking::Queries::FindTrucking.new(args.merge(klass: self)).perform
    end

    def self.find_by_hub_id(hub_id, options = {})
      args = options.merge(hub_ids: hub_id)
      result = ::Trucking::Queries::FindByHubIds.new(args.merge(klass: self)).perform
      result.paginate(page: options[:page], per_page: options[:per_page] || 20)
    end

    def self.find_by_hub_ids(hub_ids, options = {})
      find_by_hub_id(hub_ids, options)
    end

    # Instance Methods
    def nexus_id
      hub.nexus_id
    end

    def as_index_result
      {
        'truckingPricing' =>  as_json,
        'countryCode' => location&.country_code
      }.merge(location_info)
    end

    def location_info
      return {} if location.nil?

      if location&.zipcode
        { 'zipCode' => location.zipcode }
      elsif location&.distance
        { 'distance' => location.distance }
      else
        { 'city' => location&.location&.name }
      end
    end

  end
end

# == Schema Information
#
# Table name: trucking_truckings
#
#  id                  :uuid             not null, primary key
#  hub_id              :integer
#  location_id         :uuid
#  rate_id             :uuid
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  load_meterage       :jsonb
#  cbm_ratio           :integer
#  modifier            :string
#  tenant_id           :integer
#  rates               :jsonb
#  fees                :jsonb
#  identifier_modifier :string
#  load_type           :string
#  cargo_class         :string
#  carriage            :string
#  courier_id          :uuid
#  truck_type          :string
#  user_id             :integer
#
