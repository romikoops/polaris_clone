# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Validators
      class LocationsLocation < ExcelDataServices::V4::Validators::Base
        def extracted
          @extracted ||= ExcelDataServices::V4::Extractors::LocationsLocation.state(state: state)
        end

        def error_reason(row:)
          "The location '#{row.values_at(row['identifier'], 'range').compact.join(', ')}' cannot be found."
        end

        def filtered_frame
          frame[frame["query_type"] == Extractors::QueryType::QUERY_TYPE_ENUM["location"]]
        end

        def row_key
          "zone_row"
        end
      end
    end
  end
end
