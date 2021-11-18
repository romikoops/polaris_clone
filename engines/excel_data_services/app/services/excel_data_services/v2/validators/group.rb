# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class Group < ExcelDataServices::V2::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V2::Extractors::Group.state(state: state)
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
