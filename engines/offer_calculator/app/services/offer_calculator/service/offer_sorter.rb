# frozen_string_literal: true

module OfferCalculator
  module Service
    class OfferSorter < Base
      EXPORT_SECTIONS = %w[trucking_pre export cargo].freeze
      TRUCKING_SECTIONS = %w[trucking_pre trucking_on].freeze

      OfferDefiningAttributes = Struct.new(:tenant_vehicle_id, :itinerary_id, :carrier_lock, :carrier_id, :origin_hub_id, :destination_hub_id, :cargo_classes, keyword_init: true)

      def self.sorted_offers(request:, charges:, schedules:)
        new(request: request, charges: charges, schedules: schedules).perform
      end

      def initialize(request:, charges:, schedules:)
        @charges = charges
        @schedules = schedules
        super(request: request)
      end

      def perform
        raise OfferCalculator::Errors::NoValidOffers if schedules_and_results.compact.empty?

        offers = group_schedules_and_results(schedules_and_results: schedules_and_results)
        offers.sort_by(&:total)
      end

      private

      attr_reader :request, :charges, :schedules

      def schedules_and_results
        schedules_groupings.flat_map do |grouping_keys, grouped_schedules|
          grouped_schedules_and_results(
            grouped_schedules: grouped_schedules,
            offer_attributes: OfferDefiningAttributes.new(**grouping_keys.merge(cargo_classes: request.cargo_classes))
          )
        end
      end

      def schedules_groupings
        schedules.sort_by!(&:etd).group_by do |schedule|
          {
            tenant_vehicle_id: schedule.tenant_vehicle_id,
            itinerary_id: schedule.itinerary_id,
            carrier_lock: schedule.carrier_lock,
            carrier_id: schedule.carrier_id,
            origin_hub_id: schedule.origin_hub_id,
            destination_hub_id: schedule.destination_hub_id
          }
        end
      end

      def group_schedules_and_results(schedules_and_results:)
        groupings = schedules_and_results.compact.group_by do |schedule_and_result|
          schedule_and_result[:selected_result]
        end

        groupings.each_with_object([]) do |(offer, grouped), results|
          results << OfferCalculator::Service::OfferCreators::Offer.new(
            offer: offer,
            schedules: grouped.pluck(:schedule),
            request: request
          )
        end
      end

      def grouped_schedules_and_results(grouped_schedules:, offer_attributes:)
        grouped_schedules
          .flat_map { |schedule| ScheduleCharges.new(offer_attributes: offer_attributes, charges: charges, schedule: schedule, request: request).results_with_schedule }
          .compact
      end

      class ScheduleCharges
        def initialize(charges:, offer_attributes:, schedule:, request:)
          @offer_attributes = offer_attributes
          @charges = charges
          @schedule = schedule
          @request = request
        end

        attr_reader :offer_attributes, :charges, :schedule, :request

        delegate :tenant_vehicle_id, :itinerary_id, :carrier_lock, :carrier_id, :origin_hub_id, :destination_hub_id, to: :offer_attributes

        delegate :scope, to: :request

        def results_with_schedule
          expanded_path_results.map do |selected_result|
            {
              schedule: schedule,
              selected_result: selected_result
            }
          end
        end

        def expanded_path_results
          return [] if path_results.values.any?(&:empty?)

          expand_path_results
        end

        def path_results
          @path_results ||= validity_logic_dates_for_sections.each_with_object({}) do |(section, date), hash|
            hash[section] = section_charges_for_date(date: date, section: section)
          end
        end

        def expand_path_results
          if path_results["trucking_pre"].blank? && path_results["trucking_on"].blank?
            [path_results]
          else
            trucking_permutations.map { |permutation| path_results.dup.merge(permutation) }
          end
        end

        def trucking_permutations
          options = %w[trucking_pre trucking_on].map do |carriage|
            path_results[carriage].present? ? path_results[carriage].group_by(&:tenant_vehicle_id).values : [nil]
          end

          options.first.product(options.second).map do |pre, on|
            { "trucking_pre" => pre, "trucking_on" => on }.compact
          end
        end

        def sections
          [
            request.pre_carriage? ? "trucking_pre" : nil,
            local_charge_required?(direction: "export") ? "export" : nil,
            "cargo",
            local_charge_required?(direction: "import") ? "import" : nil,
            request.on_carriage? ? "trucking_on" : nil
          ].compact
        end

        def validity_logic_dates_for_sections
          sections.each_with_object({}) do |section, hash|
            direction = EXPORT_SECTIONS.include?(section) ? "export" : "import"
            hash[section] = OfferCalculator::ValidityService.new(
              logic: scope.fetch("validity_logic"),
              direction: direction,
              booking_date: request.cargo_ready_date,
              schedules: [schedule]
            ).start_date
          end
        end

        def local_charge_required?(direction:)
          carriage = direction == "export" ? "pre" : "on"
          charges_enforced_by_carriage?(carriage: carriage) || charges_exists_and_should_be_included?(direction: direction, carriage: carriage)
        end

        def charges_enforced_by_carriage?(carriage:)
          request.carriage?(carriage: carriage) && local_charges_required_with_trucking?
        end

        def charges_exists_and_should_be_included?(direction:, carriage:)
          hub = Legacy::Hub.find(direction == "export" ? origin_hub_id : destination_hub_id)
          (hub.mandatory_charge.send("#{direction}_charges") || request.carriage?(carriage: carriage)) &&
            present_charge_sections.include?(direction)
        end

        def present_charge_sections
          @present_charge_sections ||= charges.map(&:section).uniq
        end

        def local_charges_required_with_trucking?
          scope[:local_charges_required_with_trucking]
        end

        def section_charges_for_date(date:, section:)
          charges.select do |charge|
            DateSectionCharge.new(
              charge: charge,
              section: section,
              date: date,
              offer_attributes: offer_attributes
            ).valid?
          end
        end
      end

      class DateSectionCharge
        def initialize(date:, section:, charge:, offer_attributes:)
          @date = date
          @section = section
          @charge = charge
          @offer_attributes = offer_attributes
        end

        attr_reader :date, :section, :charge, :offer_attributes

        delegate :tenant_vehicle_id, :itinerary_id, :carrier_id, :origin_hub_id, :destination_hub_id, :cargo_classes, to: :offer_attributes

        def valid?
          case section
          when "cargo"
            main_freight?
          when /port/
            local_charge?
          when /trucking/
            trucking?
          end
        end

        def main_freight?
          charge.section == section &&
            service_matches? &&
            validity_covers? &&
            cargo_class_matches? &&
            charge.itinerary_id == itinerary_id
        end

        def local_charge?
          charge.section == section &&
            hub_id_matches? &&
            service_matches? &&
            validity_covers? &&
            cargo_class_matches?
        end

        def hub_id
          %w[export trucking_pre].include?(section) ? origin_hub_id : destination_hub_id
        end

        def trucking?
          charge.section == section &&
            validity_covers? &&
            hub_id_matches? &&
            satisfies_carrier_lock_if_present?
        end

        def hub_id_matches?
          charge.hub_id == hub_id
        end

        def validity_covers?
          charge.validity.cover?(date)
        end

        def service_matches?
          charge.tenant_vehicle_id == tenant_vehicle_id
        end

        def cargo_class_matches?
          cargo_classes.include?(charge.cargo_class)
        end

        def satisfies_carrier_lock_if_present?
          return true if offer_attributes.carrier_lock.blank? && charge.carrier_lock.blank?

          main_freight_carrier_matches_charge_carrier?
        end

        def main_freight_carrier_matches_charge_carrier?
          charge.carrier_id == carrier_id
        end
      end
    end
  end
end
