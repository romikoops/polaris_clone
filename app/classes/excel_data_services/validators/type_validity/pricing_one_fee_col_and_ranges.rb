# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class PricingOneFeeColAndRanges < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'effective_date': :date,
          'expiration_date': :date,
          'origin_locode': :locode,
          'destination_locode': :locode,
          'load_type': :cargo_class,
          'transshipment': :optional_string,
          'origin': :string,
          'country_origin': :string,
          'destination': :string,
          'country_destination': :string,
          'mot': :string,
          'carrier': :optional_string,
          'service_level': :optional_string,
          'rate_basis': :string,
          'range_min': :optional_numeric,
          'range_max': :optional_numeric,
          'fee_code': :string,
          'fee_name': :optional_string,
          'currency': :string,
          'fee_min': :optional_integer,
          'fee': :numeric,
          'group_id': :optional_string,
          'group_name': :optional_string,
          'transit_time': :optional_integer,
          'remarks': :optional_string,
          'wm_ratio': :optional_integer
        }.freeze
      end
    end
  end
end
