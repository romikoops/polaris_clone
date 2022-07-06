# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class Nexus < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::Nexus.new(state: state, target_frame: target_frame).perform
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
