# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class PricingDynamicFeeColsNoRanges < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'effective_date': :date,
          'expiration_date': :date,
          'origin_locode': :locode,
          'destination_locode': :locode,
          'load_type': :load_type,
          'transshipment': :optional_string
        }.freeze
      end
    end
  end
end
