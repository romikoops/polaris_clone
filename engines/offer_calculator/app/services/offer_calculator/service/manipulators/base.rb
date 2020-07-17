# frozen_string_literal: true

module OfferCalculator
  module Service
    module Manipulators
      class Base
        TRUCKING_BUFFER_DAYS = 2.days
        def self.results(association:, shipment:, schedules:)
          new(association: association, shipment: shipment, schedules: schedules).perform
        end

        def initialize(association:, schedules:, shipment:)
          @association = association
          @schedules = schedules
          @shipment = shipment
          @user = shipment.user
          @organization = shipment.organization
          @scope = ::OrganizationManager::ScopeService.new(target: @user, organization: @organization).fetch
        end

        def perform
          association.flat_map do |object|
            ::Pricings::Manipulator.new(
              type: margin_type(object: object),
              target: user,
              organization: organization,
              args: arguments(object: object)
            ).perform
          end
        end

        private

        attr_reader :association, :schedules, :shipment, :user, :organization, :scope

        def validity_service
          @validity_service ||= OfferCalculator::ValidityService.new(
            logic: scope.fetch("validity_logic"),
            schedules: schedules,
            direction: "export",
            booking_date: shipment.desired_start_date
          )
        end

        def pre_carriage_dates
          validity_service.parse_direction(direction: "export")
          {
            start_date: validity_service.start_date - TRUCKING_BUFFER_DAYS,
            end_date: validity_service.end_date
          }
        end

        def on_carriage_dates
          validity_service.parse_direction(direction: "import")
          {
            start_date: validity_service.start_date,
            end_date: validity_service.end_date + TRUCKING_BUFFER_DAYS
          }
        end

        def export_dates
          validity_service.parse_direction(direction: "export")
          dates_from_validity_service
        end

        def import_dates
          validity_service.parse_direction(direction: "import")
          dates_from_validity_service
        end

        def dates_from_validity_service
          {
            start_date: validity_service.start_date,
            end_date: validity_service.end_date
          }
        end
      end
    end
  end
end
