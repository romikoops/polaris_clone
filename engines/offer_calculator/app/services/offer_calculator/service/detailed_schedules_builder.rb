# frozen_string_literal: true

require_relative 'charge_calculator'

module OfferCalculator
  module Service
    class DetailedSchedulesBuilder < Base # rubocop:disable Metrics/ClassLength
      def perform(schedules, trucking_data, user, wheelhouse = false)
        raise OfferCalculator::Calculator::NoValidSchedules if schedules.empty?

        @trucking_data = trucking_data
        @user = user
        @pricings_with_meta = {}
        @metadata_list = trucking_data.fetch(:metadata, [])
        @wheelhouse = wheelhouse
        schedules_by_pricings = grouped_schedules(schedules: schedules,
                                                  shipment: @shipment,
                                                  user: user).compact

        raise OfferCalculator::Calculator::NoValidPricings if schedules_by_pricings.empty?

        charges_and_result = schedules_by_pricings.flat_map do |grouped_result|
          next if grouped_result[:schedules].empty?

          { grouped_result: grouped_result, valid_charges: handle_group_result(grouped_result: grouped_result) }
        end

        results_for_quotation = charges_and_result.pluck(:valid_charges)
                                                  .flatten
        handle_errors(errors: results_for_quotation) if results_for_quotation.all? { |result| result[:error].present? }

        if results_for_quotation.present?
          quotation = Quotations::Creator.new(results: results_for_quotation, user: user).perform
        end

        return quotation if @wheelhouse.present? && quotation.present?

        detailed_schedules = charges_and_result.flat_map do |grand_total_charge_and_result|
          grand_total_charge_and_result[:valid_charges].map do |grand_total_charge|
            next if invalid_quote?(charge: grand_total_charge[:total])

            handle_valid_charge(
              valid_charge: grand_total_charge,
              current_result: grand_total_charge_and_result[:grouped_result]
            )
          end
        end

        compacted_detailed_schedules = detailed_schedules.compact

        raise OfferCalculator::Calculator::NoValidSchedules if compacted_detailed_schedules.empty?

        valid_compacted_detailed_schedules = compacted_detailed_schedules.reject { |result| result[:error].present? }

        detailed_schedules_with_service_level_count(detailed_schedules: valid_compacted_detailed_schedules)
      end

      def handle_group_result(grouped_result:)
        current_result = grouped_result.dup
        grand_total_charges = ChargeCalculator.new(
          trucking_data: trucking_data[:trucking_pricings],
          shipment: @shipment,
          user: user,
          data: current_result,
          sandbox: @sandbox,
          metadata_list: @metadata_list
        ).perform

        return grand_total_charges if grand_total_charges.all? { |charge| charge[:error].present? }

        grand_total_charges.reject { |charge| charge[:error].present? }
      end

      def handle_valid_charge(valid_charge:, current_result:)
        quote = quote_from_charge(charge: valid_charge[:total])
        meta_for_result = meta(
          result: valid_charge,
          shipment: @shipment,
          pricings_by_cargo_class: current_result[:pricings_by_cargo_class],
          user: user,
          rate_overview: current_result[:rate_overview]
        )

        result_to_return(
          quote: quote,
          meta_for_result: meta_for_result,
          grand_total_charge: valid_charge,
          current_result: current_result
        )
      end

      def result_to_return(quote:, meta_for_result:, grand_total_charge:, current_result:)
        {
          quote: quote,
          schedules: grand_total_charge[:schedules].map(&:to_detailed_hash),
          meta: meta_for_result,
          notes: grab_notes(
            schedule: grand_total_charge[:schedules].first,
            tenant_id: @shipment.tenant_id,
            pricing_ids: current_result[:pricings_by_cargo_class].values.flatten
          )
        }
      end

      def quote_from_charge(charge:)
        charge.deconstruct_tree_into_schedule_charge(hidden_values_args).deep_symbolize_keys
      end

      def hidden_values_args
        if @wheelhouse
          {}
        else
          {
            guest: user.guest?,
            hidden_grand_total: scope['hide_grand_total'],
            hidden_sub_total: scope['hide_sub_totals']
          }
        end
      end

      def handle_errors(errors:)
        raise errors.last[:error]
      end

      def detailed_schedules_with_service_level_count(detailed_schedules:)
        filtered_detailed_schedules = detailed_schedules.dup

        detailed_schedule_chunks = filtered_detailed_schedules.chunk do |detailed_schedule|
          [
            detailed_schedule.dig(:meta, :carrier_name),
            detailed_schedule.dig(:meta, :origin_hub),
            detailed_schedule.dig(:meta, :destination_hub)
          ]
        end

        detailed_schedule_chunks.each do |_, detailed_schedule_chunk|
          service_levels = detailed_schedule_chunk.map do |detailed_schedule|
            detailed_schedule.dig(:meta, :service_level)
          end

          detailed_schedule_chunk.each do |detailed_schedule|
            detailed_schedule[:meta][:service_level_count] = service_levels.count
          end
        end

        filtered_detailed_schedules
      end

      def meta(result:, shipment:, pricings_by_cargo_class:, user:, rate_overview:) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        schedule = result[:schedules].first
        transit_time = (schedule.eta.to_date - schedule.etd.to_date).to_i
        chargeable_weight = if shipment.lcl? && shipment.aggregated_cargo
                              shipment.aggregated_cargo.calc_chargeable_weight(schedule.mode_of_transport)
                            elsif shipment.lcl? && !shipment.aggregated_cargo
                              shipment.cargo_items.reduce(0) do |acc, c|
                                acc + c.calc_chargeable_weight(schedule.mode_of_transport) * c.quantity
                              end
                            else
                              0
                            end
        pricing_ids = pricings_by_cargo_class.values.flat_map { |pricing| pricing['id'] }
        transshipment_notes = grab_transshipments_notes(pricing_ids: pricing_ids, tenant_id: shipment.tenant_id)
        transshipment_via = transshipment_notes.first&.body

        note_association = Legacy::Note.where(tenant_id: shipment.tenant_id, remarks: true)
        remark_notes = note_association.where(pricings_pricing_id: pricing_ids)
                                       .or(note_association.where(target: shipment.tenant))
                                       .pluck(:body)
        valid_until = shipment.valid_until(schedule.trip)

        {
          shipment_id: shipment.id,
          transit_time: transit_time,
          load_type: shipment.load_type,
          mode_of_transport: schedule.mode_of_transport,
          name: schedule.trip.itinerary.name,
          service_level: schedule.vehicle_name,
          carrier_name: schedule.carrier_name,
          origin_hub: schedule.origin_hub,
          tenant_vehicle_id: schedule.trip.tenant_vehicle_id,
          itinerary_id: schedule.trip.itinerary_id,
          destination_hub: schedule.destination_hub,
          charge_trip_id: schedule.trip_id,
          ocean_chargeable_weight: chargeable_weight,
          pricings_by_cargo_class: pricings_by_cargo_class,
          transshipmentVia: transshipment_via,
          validUntil: valid_until,
          remarkNotes: remark_notes,
          metadata_id: result[:metadata].id,
          pricing_rate_data: filter_rate_overview(rate_overview: rate_overview, valid_until: valid_until)
        }
      end

      def filter_rate_overview(rate_overview:, valid_until:)
        rate_overview.each_with_object({}) do |(key, rates), result|
          correct_rate = rates.find do |rate|
            valid_until.between?(rate['effective_date'], rate['expiration_date'])
          end
          pricing_hash = correct_rate.dig('data') || {}
          flat_margins = correct_rate.dig('flat_margins') || {}

          flat_margins.each do |code, value|
            pricing_hash[code.to_s]['rate'] += value if value.present?
          end

          result[key] = pricing_hash
        end
      end

      def dedicated_pricings?(user)
        if @scope['base_pricing']
          @scope['dedicated_pricings_only']
        else
          legacy_pricing = Legacy::Pricing.where(user: user, internal: false, sandbox: @sandbox)
          legacy_pricing.exists? && @scope['dedicated_pricings_only']
        end
      end

      def pricings_sets(pricings:)
        most_diverse_set = pricings.values.max_by(&:length)
        other_pricings = pricings
                         .values
                         .reject { |pricing_group| pricing_group == most_diverse_set }
                         .flatten

        [most_diverse_set, other_pricings]
      end

      def filter_schedules_for_dates(schedules:, pricing:)
        filtered_schedules = schedules.dup
        filtered_schedules.select! do |sched|
          (pricing[:effective_date]..pricing[:expiration_date]).cover?(sched.etd)
        end
        if filtered_schedules.empty?
          filtered_schedules = schedules.select do |sched|
            (pricing[:effective_date]..pricing[:expiration_date]).cover?(sched.closing_date)
          end
        end

        filtered_schedules
      end

      def filter_other_sets(sets:, result:, dates:)
        sets.each do |pricing|
          other_cargo_class_key = pricing[:cargo_class]
          if (pricing[:effective_date]..pricing[:expiration_date]).overlaps?(dates[:start_date]..dates[:end_date])
            result[:pricings_by_cargo_class][other_cargo_class_key] = pricing
          end

          next unless result[:pricings_by_cargo_class][other_cargo_class_key].nil? &&
                      (pricing[:effective_date]..pricing[:expiration_date])
                      .overlaps?(dates[:closing_start_date]..dates[:closing_end_date])

          result[:pricings_by_cargo_class][other_cargo_class_key] = pricing
        end

        result
      end

      def sort_sets(schedules:, alpha_set:, other_sets:, dates:, rate_overview:)
        result_to_return = []
        alpha_set.each do |pricing|
          schedules_for_obj = filter_schedules_for_dates(schedules: schedules, pricing: pricing)
          cargo_class_key = pricing[:cargo_class]
          result = {
            pricings_by_cargo_class: {
              cargo_class_key => pricing
            },
            schedules: schedules_for_obj,
            rate_overview: rate_overview
          }
          result = filter_other_sets(sets: other_sets, result: result, dates: dates)
          result_to_return << result
        end
        result_to_return
      end

      def grouped_schedules(schedules:, shipment:, user:)
        result_to_return = []
        cargo_classes = shipment.aggregated_cargo ? ['lcl'] : shipment.cargo_units.pluck(:cargo_class)
        schedule_groupings = sort_schedule_permutations(schedules: schedules)
        user_pricing_id = @scope['base_pricing'] ? user.id : user.pricing_id
        schedule_groupings.each do |_key, schedules_array|
          schedules_array.sort_by!(&:eta)
          dates = extract_dates_and_quote(schedules_array)
          pricings_by_cargo_class, rate_overview = sort_pricings(
            schedules: schedules_array,
            user_pricing_id: user_pricing_id,
            cargo_classes: cargo_classes,
            dates: dates,
            dedicated_pricings_only: dedicated_pricings?(user)
          )

          next nil if pricings_by_cargo_class.empty?

          most_diverse_set, other_pricings = pricings_sets(pricings: pricings_by_cargo_class)
          result_to_return |= sort_sets(
            schedules: schedules_array,
            alpha_set: most_diverse_set,
            other_sets: other_pricings,
            dates: dates,
            rate_overview: rate_overview
          )
        end
        result_to_return
      end

      def sort_schedule_permutations(schedules:)
        schedules.group_by do |schedule|
          [schedule.mode_of_transport,
           schedule.vehicle_name,
           schedule.carrier_name,
           schedule.load_type,
           schedule.origin_hub_id,
           schedule.destination_hub_id].join('_')
        end
      end

      def sort_pricings(schedules:, user_pricing_id:, cargo_classes:, dates:, dedicated_pricings_only:)
        pricings_by_cargo_class, pricing_metadata, rate_overview = ::Pricings::Finder.new(
          schedules: schedules,
          user_pricing_id: user_pricing_id,
          cargo_classes: cargo_classes,
          dates: dates,
          dedicated_pricings_only: dedicated_pricings_only,
          shipment: @shipment,
          sandbox: @sandbox
        ).perform

        @metadata_list |= pricing_metadata if pricing_metadata.present?

        [pricings_by_cargo_class, rate_overview]
      end

      def extract_dates_and_quote(schedules)
        start_date, end_date = start_and_end_dates(schedules: schedules, closing: false)
        closing_start_date, closing_end_date = start_and_end_dates(schedules: schedules, closing: true)
        is_quote = quotation_tool?

        {
          start_date: start_date,
          end_date: end_date,
          is_quote: is_quote,
          closing_start_date: closing_start_date,
          closing_end_date: closing_end_date
        }
      end

      def start_and_end_dates(schedules:, closing: false)
        attr = closing ? :closing_date : :etd
        start_date = schedules.first.send(attr).to_date
        end_date = schedules.last.send(attr).to_date
        end_date = start_date == end_date ? end_date + 1.day : end_date
        [start_date, end_date]
      end

      def invalid_quote?(charge:)
        charge.price.value.zero?
      end

      def grab_notes(pricing_ids:, tenant_id:, schedule:)
        hubs = [schedule.origin_hub, schedule.destination_hub]
        nexii = hubs.map(&:nexus)
        countries = nexii.map(&:country)
        legacy_pricings = Legacy::Pricing.where(id: pricing_ids)
        pricings = Pricings::Pricing.where(id: pricing_ids)
        regular_notes = Legacy::Note.where(transshipment: false, tenant_id: tenant_id)
        regular_notes.where(target: hubs | nexii | countries | legacy_pricings)
                     .or(regular_notes.where(pricings_pricing_id: pricings.ids))
      end

      def grab_transshipments_notes(pricing_ids:, tenant_id:)
        legacy_pricings = Legacy::Pricing.where(id: pricing_ids)
        pricings = Pricings::Pricing.where(id: pricing_ids)
        transshipment_notes = Legacy::Note.where(transshipment: true, tenant_id: tenant_id)

        transshipment_notes.where(target: legacy_pricings)
                           .or(transshipment_notes.where(pricings_pricing_id: pricings.ids))
                           .select(:id, :body)
      end

      attr_reader :trucking_data, :user, :shipment
    end
  end
end
