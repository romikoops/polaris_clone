# frozen_string_literal: true

module OfferCalculator
  module Service
    class OfferSorter < Base
      EXPORT_SECTIONS = %w[trucking_pre export cargo].freeze
      TRUCKING_SECTIONS = %w[trucking_pre trucking_on].freeze

      def self.sorted_offers(shipment:, quotation:, charges:, schedules:)
        new(shipment: shipment, quotation: quotation, charges: charges, schedules: schedules).perform
      end

      def initialize(shipment:, quotation:, charges:, schedules:)
        @charges = charges
        @schedules = schedules
        super(shipment: shipment, quotation: quotation)
      end

      def perform
        schedules_and_results = schedules_groupings(schedules: schedules).flat_map { |grouping_keys, grouping|
          sections = required_sections(grouping_keys: grouping_keys)
          grouping.flat_map do |schedule|
            selected_results = select_results_for_dates(
              dates: section_dates(schedule: schedule, sections: sections),
              grouping_keys: grouping_keys
            )
            next if selected_results.empty?

            selected_results.map do |selected_result|
              {
                schedule: schedule,
                selected_result: selected_result
              }
            end
          end
        }

        raise OfferCalculator::Errors::NoValidOffers if schedules_and_results.compact.empty?

        group_schedules_and_results(schedules_and_results: schedules_and_results)
      end

      private

      attr_reader :shipment, :quotation, :charges, :schedules

      def group_schedules_and_results(schedules_and_results:)
        groupings = schedules_and_results.compact.group_by { |schedule_and_result|
          schedule_and_result[:selected_result]
        }

        groupings.each_with_object([]) do |(offer, grouped), results|
          results << OfferCalculator::Service::OfferCreators::Offer.new(
            offer: offer,
            schedules: grouped.pluck(:schedule),
            shipment: shipment,
            quotation: quotation
          )
        end
      end

      def select_results_for_dates(dates:, grouping_keys:)
        path_results = dates.each_with_object({}) { |(section, date), hash|
          hash[section] = result_matcher(
            section: section,
            date: date,
            grouping_keys: grouping_keys
          )
        }
        return [] if path_results.values.any?(&:empty?)

        expand_path_results(path_results: path_results, grouping_keys: grouping_keys)
      end

      def expand_path_results(path_results:, grouping_keys:)
        return [path_results] if path_results["trucking_pre"].blank? && path_results["trucking_on"].blank?

        if grouping_keys[:carrier_lock].present?

          return locked_trucking_permutations(path_results: path_results, carrier_id: grouping_keys[:carrier_id])
        end

        trucking_permutations(path_results: path_results).map do |pre, on|
          path_results.dup.tap do |permutation|
            permutation["trucking_pre"] = pre if pre.present?
            permutation["trucking_on"] = on if on.present?
          end
        end
      end

      def locked_trucking_permutations(path_results:, carrier_id:)
        path_results["trucking_pre"]&.select! { |charge| charge.carrier_id == carrier_id }
        path_results["trucking_on"]&.select! { |charge| charge.carrier_id == carrier_id }
        [path_results]
      end

      def trucking_permutations(path_results:)
        options = %w[trucking_pre trucking_on].map { |carriage|
          path_results[carriage].present? ? path_results[carriage].group_by(&:tenant_vehicle_id).values : [nil]
        }

        options.first.product(options.second)
      end

      def result_matcher(section:, date:, grouping_keys:)
        tenant_vehicle_id = grouping_keys[:tenant_vehicle_id]
        itinerary_id = grouping_keys[:itinerary_id]
        if TRUCKING_SECTIONS.include?(section)
          return trucking_result_matcher(section: section, date: date, grouping_keys: grouping_keys)
        end

        charges.select do |charge|
          result_comparator(
            charge: charge,
            section: section,
            date: date,
            tenant_vehicle_id: tenant_vehicle_id,
            itinerary_id: itinerary_id
          )
        end
      end

      def result_comparator(charge:, section:, date:, tenant_vehicle_id:, itinerary_id:)
        if section == "cargo"
          freight_result_comparator(
            charge: charge,
            section: section,
            date: date,
            tenant_vehicle_id: tenant_vehicle_id,
            itinerary_id: itinerary_id
          )
        else
          local_charge_result_comparator(
            charge: charge,
            section: section,
            date: date,
            tenant_vehicle_id: tenant_vehicle_id
          )
        end
      end

      def freight_result_comparator(charge:, section:, date:, tenant_vehicle_id:, itinerary_id:)
        charge.section == section &&
          charge.tenant_vehicle_id == tenant_vehicle_id &&
          charge.validity.cover?(date) &&
          shipment.cargo_classes.include?(charge.cargo_class) &&
          charge.itinerary_id == itinerary_id
      end

      def local_charge_result_comparator(charge:, section:, date:, tenant_vehicle_id:)
        charge.section == section &&
          charge.tenant_vehicle_id == tenant_vehicle_id &&
          charge.validity.cover?(date) &&
          shipment.cargo_classes.include?(charge.cargo_class)
      end

      def trucking_result_matcher(section:, date:, grouping_keys:)
        if grouping_keys[:carrier_lock]
          return trucking_carrier_lock_matcher(section: section, date: date, carrier_id: grouping_keys[:carrier_id])
        end
        target_hub_id = section.match?(/pre/) ? grouping_keys[:origin_hub_id] : grouping_keys[:destination_hub_id]
        charges.select do |charge|
          charge.section == section &&
            charge.validity.cover?(date) &&
            charge.hub_id == target_hub_id
        end
      end

      def trucking_carrier_lock_matcher(section:, date:, carrier_id:)
        charges.select do |charge|
          charge.section == section &&
            charge.validity.cover?(date) &&
            charge.carrier_id == carrier_id
        end
      end

      def required_sections(grouping_keys:)
        [
          shipment.has_pre_carriage? ? "trucking_pre" : nil,
          local_charge_required?(direction: "export", grouping_keys: grouping_keys) ? "export" : nil,
          "cargo",
          local_charge_required?(direction: "import", grouping_keys: grouping_keys) ? "import" : nil,
          shipment.has_on_carriage? ? "trucking_on" : nil
        ].compact
      end

      def section_dates(schedule:, sections:)
        sections.each_with_object({}) do |section, hash|
          direction = EXPORT_SECTIONS.include?(section) ? "export" : "import"
          hash[section] = OfferCalculator::ValidityService.new(
            logic: @scope.fetch("validity_logic"),
            direction: direction,
            booking_date: @shipment.desired_start_date,
            schedules: [schedule]
          ).start_date
        end
      end

      def local_charge_required?(direction:, grouping_keys:)
        itinerary = Legacy::Itinerary.find(grouping_keys[:itinerary_id])
        hub = direction == "export" ? itinerary.origin_hub : itinerary.destination_hub
        carriage = direction == "export" ? "pre" : "on"
        mandatory_and_exists = hub.mandatory_charge.send("#{direction}_charges") &&
          hub.local_charges.current.exists?(tenant_vehicle_id: grouping_keys[:tenant_vehicle_id], direction: direction)
        shipment.has_carriage?(carriage) || mandatory_and_exists
      end

      def schedules_groupings(schedules:)
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
    end
  end
end
