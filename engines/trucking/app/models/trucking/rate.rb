# frozen_string_literal: true
require 'will_paginate/array'

module Trucking
  class Rate < ApplicationRecord
    has_paper_trail
    has_many :shipments
    belongs_to :scope, class_name: '::Trucking::Scope'
    delegate :courier, to: :scope
    belongs_to :tenant, class_name: 'Legacy::Tenant'
    has_many :truckings, dependent: :destroy, class_name: '::Trucking::Trucking'
    has_many :hubs, class_name: 'Legacy::Hub', through: :truckings
    has_many :locations, class_name: '::Trucking::Location', through: :truckings

    SCOPING_ATTRIBUTE_NAMES = %i(load_type cargo_class carriage courier_id truck_type).freeze

    SCOPING_ATTRIBUTE_NAMES.each do |scoping_attribute_name|
      delegate scoping_attribute_name, to: :scope
    end

    # Validations

    # Class methods

    def self.delete_existing_truckings(hub)
      hub.rates.delete_all
      hub.truckings.delete_all
    end

    def self.find_by_filter(args = {})
      ::Trucking::Queries::FindByFilter.new(args.merge(klass: self)).perform
    end

    def self.find_by_hub_id(hub_id, options = {})
      find_by_hub_ids([hub_id], options)
    end

    def self.find_by_hub_ids(hub_ids, options = {})
      query = ::Trucking::Queries::FindByHubIds.new(hub_ids: hub_ids, klass: self)
      query.perform
      if options[:paginate]
        raw_result = query.result.paginate(page: options[:page], per_page: 20)
        result = query.deserialize_results(raw_result)
      else
        result = query.deserialized_result
      end

      result
    end

    # Instance Methods
    def nexus_id
      ActiveRecord::Base.connection.execute("
        SELECT nexuses.id FROM nexuses
        JOIN hubs ON hubs.nexus_id = nexuses.id
        JOIN trucking_truckings ON trucking_truckings.hub_id = hubs.id
        JOIN trucking_rates ON trucking_truckings.rate_id = trucking_rates.id
        WHERE trucking_rates.id = '#{id}'
        LIMIT 1
      ").values.flatten.first
    end

    def hub_id
      ActiveRecord::Base.connection.execute("
        SELECT hubs.id FROM hubs
        JOIN trucking_truckings ON trucking_truckings.hub_id = hubs.id
        JOIN trucking_rates ON trucking_truckings.rate_id = trucking_rates.id
        WHERE trucking_rates.id = '#{id}'
        LIMIT 1
      ").values.flatten.first
    end

    def as_options_json(options = {})
      as_json(options.reverse_merge(methods: SCOPING_ATTRIBUTE_NAMES))
    end
  end
end

# == Schema Information
#
# Table name: trucking_rates
#
#  id                  :uuid             not null, primary key
#  load_meterage       :jsonb
#  cbm_ratio           :integer
#  modifier            :string
#  tenant_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  rates               :jsonb
#  fees                :jsonb
#  identifier_modifier :string
#  scope_id            :uuid
#
