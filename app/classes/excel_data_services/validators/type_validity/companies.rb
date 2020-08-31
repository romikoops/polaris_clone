# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Companies < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'name': :string,
          'email': :optional_string,
          'phone': :optional_string,
          'vat_number': :optional_string,
          'external_id': :optional_string,
          'address': :optional_string
        }.freeze
      end
    end
  end
end
