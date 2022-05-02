# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Formatters::Carrier do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:insertable_data) { result.insertable_data }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "carrier" => "MSC",
          "organization_id" => organization.id,
          "row" => 2,
          "carrier_id" => nil
        }
      end
      let(:expected_data) do
        [{
          "name" => "MSC",
          "code" => "msc"
        }]
      end

      it "returns the frame with the insertable_data" do
        expect(insertable_data.to_a).to eq(expected_data)
      end
    end
  end
end
