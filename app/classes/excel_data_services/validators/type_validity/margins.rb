# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Margins < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'effective_date': :date,
          'expiration_date': :date,
          'origin': :string,
          'country_origin': :string,
          'destination': :string,
          'country_destination': :string,
          'mot': :string,
          'carrier': :optional_string,
          'service_level': :optional_string,
          'margin_type': :string,
          'load_type': :cargo_class,
          'fee_code': :string,
          'operator': :string,
          'margin': :string
        }.freeze
      end
    end
  end
end
