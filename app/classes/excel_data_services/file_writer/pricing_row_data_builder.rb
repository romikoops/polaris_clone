# frozen_string_literal: true

module ExcelDataServices
  module FileWriter
    module PricingRowDataBuilder
      include ExcelDataServices::PricingTool

      private

      def build_raw_pricing_rows(pricings)
        raw_pricing_rows = []

        pricings.each do |pricing|
          pricing_only_attributes = build_pricing_only_row_data(pricing)
          pricing.pricing_details.each do |pricing_detail|
            pricing_detail_only_attributes = build_pricing_detail_only_row_data(pricing_detail)
            raw_pricing_rows << pricing_only_attributes.merge(pricing_detail_only_attributes)
          end
        end
        raw_pricing_rows
      end

      def build_pricing_only_row_data(pricing)
        pricing_attributes = pricing.attributes.with_indifferent_access.except(
          :id,
          :created_at,
          :updated_at,
          :wm_rate,
          :tenant_id,
          :transport_category_id,
          :user_id,
          :itinerary_id,
          :tenant_vehicle_id
        )

        customer_email = pricing.user&.email
        itinerary = pricing.itinerary
        mot = itinerary.mode_of_transport
        origin_hub = itinerary.origin_stops.first.hub
        origin_hub_name = remove_hub_suffix(origin_hub.name, mot)
        origin_country_name = origin_hub.address.country.name
        destination_hub = itinerary.destination_stops.first.hub
        destination_hub_name = remove_hub_suffix(destination_hub.name, mot)
        destination_country_name = destination_hub.address.country.name
        carrier_name = pricing.carrier
        service_level = pricing.tenant_vehicle.name
        load_type = pricing.cargo_class.upcase # TODO: load_type is called cargo_class...
        trip = itinerary.trips.first if itinerary.trips
        transit_time = ((trip.end_date - trip.start_date).seconds / 1.day).round(0) if trip&.end_date && trip&.start_date
        transit_time = nil if transit_time&.zero?

        pricing_attributes.merge(
          customer_email: customer_email,
          mot: mot,
          origin_hub_name: origin_hub_name,
          origin_country_name: origin_country_name,
          destination_hub_name: destination_hub_name,
          destination_country_name: destination_country_name,
          carrier_name: carrier_name,
          service_level: service_level,
          load_type: load_type,
          transit_time: transit_time
        )
      end

      def build_pricing_detail_only_row_data(pricing_detail)
        charge_category = ChargeCategory.from_code(pricing_detail.shipping_type, tenant.id)
        fee_name = charge_category.name
        pricing_detail.attributes.with_indifferent_access.except(
          :id,
          :created_at,
          :updated_at,
          :priceable_type,
          :priceable_id,
          :tenant_id
        ).merge(fee_name: fee_name)
      end

      def expand_ranges(data)
        result_rows_data = []
        data.each do |row_data|
          result_row = row_data.except(:range)
          row_data[:range]&.each do |range|
            result_rows_data << result_row.merge(
              rate: range[:rate],
              range_min: range[:min],
              range_max: range[:max]
            ) # important: non-destructive merge!
          end
          result_rows_data << result_row if row_data[:range].blank?
        end
        result_rows_data
      end

      def sort!(data)
        data.sort_by! do |h|
          [
            h[:destination_country_name] || '',
            h[:destination_hub_name] || '',
            h[:origin_country_name] || '',
            h[:origin_hub_name] || '',
            h[:carrier_name] || '',
            h[:service_level] || '',
            h[:load_type] || '',
            h[:rate_basis] || '',
            h[:shipping_type] || ''
          ]
        end
      end

      def build_rows_data_with_static_fee_col(data_static_fee_col)
        return nil unless data_static_fee_col

        sort!(data_static_fee_col)
        data_static_fee_col = expand_ranges(data_static_fee_col)
        data_static_fee_col.map do |attributes|
          ONE_COL_FEE_AND_RANGES_ATTRIBUTES_LOOKUP.inject({}) do |row_data, (key, value)|
            row_data.merge!(key => attributes[value])
          end
        end
      end
    end
  end
end
