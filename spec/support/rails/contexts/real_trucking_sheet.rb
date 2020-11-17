# frozen_string_literal: true

RSpec.shared_context "with real trucking_sheet" do
  let(:xlsx) { Roo::Spreadsheet.open(file_fixture("excel/example_trucking.xlsx").to_s) }
end
