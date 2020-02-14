# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class SacoShipping < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          '20dc': :fee,
          '40dc': :fee,
          '40hq': :fee,
          'destination_locode': :locode,
          'origin_locode': :locode,
          'effective_date': :date,
          'expiration_date': :date,
          'destination_country': :required_string,
          'destination_hub': :required_string,
          'carrier': :required_string,
          'terminal': :optional_string,
          'transshipment_via': :optional_string,
          'internal': :internal
        }.freeze
      end
    end
  end
end
