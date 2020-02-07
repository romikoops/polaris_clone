# frozen_string_literal: true

require_relative 'charge_calculator'

module OfferCalculator
  module Service
    class DetailedSchedulesBuilder < Base # rubocop:disable Metrics/ClassLength

      def perform(schedules, trucking_data, user) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
        @pricings_with_meta = {}
        @metadata_list = trucking_data.fetch(:metadata, [])
        schedules_by_pricings = grouped_schedules(schedules: schedules,
                                                  shipment: @shipment,
                                                  user: user).compact

        raise OfferCalculator::Calculator::NoValidPricings if schedules_by_pricings.empty?

        detailed_schedules = schedules_by_pricings.map do |grouped_result| # rubocop:disable Metrics/BlockLength
          next if grouped_result[:schedules].empty?

          current_result = grouped_result.dup
          grand_total_charges = ChargeCalculator.new(
            trucking_data: trucking_data[:trucking_pricings],
            shipment: @shipment,
            user: user,
            data: current_result,
            sandbox: @sandbox,
            metadata_list: @metadata_list
          ).perform

          next if grand_total_charges.blank?


          grand_total_charges.map do |grand_total_charge|
            quote = grand_total_charge[:total].deconstruct_tree_into_schedule_charge.deep_symbolize_keys
            next if invalid_quote?(quote: quote)

            meta_for_result = meta(
              result: grand_total_charge,
              shipment: @shipment,
              pricings_by_cargo_class: current_result[:pricings_by_cargo_class],
              user: user
            )
            Quotations::Creator.new(
              charge: grand_total_charge[:total],
              meta: meta_for_result,
              user: user
            ).perform
            {
              quote: grand_total_charge[:total].deconstruct_tree_into_schedule_charge.deep_symbolize_keys,
              schedules: grand_total_charge[:schedules].map(&:to_detailed_hash),
              meta: meta_for_result,
              notes: grab_notes(
                schedule: grand_total_charge[:schedules].first,
                tenant_id: @shipment.tenant_id,
                pricing_ids: current_result[:pricings_by_cargo_class].values.flatten
              )
            }
          end
        end

        compacted_detailed_schedules = detailed_schedules.flatten.compact

        raise OfferCalculator::Calculator::NoSchedulesCharges if compacted_detailed_schedules.empty?

        detailed_schedules_with_service_level_count(detailed_schedules: compacted_detailed_schedules)
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

      def meta(result:, shipment:, pricings_by_cargo_class:, user:) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        schedule = result[:schedules].first
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

        {
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
          validUntil: shipment.valid_until(schedule.trip),
          remarkNotes: remark_notes,
          metadata_id: result[:metadata].id,
          pricing_rate_data: grab_pricing_rates(
            schedule: schedule,
            load_type: shipment.load_type,
            user: user
          )
        }
      end

      def grab_pricing_rates(schedule:, load_type:, user:) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        # Used to create data for rate overview
        tenant_vehicle_id = schedule.trip.tenant_vehicle_id
        itinerary = schedule.trip.itinerary
        eta = schedule.eta || Time.zone.today
        etd = schedule.etd || Time.zone.today
        if @scope['base_pricing']
          itinerary.rates
                   .where(tenant_vehicle_id: tenant_vehicle_id, internal: false, sandbox: @sandbox)
                   .for_dates(etd, eta)
                   .for_load_type(load_type)
                   .each_with_object({}) do |pricing, hash|
            manipulated_pricing, _metadata = ::Pricings::Manipulator.new(
              target: Tenants::User.find_by(legacy_id: user.id),
              tenant: Tenants::Tenant.find_by(legacy_id: user.tenant_id),
              type: :freight_margin,
              args: {
                pricing: pricing,
                schedules: [schedule],
                shipment: @shipment
              }
            ).perform

            pricing_hash = manipulated_pricing.first.dig('data')
            flat_margins = manipulated_pricing.first.dig('flat_margins')

            flat_margins.each do |code, value|
              pricing_hash[code.to_s]['rate'] += value if value.present?
            end

            pricing_hash['valid_until'] = pricing.expiration_date
            hash[pricing.cargo_class] = pricing_hash
          end
        else
          pricings = itinerary.pricings.where(
            tenant_vehicle_id: tenant_vehicle_id,
            user_id: user.pricing_id,
            sandbox: @sandbox,
            internal: false
          )

          if pricings.empty?
            pricings = itinerary.pricings.where(
              tenant_vehicle_id: tenant_vehicle_id,
              sandbox: @sandbox,
              internal: false
            )
          end

          pricings.for_dates(etd, eta)
                  .for_load_type(load_type)
                  .each_with_object({}) do |pricing, hash|
            pricing_hash = pricing.as_json.dig('data')
            pricing_hash['total'] = pricing_hash.keys.each_with_object('value' => 0, 'currency' => nil) do |key, obj|
              obj['value'] += pricing_hash[key]['rate']
              obj['currency'] ||= pricing_hash[key]['currency']
            end
            pricing_hash['valid_until'] = pricing.expiration_date
            hash[pricing.cargo_class] = pricing_hash
          end
        end
      end

      def dedicated_pricings?(user)
        if @scope['base_pricing']
          @scope['dedicated_pricings_only']
        else
          user.pricings.where(internal: false, sandbox: @sandbox).exists? && @scope['dedicated_pricings_only']
        end
      end

      def grouped_schedules(schedules:, shipment:, user:) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
        result_to_return = []
        cargo_classes = shipment.aggregated_cargo ? ['lcl'] : shipment.cargo_units.pluck(:cargo_class)
        schedule_groupings = sort_schedule_permutations(schedules: schedules)
        user_pricing_id = @scope['base_pricing'] ? user.id : user.pricing_id
        # Find the pricings for the cargo classes and effective date ranges then group by cargo_class
        schedule_groupings.each do |_key, schedules_array| # rubocop:disable Metrics/BlockLength
          schedules_array.sort_by!(&:eta)
          dates = extract_dates_and_quote(schedules_array)
          pricings_by_cargo_class = sort_pricings(
            schedules: schedules_array,
            user_pricing_id: user_pricing_id,
            cargo_classes: cargo_classes,
            dates: dates,
            dedicated_pricings_only: dedicated_pricings?(user)
          )

          next nil if pricings_by_cargo_class.empty?
          # Find the group with the most pricings and create the object to be passed on
          most_diverse_set = pricings_by_cargo_class.values.max_by(&:length)
          other_pricings = pricings_by_cargo_class
                           .values
                           .reject { |pricing_group| pricing_group == most_diverse_set }
                           .flatten

          if @scope['base_pricing'] # rubocop:disable Style/IfInsideElse
            most_diverse_set.each do |pricing| # rubocop:disable Metrics/BlockLength
              schedules_for_obj = schedules_array.dup
              if dates[:is_quote]
                schedules_for_obj.reject! do |sched|
                  sched.etd > pricing[:expiration_date]
                end

                next if schedules_for_obj.empty?
              else
                schedules_for_obj.select! do |sched|
                  sched.etd < pricing[:expiration_date] && sched.etd > pricing[:effective_date]
                end
                if schedules_for_obj.empty? # rubocop:disable Metrics/BlockNesting
                  schedules_for_obj = schedules_array.select do |sched|
                    sched.closing_date < pricing[:expiration_date] &&
                      sched.closing_date > pricing[:effective_date]
                  end
                end
              end
              cargo_class_key = pricing[:cargo_class]
              obj = {
                pricings_by_cargo_class: {
                  cargo_class_key => pricing
                },
                schedules: schedules_for_obj
              }

              other_pricings.each do |other_pricing|
                other_cargo_class_key = other_pricing[:cargo_class]
                if other_pricing[:effective_date] < dates[:start_date] &&
                   other_pricing[:expiration_date] > dates[:end_date]
                  obj[:pricings_by_cargo_class][other_cargo_class_key] =
                    other_pricing
                end

                next unless obj[:pricings_by_cargo_class][other_cargo_class_key].nil? &&
                            other_pricing[:effective_date] < dates[:closing_start_date] &&
                            other_pricing[:expiration_date] > dates[:closing_end_date]

                obj[:pricings_by_cargo_class][other_cargo_class_key] = other_pricing
              end
              result_to_return << obj
            end
          else
            most_diverse_set.each do |pricing| # rubocop:disable Metrics/BlockLength
              schedules_for_obj = schedules_array.dup
              if dates[:is_quote]
                schedules_for_obj.reject! do |sched|
                  sched.etd > pricing[:expiration_date]
                end

                next if schedules_for_obj.empty?
              else
                schedules_for_obj.select! do |sched|
                  sched.etd < pricing[:expiration_date] && sched.etd > pricing[:effective_date]
                end
                if schedules_for_obj.empty? # rubocop:disable Metrics/BlockNesting
                  schedules_for_obj = schedules_array.select do |sched|
                    sched.closing_date < pricing[:expiration_date] &&
                      sched.closing_date > pricing[:effective_date]
                  end
                end
              end

              cargo_class_key = pricing[:cargo_class] ||
                                Legacy::TransportCategory.find(pricing[:transport_category_id])&.cargo_class.to_s
              obj = {
                pricings_by_cargo_class: {
                  cargo_class_key => pricing
                },
                schedules: schedules_for_obj
              }

              other_pricings.each do |other_pricing|

                other_cargo_class_key = other_pricing.try(:cargo_class) ||
                                        Legacy::TransportCategory.find_by(id: other_pricing['transport_category_id'])&.cargo_class&.to_s
                if other_pricing['effective_date'] < dates[:start_date] &&
                   other_pricing['expiration_date'] > dates[:end_date]
                  obj[:pricings_by_cargo_class][other_cargo_class_key] =
                    other_pricing
                end

                next unless obj[:pricings_by_cargo_class][other_cargo_class_key].nil? &&
                            other_pricing['effective_date'] < dates[:closing_start_date] &&
                            other_pricing['expiration_date'] > dates[:closing_end_date]

                obj[:pricings_by_cargo_class][other_cargo_class_key] = other_pricing
              end

              result_to_return << obj
            end
          end
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

      def sort_pricings(schedules:, user_pricing_id:, cargo_classes:, dates:, dedicated_pricings_only:) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity, Metrics/MethodLength
        if @scope['base_pricing']
          pricings_by_cargo_class, pricing_metadata = ::Pricings::Finder.new(
            schedules: schedules,
            user_pricing_id: user_pricing_id,
            cargo_classes: cargo_classes,
            dates: dates,
            dedicated_pricings_only: dedicated_pricings_only,
            shipment: @shipment,
            sandbox: @sandbox
          ).perform

          @metadata_list |= pricing_metadata if pricing_metadata.present?

          return pricings_by_cargo_class
        end
        tenant_vehicle_id = schedules.first.trip.tenant_vehicle_id
        start_date = dates[:start_date]
        end_date = dates[:end_date]
        closing_start_date = dates[:closing_start_date]
        closing_end_date = dates[:closing_end_date]
        pricings_by_cargo_class = schedules.first.trip.itinerary.pricings
                                           .where(tenant_vehicle_id: tenant_vehicle_id, sandbox: @sandbox)
                                           .for_cargo_classes(cargo_classes)
        if start_date && end_date
          pricings_by_cargo_class_and_dates = pricings_by_cargo_class.for_dates(start_date, end_date)
        end
        ## If etd filter results in no pricings, check using closing_date
        if start_date && end_date && pricings_by_cargo_class_and_dates.empty?
          pricings_by_cargo_class_and_dates = pricings_by_cargo_class
                                              .for_dates(closing_start_date, closing_end_date)
        end
        pricings_by_cargo_class_and_dates_and_user = pricings_by_cargo_class_and_dates
                                                     .select { |pricing| pricing.user_id == user_pricing_id }
        if pricings_by_cargo_class_and_dates_and_user.empty? && !dedicated_pricings_only
          pricings_by_cargo_class_and_dates_and_user = pricings_by_cargo_class_and_dates
                                                       .select { |pricing| pricing.user_id.nil? }
        end

        pricings_by_cargo_class_and_dates_and_user
          .map { |pricing| pricing.as_json.with_indifferent_access }
          .group_by { |pricing| pricing['transport_category_id'] }
      end

      def extract_dates_and_quote(schedules)
        start_date = schedules.first.etd
        end_date = schedules.last.etd
        closing_start_date = schedules.first.closing_date
        closing_end_date = schedules.last.closing_date
        is_quote = quotation_tool?
        {
          start_date: start_date,
          end_date: end_date,
          is_quote: is_quote,
          closing_start_date: closing_start_date,
          closing_end_date: closing_end_date
        }
      end

      def invalid_quote?(quote:)
        quote.dig(:total, :value).blank? ||
          quote.dig(:total, :value).to_i.zero? ||
          !quote.dig(:cargo, :value).nil?
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
    end
  end
end
