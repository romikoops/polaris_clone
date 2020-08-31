# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Employees < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'company_name': :string,
          'first_name': :string,
          'last_name': :optional_string,
          'email': :string,
          'password': :string,
          'phone': :optional_string,
          'vat_number': :optional_string,
          'external_id': :optional_string,
          'address': :optional_string
        }.freeze
      end
    end
  end
end
