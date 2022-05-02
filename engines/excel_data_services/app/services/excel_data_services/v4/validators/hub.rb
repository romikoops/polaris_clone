# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class Hub < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::Hub.state(state: state)
        end

        def prefix
          ""
        end

        def key_base
          prefix_key(key: "hub")
        end

        def required_key
          @required_key ||= prefix_key(key: "hub_id")
        end

        def missing_hub_details(row:)
          row.values_at(*row_values_keys).compact.join(", ")
        end

        def error_reason(row:)
          "The #{prefix_key(key: 'hub').humanize.downcase} '#{missing_hub_details(row: row)}' cannot be found. Please check that the information is entered correctly"
        end

        def prefix_key(key:)
          prefixer.prefix_key(key: key)
        end

        def prefixer
          @prefixer ||= ExcelDataServices::V4::Helpers::Prefixer.new(prefix: prefix)
        end

        def row_values_keys
          %w[hub terminal locode country].map { |key| prefix_key(key: key) }
        end
      end
    end
  end
end
