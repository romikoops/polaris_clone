# frozen_string_literal: true

module OfferCalculator
  module Service
    module Finders
      class Base
        def self.prices(request:, schedules:)
          new(request: request, schedules: schedules).perform
        end

        def initialize(request:, schedules:)
          @request = request
          @schedules = schedules

          raise OfferCalculator::Errors::NoValidSchedules if schedules.empty?
        end

        private

        attr_reader :schedules, :request

        delegate :client, :organization, :cargo_classes, :load_type, to: :request

        def scope
          @scope ||= ::OrganizationManager::ScopeService.new(target: client, organization: organization).fetch
        end

        def hierarchy
          @hierarchy ||= OrganizationManager::GroupsService.new(
            target: client, organization: organization, exclude_default: exclude_default
          ).fetch
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
