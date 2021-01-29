# frozen_string_literal: true

RSpec.shared_context "with trucking_brackets_sheet" do
  let(:rate_schema) do
    FactoryBot.build(:schemas_sheets_trucking_rates, file: instance_double("xlsx"), sheet_name: "Rates")
  end
  let(:bracket_counts) { [10] }
  let(:max_ranges) { [3500] }
  let(:start) { 0 }
  let(:trucking_brackets_frame) do
    FactoryBot.build(:trucking_brackets_frame,
      bracket_counts: bracket_counts,
      max_ranges: max_ranges,
      start: start)
  end
  let(:trucking_brackets_state) do
    ExcelDataServices::DataFrames::Combinators::State.new(
      frame: trucking_brackets_frame,
      schema: rate_schema,
      errors: [],
      hub_id: hub.id,
      group_id: group_id,
      organization_id: organization.id
    )
  end

  before do
    allow(ExcelDataServices::DataFrames::DataProviders::Trucking::Brackets).to receive(:state)
      .and_return(trucking_brackets_state)
  end
end
