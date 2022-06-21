# frozen_string_literal: true

module OfferCalculator
  module Service
    module Charges
      class Generator
        def self.results(association:, request:, schedules:)
          new(association: association, request: request, schedules: schedules).perform
        end

        def initialize(association:, schedules:, request:)
          @association = association
          @schedules = schedules
          @request = request
          @client = request.client
          @organization = request.organization
          @scope = ::OrganizationManager::ScopeService.new(target: @client, organization: @organization).fetch
        end

        def perform
          OfferCalculator::Service::Charges::Calculator.new(
            charges: built_charges
          ).perform
        end

        private

        attr_reader :association, :schedules, :request, :client, :organization, :scope

        def built_charges
          @built_charges ||= OfferCalculator::Service::Charges::Builder.new(request: request, relation: association, period: validity_service.period).perform
        end

        def validity_service
          @validity_service ||= OfferCalculator::ValidityService.new(
            logic: scope.fetch("validity_logic"),
            schedules: schedules,
            direction: "export",
            booking_date: request.cargo_ready_date
          )
        end
      end
    end
  end
end
