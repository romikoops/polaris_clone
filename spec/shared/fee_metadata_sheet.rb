# frozen_string_literal: true

RSpec.shared_context "with trucking_fee_metadata_sheet" do
  let(:rate_schema) do
    FactoryBot.build(:schemas_sheets_trucking_rates, file: instance_double("xlsx"), sheet_name: "Rates")
  end
  let(:carrier_name) { "SACO" }
  let(:service) { "standard" }
  let(:sheet_name) { "Rates" }
  let(:mode_of_transport) { "truck_carriage" }
  let(:trucking_fee_metadata_frame) do
    FactoryBot.build(:trucking_fee_metadata_frame,
      carrier: carrier_name,
      service: service,
      sheet_name: sheet_name,
      organization_id: organization.id,
      mode_of_transport: mode_of_transport)
  end

  let(:trucking_fee_metadata_state) do
    ExcelDataServices::DataFrames::Combinators::State.new(
      frame: trucking_fee_metadata_frame,
      schema: rate_schema,
      errors: [],
      hub_id: hub.id,
      group_id: group_id,
      organization_id: organization.id
    )
  end

  before do
    allow(ExcelDataServices::DataFrames::DataProviders::Trucking::FeeMetadata).to receive(:state)
      .and_return(trucking_fee_metadata_state)
  end
end
