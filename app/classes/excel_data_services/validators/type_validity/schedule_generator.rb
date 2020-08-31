# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module TypeValidity
      class ScheduleGenerator < ExcelDataServices::Validators::TypeValidity::Base
        COLUMN_TO_CLASS_LOOKUP = {
          'origin': :string,
          'destination': :string,
          'carrier': :optional_string,
          'service_level': :optional_string,
          'etd_days': :integer,
          'mot': :string,
          'transit_time': :optional_integer,
          'cargo_class': :cargo_class
        }.freeze
      end
    end
  end
end
