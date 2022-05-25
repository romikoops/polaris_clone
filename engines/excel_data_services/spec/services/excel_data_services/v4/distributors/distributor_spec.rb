# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Distributors::Distributor do
  include_context "V4 setup"

  let(:result) { described_class.state(state: state_arguments) }
  let(:origins) { %w[DEHAM] }
  let(:destinations) { %w[CNSGH CNNGB] }
  let(:locode_pairings) { origins.product(destinations) }

  describe "#perform" do
    context "when no Actions exist for the section type" do
      let(:section_string) { "local_charges" }

      it "returns the frame as is" do
        expect(result.frame).to eq(frame)
      end
    end

    context "when an Action exists for the section type" do
      let!(:action) { FactoryBot.create(:distributions_action, :duplicate, organization: organization, upload_schema: section_string, where: { origin_locode: "DEHAM" }) }
      let(:section_string) { "pricings" }
      let(:rows) do
        locode_pairings.map.with_index do |(origin, destination), index|
          { "customer" => "Customer AA",
            "wwa_member" => "SSLL",
            "origin_region" => "EMEA",
            "origin_inland_cfs" => origin,
            "consol_cfs" => origin,
            "origin_locode" => origin,
            "destination_region" => "EMEA",
            "destination_locode" => destination,
            "deconsol_cfs" => destination,
            "destination_inland_cfs" => nil,
            "quoting_region" => "EMEA",
            "sheet_name" => "Sheet 1",
            "row" => index + 2,
            "distribute" => true,
            "organization_id" => organization.id }
        end
      end
      let(:types) { { "distribute" => :object } }
      let!(:result_frame) { result.frame }

      it "applies the Action to the frame", :aggregate_failures do
        expect(result_frame["origin_locode"].to_a).to match_array(%w[DEHAM DEHAM DEHAM DEHAM])
        expect(result_frame["organization_id"].to_a.uniq).to match_array([organization.id, action.target_organization_id])
      end

      it "generates an Execution detailing the Action's application" do
        expect(Distributions::Execution.find_by(action: action, file_id: file.id)).to be_present
      end
    end
  end
end
