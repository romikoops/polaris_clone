# frozen_string_literal: true

module ExcelDataServices
  module PricingTool
    private

    DYNAMIC_FEE_COLS_NO_RANGES_HEADERS = %i(
      effective_date
      expiration_date
      customer_email
      origin
      country_origin
      destination
      country_destination
      mot
      carrier
      service_level
      load_type
      rate_basis
      transit_time
      currency
    ).freeze

    ONE_COL_FEE_AND_RANGES_HEADERS = %i(
      effective_date
      expiration_date
      customer_email
      origin
      country_origin
      destination
      country_destination
      mot
      carrier
      service_level
      load_type
      rate_basis
      range_min
      range_max
      fee_code
      fee_name
      currency
      fee_min
      fee
    ).freeze

    STATIC_HEADERS_ATTRIBUTES_LOOKUP = {
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
      currency: :currency_name
    }.freeze

    ONE_COL_FEE_AND_RANGES_ATTRIBUTES_LOOKUP = STATIC_HEADERS_ATTRIBUTES_LOOKUP.merge(
      range_min: :range_min,
      range_max: :range_max,
      fee_code: :shipping_type,
      fee_name: :fee_name,
      fee_min: :min,
      fee: :rate
    ).freeze

    DYNAMIC_FEE_COLS_NO_RANGES_ATTRIBUTES_LOOKUP = STATIC_HEADERS_ATTRIBUTES_LOOKUP.merge(
      transit_time: :transit_time
    ).freeze
  end
end
