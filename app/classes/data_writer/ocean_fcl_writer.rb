# frozen_string_literal: true

module DataWriter
  class OceanFclWriter < BaseWriter
    private

    STATIC_HEADERS_NO_RANGES_TO_ATTRIBUTES = {
      effective_date: :effective_date,
      expiration_date: :expiration_date,
      customer_email: :customer_email,
      origin: :origin_hub_name,
      country_origin: :origin_country_name,
      destination: :destination_hub_name,
      country_destination: :destination_country_name,
      mot: :mot,
      carrier: :carrier_name,
      service_level: :service_level,
      load_type: :load_type,
      rate_basis: :rate_basis,
      transit_time: :transit_time,
      currency: :currency_name
    }.freeze

    def load_and_prepare_data
      pricing_rows = []
      tenant.pricings.all_fcl.each do |pricing|
        pricing_only_attributes = build_pricing_only_row_data(pricing)
        pricing.pricing_details.each do |pricing_detail|
          pricing_detail_only_attributes = build_pricing_detail_only_row_data(pricing_detail)
          pricing_rows << pricing_only_attributes.merge(pricing_detail_only_attributes)
        end
      end

      dynamic_headers = pricing_rows.map { |x| x[:shipping_type]&.downcase&.to_sym }.uniq.compact

      data_no_ranges, data_with_ranges = pricing_rows.group_by { |row| row[:range].empty? }.values

      rows_data_no_ranges = data_no_ranges.map do |row|
        row_data = {}
        STATIC_HEADERS_NO_RANGES_TO_ATTRIBUTES.each do |key, value|
          row_data.merge!(key => row[value])
        end

        header = row[:shipping_type]&.downcase&.to_sym
        row_data[header] = row[:rate]
        headers_no_values = dynamic_headers - [header]

        headers_no_values.each do |key|
          row_data.merge!(key => nil)
        end
        row_data
      end

      { "No Ranges": rows_data_no_ranges }
    end

    def build_pricing_detail_only_row_data(pricing_detail)
      pricing_detail.attributes.with_indifferent_access.except(
        :id,
        :created_at,
        :updated_at,
        :priceable_type,
        :priceable_id,
        :tenant_id
      )
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
      origin_hub = itinerary.hubs.first
      origin_hub_name = remove_hub_suffix(origin_hub.name, mot)
      origin_country_name = origin_hub.address.country.name
      destination_hub = itinerary.hubs.second
      destination_hub_name = remove_hub_suffix(destination_hub.name, mot)
      destination_country_name = destination_hub.address.country.name
      carrier_name = pricing.carrier
      service_level = pricing.tenant_vehicle.name
      load_type = pricing.cargo_class # TODO: load_type is called cargo_class...
      trip = itinerary.trips.first if itinerary.trips
      transit_time = ((trip.end_date - trip.start_date).seconds / 1.day).round(0) if trip
      transit_time = nil if transit_time.zero?

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
  end
end
