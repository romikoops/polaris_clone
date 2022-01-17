# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V3::Validators::Nexus do
  include_context "V3 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:nexus) { FactoryBot.create(:legacy_nexus, :segot, organization: organization) }

  describe ".state" do
    context "when found" do
      let(:row) do
        {
          "name" => nexus.name,
          "locode" => nexus.locode,
          "country" => nexus.country.name,
          "row" => 2,
          "nexus_id" => nil
        }
      end

      it "returns the frame with the nexus_id" do
        expect(extracted_table["nexus_id"].to_a).to eq([nexus.id])
      end
    end

    context "when not found" do
      let(:row) do
        {
          "name" => "AAA",
          "locode" => "BBBB",
          "country" => "CCC",
          "row" => 2,
          "nexus_id" => nil
        }
      end

      let(:error_messages) do
        [
          "The nexus '#{row['name']} (#{row['locode']})' cannot be found."
        ]
      end

      it "appends an error to the state", :aggregate_failures do
        expect(result.errors).to be_present
        expect(result.errors.map(&:reason)).to match_array(error_messages)
      end
    end
  end
end
