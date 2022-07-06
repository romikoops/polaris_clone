# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class TruckingLocationUpsertId < ExcelDataServices::V4::Extractors::UpsertId
        def upsert_id_from_row(row:)
          ::UUIDTools::UUID.sha1_create(::UUIDTools::UUID.parse(::Trucking::Location::UUID_V5_NAMESPACE), combined_values(row: row)).to_s
        end

        def combined_values(row:)
          [
            row["trucking_location_name"],
            Trucking::Location.queries.key(row["query_type"]),
            row["country_id"]
          ].map(&:to_s).join
        end

        def upsert_key
          "upsert_id"
        end
      end
    end
  end
end
