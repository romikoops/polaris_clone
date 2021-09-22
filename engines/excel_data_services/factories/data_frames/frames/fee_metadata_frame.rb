# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_fee_metadata_frame, class: "Rover::DataFrame" do
    transient do
      carrier { "SACO" }
      service { "standard" }
      cargo_class { "lcl" }
      sheet_name { "Rates" }
      truck_type { "default" }
      direction { "export" }
      organization_id { nil }
    end

    initialize_with do
      new([{
        "carrier" => carrier,
        "service" => service,
        "truck_type" => truck_type,
        "direction" => direction,
        "cargo_class" => cargo_class,
        "sheet_name" => sheet_name,
        "mode_of_transport" => mode_of_transport,
        "organization_id" => organization_id
      }],
        types: ExcelDataServices::DataFrames::DataProviders::Trucking::FeeMetadata.column_types)
    end
  end
end
