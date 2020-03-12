# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class LocalCharges < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'effective_date': :date,
          'expiration_date': :date,
          'hub': :required_string,
          'country': :required_string,
          'fee': :required_string,
          'counterpart_hub': :optional_string,
          'counterpart_country': :optional_string,
          'service_level': :optional_string,
          'carrier': :optional_string,
          'fee_code': :optional_string,
          'direction': :optional_string,
          'rate_basis': :required_string,
          'mot': :required_string,
          'load_type': :required_string,
          'currency': :required_string
        }.freeze
      end
    end
  end
end
