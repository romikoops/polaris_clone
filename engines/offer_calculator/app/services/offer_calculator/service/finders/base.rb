# frozen_string_literal: true

module OfferCalculator
  module Service
    module Finders
      class Base
        def self.prices(shipment:, quotation:, schedules:)
          new(shipment: shipment, quotation: quotation, schedules: schedules).perform
        end

        def initialize(shipment:, quotation:, schedules:)
          @user = shipment.user
          @organization = shipment.organization
          @quotation = quotation
          @schedules = schedules
          @shipment = shipment
          @scope = ::OrganizationManager::ScopeService.new(target: @user, organization: @organization).fetch
          @hierarchy = ::OrganizationManager::HierarchyService.new(target: @user).fetch.select { |target|
            target.is_a?(Groups::Group)
          }
          raise OfferCalculator::Errors::NoValidSchedules if schedules.empty?
        end

        private

        attr_reader :schedules, :shipment, :organization, :hierarchy, :scope, :quotation

        def cargo_classes
          @cargo_classes ||= shipment.cargo_classes
        end

        def end_date
          @end_date ||= schedules.last.eta
        end

        def start_date
          @start_date ||= schedules.first.closing_date
        end

        def valid_ids(collection:, association:, filter_column:, select:)
          collection.select do |id|
            association.where("#{filter_column} = #{id}")
              .select(select.to_sym)
              .distinct.count == cargo_classes.count
          end
        end
      end
    end
  end
end
