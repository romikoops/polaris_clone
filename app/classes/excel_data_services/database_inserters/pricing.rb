# frozen_string_literal: true

module ExcelDataServices
  module DatabaseInserters
    class Pricing < Base # rubocop:disable Metrics/ClassLength
      def perform
        data.each do |group_of_row_data|
          row = ExcelDataServices::Rows::Base.get(klass_identifier).new(
            row_data: group_of_row_data.first, tenant: tenant
          )

          itinerary = find_or_initialize_itinerary(row)

          hub_names = [row.origin_name, row.destination_name]
          stops = find_or_initialize_stops(hub_names, itinerary)
          itinerary.stops << stops - itinerary.stops

          add_stats(itinerary)
          itinerary.save!

          tenant_vehicle = find_or_create_tenant_vehicle(row)
          transport_category = find_transport_category(tenant_vehicle, row.load_type)

          create_pricing_with_pricing_details(group_of_row_data, row, transport_category, tenant_vehicle, itinerary)
        end

        stats
      end

      private

      def find_or_initialize_itinerary(row)
        Itinerary.find_or_initialize_by(
          tenant: tenant,
          name: row.itinerary_name,
          mode_of_transport: row.mot,
          sandbox: @sandbox
        )
      end

      def find_or_initialize_stops(hub_names, itinerary)
        hub_names.map.with_index do |hub_name, i|
          hub = Hub.find_by(tenant: tenant, name: hub_name, sandbox: @sandbox)
          stop = itinerary.stops.find_by(hub_id: hub.id, index: i, sandbox: @sandbox)
          stop ||= Stop.new(hub_id: hub.id, index: i, sandbox: @sandbox)
          add_stats(stop)

          stop
        end
      end

      def find_or_create_tenant_vehicle(row)
        carrier = Carrier.find_or_create_by(name: row.carrier) unless row.carrier.blank?

        tenant_vehicle = TenantVehicle.find_by(
          tenant: tenant,
          name: row.service_level,
          mode_of_transport: row.mot,
          carrier: carrier,
          sandbox: @sandbox
        )

        # TODO: fix!! `Vehicle` shouldn't be creating a `TenantVehicle`!:
        tenant_vehicle || Vehicle.create_from_name(
          name: row.service_level,
          mot: row.mot,
          tenant_id: tenant.id,
          carrier_name: carrier&.name,
          sandbox: @sandbox
        ) # returns a `TenantVehicle`!
      end

      def find_transport_category(tenant_vehicle, cargo_class)
        # TODO: what is called 'load_type' in the excel file is actually a cargo_class!
        tenant_vehicle.vehicle.transport_categories.find_by(
          name: 'any',
          cargo_class: cargo_class.downcase,
          sandbox: @sandbox
        )
      end

      def create_pricing_with_pricing_details(group_of_row_data, row, transport_category, tenant_vehicle, itinerary) # rubocop:disable Metrics/AbcSize
        if @scope['base_pricing']
          load_type = row.load_type == 'lcl' ? 'cargo_item' : 'container'
          pricing_params =
            { tenant: tenant,
              cargo_class: row.load_type,
              load_type: load_type,
              tenant_vehicle: tenant_vehicle,
              sandbox: @sandbox,
              group_id: @group_id,
              effective_date: Date.parse(row.effective_date.to_s).beginning_of_day,
              expiration_date: Date.parse(row.expiration_date.to_s).end_of_day.change(usec: 0) }

          new_pricing = itinerary.rates.new(pricing_params)
          old_pricings = itinerary.rates.where(pricing_params.except(:effective_date, :expiration_date))
          overlap_handler = ExcelDataServices::DatabaseInserters::DateOverlapHandler.new(old_pricings, new_pricing)
          pricings_with_actions = overlap_handler.perform

          pricings_for_new_pricing_details = act_on_overlapping_pricings(pricings_with_actions)

          new_pricing_detail_params_arr = build_pricing_detail_params_for_pricing(group_of_row_data)
          new_pricing_detail_params_arr.each do |pricing_detail_params|
            range_data = pricing_detail_params.delete(:range) if pricing_detail_params[:range]

            pricings_for_new_pricing_details.each do |pricing|
              new_pricing_detail = pricing.fees.new(pricing_detail_params)
              new_pricing_detail.range = range_data if range_data

              add_stats(new_pricing_detail)
              new_pricing_detail.save!
            end
          end
        else
          pricing_params =
          { tenant: tenant,
            transport_category: transport_category,
            tenant_vehicle: tenant_vehicle,
            sandbox: @sandbox,
            user: User.find_by(tenant_id: tenant.id, email: row.customer_email),
            effective_date: Date.parse(row.effective_date.to_s).beginning_of_day,
            expiration_date: Date.parse(row.expiration_date.to_s).end_of_day.change(usec: 0) }

          new_pricing = itinerary.pricings.new(pricing_params)
          old_pricings = itinerary.pricings.where(pricing_params.except(:effective_date, :expiration_date))
          overlap_handler = ExcelDataServices::DatabaseInserters::DateOverlapHandler.new(old_pricings, new_pricing)
          pricings_with_actions = overlap_handler.perform

          pricings_for_new_pricing_details = act_on_overlapping_pricings(pricings_with_actions)

          new_pricing_detail_params_arr = build_pricing_detail_params_for_pricing(group_of_row_data)
          new_pricing_detail_params_arr.each do |pricing_detail_params|
            range_data = pricing_detail_params.delete(:range) if pricing_detail_params[:range]

            pricings_for_new_pricing_details.each do |pricing|
              new_pricing_detail = pricing.pricing_details.new(pricing_detail_params)
              new_pricing_detail.range = range_data if range_data

              add_stats(new_pricing_detail)
              new_pricing_detail.save!
            end
          end
        end
      end

      def act_on_overlapping_pricings(pricings_with_actions)
        new_pricings = []
        if scope['base_pricing']
          pricings_with_actions.slice(:destroy).values.each do |pricings|
            pricings.each do |pricing|
              pricing.fees.each do |pricing_detail|
                pricing_detail.destroy
                add_stats(pricing_detail)
              end
              pricing.destroy
              add_stats(pricing)
            end
          end
          pricings_with_actions.slice(:save).values.each do |pricings|
            pricings.map do |pricing|
              new_pricings << pricing if pricing.new_record? && !pricing.transient_marked_as_old
              add_stats(pricing)
              pricing.save!
            end
          end
        else
          pricings_with_actions.slice(:destroy).values.each do |pricings|
            pricings.each do |pricing|
              pricing.pricing_details.each do |pricing_detail|
                pricing_detail.destroy
                add_stats(pricing_detail)
              end
              pricing.destroy
              add_stats(pricing)
            end
          end
          pricings_with_actions.slice(:save).values.each do |pricings|
            pricings.map do |pricing|
              new_pricings << pricing if pricing.new_record? && !pricing.transient_marked_as_old
              add_stats(pricing)
              pricing.save!
            end
          end
        end
        new_pricings
      end

      def build_pricing_detail_params_for_pricing(group_of_row_data) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        group_of_row_data.map do |row_data| # rubocop:disable Metrics/BlockLength
          row = ExcelDataServices::Rows::Base.get(klass_identifier).new(row_data: row_data, tenant: tenant)

          fee_code = row.fee_code.upcase

          charge_category = ChargeCategory.from_code(
            tenant_id: tenant.id,
            code: fee_code,
            name: row.fee_name || fee_code,
            sandbox: @sandbox
          )
          if scope['base_pricing']
            rate_basis = Pricings::RateBasis.create_from_external_key(row.rate_basis)
            hw_rate_basis = Pricings::RateBasis.create_from_external_key(row.hw_rate_basis)
            pricing_detail_params =
            { tenant_id: tenant.id,
              rate_basis: rate_basis,
              charge_category: charge_category,
              currency_name: row.currency&.upcase,
              currency_id: nil,
              sandbox: @sandbox,
              hw_threshold: row.hw_threshold,
              hw_rate_basis: hw_rate_basis }

            if row.range.blank?
              pricing_detail_params[:rate] = row.fee
              pricing_detail_params[:min] = row.fee_min.blank? ? row.fee : row.fee_min
            else
              min_rate_in_range = row.range.map { |r| r['rate'] }.min
              min_rate = row.fee_min.blank? ? min_rate_in_range : row.fee_min
              pricing_detail_params.merge!(
                rate: min_rate_in_range,
                min: min_rate,
                range: row.range
              )
            end
          else

            pricing_detail_params =
            { tenant_id: tenant.id,
              rate_basis: row.rate_basis,
              shipping_type: fee_code,
              currency_name: row.currency&.upcase,
              currency_id: nil,
              sandbox: @sandbox,
              hw_threshold: row.hw_threshold,
              hw_rate_basis: row.hw_rate_basis }

            if row.range.blank?
              pricing_detail_params[:rate] = row.fee
              pricing_detail_params[:min] = row.fee_min.blank? ? row.fee : row.fee_min
            else
              min_rate_in_range = row.range.map { |r| r['rate'] }.min
              min_rate = row.fee_min.blank? ? min_rate_in_range : row.fee_min
              pricing_detail_params.merge!(
                rate: min_rate_in_range,
                min: min_rate,
                range: row.range
              )
            end
          end


          pricing_detail_params
        end
      end
    end
  end
end
