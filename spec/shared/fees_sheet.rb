# frozen_string_literal: true

RSpec.shared_context "with trucking_fees_sheet" do
  let(:fee_count) { 3 }
  let(:country_code) { "GB" }
  let(:fee_trait) { :fees }
  let(:fee_schema) do
    FactoryBot.build(:schemas_sheets_trucking_fees, file: instance_double("xlsx"), sheet_name: "Zones")
  end
  let(:trucking_fees_frame) { FactoryBot.build(:trucking_fees_frame, fee_trait, carrier: carrier_name, organization: organization) }
  let(:trucking_fees_state) do
    ExcelDataServices::DataFrames::Combinators::State.new(
      frame: trucking_fees_frame,
      schema: fee_schema,
      errors: [],
      hub_id: hub.id,
      group_id: group_id,
      organization_id: organization.id
    )
  end

  before do
    allow(ExcelDataServices::DataFrames::DataProviders::Trucking::Fees).to receive(:state)
      .and_return(trucking_fees_state)
  end
end
