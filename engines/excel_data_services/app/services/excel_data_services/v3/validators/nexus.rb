# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Validators
      class Nexus < ExcelDataServices::V3::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V3::Extractors::Nexus.state(state: state)
        end

        def error_reason(row:)
          "The nexus '#{row['name']} (#{row['locode']})' cannot be found."
        end

        def required_key
          "nexus_id"
        end
      end
    end
  end
end
