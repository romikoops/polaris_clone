# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class Schedules < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'from': :string,
          'to': :string,
          'closing_date': :date,
          'etd': :date,
          'eta': :date,
          'transit_time': :optional_integer,
          'service_level': :optional_string,
          'carrier': :optional_string,
          'mode_of_transport': :string,
          'vessel': :optional_string,
          'voyage_code': :optional_string,
          'load_type': :load_type
        }.freeze
      end
    end
  end
end
