# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class Group < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::Group.state(state: state)
        end

        def error_reason(row:)
          "The Group '#{row['group_name']}' cannot be found."
        end

        def required_key
          "group_found"
        end
      end
    end
  end
end
