# frozen_string_literal: true

RSpec.shared_context "with trucking_metadata_sheet" do
  let(:rate_schema) do
    FactoryBot.build(:schemas_sheets_trucking_rates, file: instance_double("xlsx"), sheet_name: "Rates")
  end
  let(:city) { "Hamburg" }
  let(:currency) { "EUR" }
  let(:load_meterage_ratio) { 1500 }
  let(:load_meterage_limit) { 2.4 }
  let(:load_meterage_area) { 2.5 }
  let(:cbm_ratio) { 250 }
  let(:scale) { "kg" }
  let(:rate_basis) { "PER_KG" }
  let(:base) { 1.0 }
  let(:truck_type) { "default" }
  let(:load_type) { "cargo_item" }
  let(:cargo_class) { "lcl" }
  let(:direction) { "export" }
  let(:carrier_name) { "SACO" }
  let(:service) { "standard" }
  let(:sheet_name) { "Rates" }
  let(:mode_of_transport) { "truck_carriage" }
  let(:trucking_metadata_frame) do
    FactoryBot.build(:trucking_metadata_frame,
      city: city,
      currency: currency,
      load_meterage_ratio: load_meterage_ratio,
      load_meterage_limit: load_meterage_limit,
      load_meterage_area: load_meterage_area,
      cbm_ratio: cbm_ratio,
      scale: scale,
      rate_basis: rate_basis,
      base: base,
      truck_type: truck_type,
      load_type: load_type,
      cargo_class: cargo_class,
      direction: direction,
      carrier: carrier_name,
      service: service,
      sheet_name: sheet_name,
      mode_of_transport: mode_of_transport)
  end

  let(:trucking_metadata_state) do
    ExcelDataServices::DataFrames::Combinators::State.new(
      frame: trucking_metadata_frame,
      schema: rate_schema,
      errors: [],
      hub_id: hub.id,
      group_id: group_id,
      organization_id: organization.id
    )
  end

  before do
    allow(ExcelDataServices::DataFrames::DataProviders::Trucking::Metadata).to receive(:state)
      .and_return(trucking_metadata_state)
  end
end
