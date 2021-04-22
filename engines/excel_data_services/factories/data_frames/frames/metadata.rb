# frozen_string_literal: true

FactoryBot.define do
  factory :trucking_metadata_frame, class: "Rover::DataFrame" do
    transient do
      city { "Hamburg" }
      currency { "EUR" }
      load_meterage_ratio { 1500 }
      load_meterage_stackable_type { "area" }
      load_meterage_non_stackable_type { "ldm" }
      load_meterage_stackable_limit { 5 }
      load_meterage_non_stackable_limit { 2.5 }
      load_meterage_hard_limit { false }
      cbm_ratio { 250 }
      scale { "kg" }
      rate_basis { "PER_KG" }
      base { 1.0 }
      truck_type { "default" }
      load_type { "cargo_item" }
      cargo_class { "lcl" }
      direction { "export" }
      carrier { "SACO" }
      service { "standard" }
      sheet_name { "Rates" }
      mode_of_transport { "truck_carriage" }
      effective_date { Date.parse("01/09/2020") }
      expiration_date { Date.parse("31/12/2020") }
      group_id { nil }
      hub_id { nil }
      organization_id { nil }
    end

    initialize_with do
      new([{
        "city" => city,
        "currency" => currency,
        "load_meterage_ratio" => load_meterage_ratio,
        "load_meterage_non_stackable_type" => load_meterage_non_stackable_type,
        "load_meterage_stackable_type" => load_meterage_stackable_type,
        "load_meterage_stackable_limit" => load_meterage_stackable_limit,
        "load_meterage_non_stackable_limit" => load_meterage_non_stackable_limit,
        "load_meterage_hard_limit" => load_meterage_hard_limit,
        "cbm_ratio" => cbm_ratio,
        "scale" => scale,
        "rate_basis" => rate_basis,
        "base" => base,
        "truck_type" => truck_type,
        "load_type" => load_type,
        "cargo_class" => cargo_class,
        "direction" => direction,
        "carrier" => carrier,
        "service" => service,
        "sheet_name" => sheet_name,
        "mode_of_transport" => mode_of_transport,
        "effective_date" => effective_date,
        "expiration_date" => expiration_date,
        "group_id" => group_id,
        "hub_id" => hub_id,
        "organization_id" => organization_id
      }],
        types: ExcelDataServices::DataFrames::DataProviders::Trucking::Metadata.column_types)
    end
  end
end
