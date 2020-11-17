# frozen_string_literal: true

RSpec.shared_context "with trucking_modifiers_sheet" do
  let(:rate_schema) do
    FactoryBot.build(:schemas_sheets_trucking_rates, file: instance_double("xlsx"), sheet_name: "Rates")
  end
  let(:bracket_counts) { [10] }
  let(:modifiers) { ["kg"] }
  let(:trucking_modifiers_frame) do
    FactoryBot.build(:trucking_modifiers_frame,
      bracket_counts: bracket_counts,
      modifiers: modifiers)
  end
  let(:trucking_modifiers_state) do
    ExcelDataServices::DataFrames::Combinators::State.new(
      frame: trucking_modifiers_frame,
      schema: rate_schema,
      errors: [],
      hub_id: hub.id,
      group_id: group_id,
      organization_id: organization.id
    )
  end

  before do
    allow(ExcelDataServices::DataFrames::DataProviders::Trucking::Modifiers).to receive(:state)
      .and_return(trucking_modifiers_state)
  end
end
