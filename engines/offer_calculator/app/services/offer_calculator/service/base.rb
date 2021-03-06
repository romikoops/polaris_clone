# frozen_string_literal: true

module OfferCalculator
  module Service
    class Base
      CARRIAGE_MAP = { "export" => "pre", "import" => "on" }.freeze

      def initialize(request:)
        @request = request
      end

      attr_reader :request

      delegate :organization, :client, :creator, to: :request

      private

      def scope
        @scope ||= OrganizationManager::ScopeService.new(
          target: client,
          organization: organization
        ).fetch
      end

      def check_for_fee_type(type:, results:)
        return check_for_freight(results: results) if type == :pricings

        fee_type_map = { truckings: "Carriage", local_charges: "Fees" }
        dynamic_local_charge_check = (type == :truckings || scope[:local_charges_required_with_trucking])

        %w[export import].each do |direction|
          carriage = CARRIAGE_MAP[direction]
          next unless request.carriage?(carriage: carriage) && dynamic_local_charge_check

          error = error_for_fee_type(
            results: results,
            switch_name: type == :truckings ? carriage.capitalize : direction.capitalize,
            fee_type_name: fee_type_map[type],
            direction: direction
          )
          raise error if error
        end
      end

      def error_for_fee_type(results:, switch_name:, fee_type_name:, direction:)
        if results.is_a?(ActiveRecord::Relation)
          return if case fee_type_name
                    when "Carriage"
                      results.exists?(carriage: CARRIAGE_MAP[direction])
                    else
                      results.exists?(direction: direction)
                    end

          OfferCalculator::Errors.const_get("No#{switch_name}#{fee_type_name}Found")
        elsif results.none? { |result| result.direction == direction }
          OfferCalculator::Errors.const_get("NoManipulated#{switch_name}#{fee_type_name}Found")
        end
      end

      def check_for_freight(results:)
        if results.is_a?(ActiveRecord::Relation)
          raise OfferCalculator::Errors::NoPricingsFound if results.empty?
        elsif results.empty?
          raise OfferCalculator::Errors::NoManipulatedPricingsFound
        end
      end
    end
  end
end
