# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Extractors::DistributionHub do
  include_context "V4 setup"
  let(:result) { described_class.state(state: state_arguments) }
  let(:extracted_table) { result.frame }
  let(:hub) { FactoryBot.create(:legacy_hub, :gothenburg, organization: organization) }
  let(:distribution_hub) { FactoryBot.create(:legacy_hub, :gothenburg) }

  describe ".state" do
    context "when found" do
      let(:rows) do
        [
          {
            "hub_id" => hub.id,
            "row" => 2,
            "organization_id" => organization.id
          },
          {
            "hub_id" => hub.id,
            "row" => 2,
            "organization_id" => distribution_hub.organization_id
          }
        ]
      end
      let(:expected_data) do
        [{ "hub_id" => hub.id, "organization_id" => organization.id }, { "hub_id" => distribution_hub.id, "organization_id" => distribution_hub.organization_id }]
      end

      it "returns the frame with the hub ids corrected on the mismatched rows" do
        expect(extracted_table[%w[hub_id organization_id]].to_a).to match_array(expected_data)
      end
    end
  end
end
