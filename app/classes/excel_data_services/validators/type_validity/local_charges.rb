# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class LocalCharges < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'effective_date': :date,
          'expiration_date': :date,
          'hub': :string,
          'country': :string,
          'fee': :string,
          'counterpart_hub': :optional_string,
          'counterpart_country': :optional_string,
          'service_level': :optional_string,
          'carrier': :optional_string,
          'fee_code': :string,
          'direction': :optional_string,
          'rate_basis': :string,
          'mot': :string,
          'load_type': :cargo_class,
          'currency': :string,
          'minimum': :optional_numeric,
          'maximum': :optional_numeric,
          'base': :optional_numeric,
          'ton': :optional_numeric,
          'cbm': :optional_numeric,
          'kg': :optional_numeric,
          'item': :optional_numeric,
          'shipment': :optional_numeric,
          'bill': :optional_numeric,
          'container': :optional_numeric,
          'wm': :optional_numeric,
          'range_min': :optional_numeric,
          'range_max': :optional_numeric,
          'dangerous': :optional_boolean,
          'group_id': :optional_string,
          'group_name': :optional_string
        }.freeze
      end
    end
  end
end
