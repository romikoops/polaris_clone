# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::StringValidity do
  include_context "V4 setup"
  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }

  describe ".state" do
    context "when found" do
      let(:rows) do
        [
          {
            "effective_date" => Date.parse("2022-06-27"),
            "expiration_date" => Date.parse("2022-10-04"),
            "row" => 3,
            "organization_id" => organization.id
          }
        ]
      end

      it "returns the frame the validity range is string format" do
        expect(extracted_table["validity"].to_a).to match_array(["[2022-06-27, 2022-10-04)"])
      end
    end
  end
end
