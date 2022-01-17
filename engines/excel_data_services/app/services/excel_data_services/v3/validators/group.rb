# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Validators
      class Group < ExcelDataServices::V3::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V3::Extractors::Group.state(state: state)
        end

        def error_reason(row:)
          "The Group '#{row['group_name']}' cannot be found."
        end

        def required_key
          "group_id"
        end
      end
    end
  end
end
