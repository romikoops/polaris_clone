# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Distributors::Actions::AddValues do
  include_context "V4 setup"

  let(:result) { described_class.new(frame: frame, action: action).perform }
  let(:origins) { %w[DEHAM] }
  let(:destinations) { %w[CNSGH CNNGB] }
  let(:locode_pairings) { origins.product(destinations) }
  let(:action) { FactoryBot.create(:distributions_action, :add_values, where: { destination_locode: "CNNGB" }, arguments: { remarks: "Testing" }) }

  describe "#perform" do
    let(:rows) do
      locode_pairings.map.with_index do |(origin, destination), row|
        { "customer" => "Customer AA",
          "wwa_member" => "SSLL",
          "origin_region" => "EMEA",
          "origin_inland_cfs" => origin,
          "consol_cfs" => origin,
          "origin_locode" => origin,
          "transhipment_1" => "JOAQJ",
          "transhipment_2" => nil,
          "transhipment_3" => nil,
          "destination_region" => "EMEA",
          "destination_locode" => destination,
          "deconsol_cfs" => destination,
          "destination_inland_cfs" => nil,
          "quoting_region" => "EMEA",
          "origin_terminal" => nil,
          "origin_hub" => nil,
          "origin_country" => nil,
          "destination_terminal" => nil,
          "destination_hub" => nil,
          "destination_country" => nil,
          "mode_of_transport" => nil,
          "transshipment" => nil,
          "fee_name" => "Container loading",
          "fee_code" => "container_loading",
          "service" => "standard",
          "carrier" => "test_8",
          "carrier_code" => "test_8",
          "sheet_name" => "Sheet 1",
          "row" => row + 2,
          "currency" => nil,
          "rate_basis" => nil,
          "minimum" => nil,
          "maximum" => nil,
          "notes" => nil,
          "effective_date" => nil,
          "expiration_date" => nil,
          "rate" => 100,
          "from" => nil,
          "to" => nil,
          "distribute" => true,
          "organization_id" => action.target_organization_id }
      end
    end

    it "returns the frame with the remarks added to the DEHAM rows", :aggregate_failures do
      expect(result.filter("organization_id" => action.target_organization_id, "destination_locode" => "CNNGB")["remarks"].to_a).to match_array(%w[Testing])
      expect(result.filter("organization_id" => action.target_organization_id).reject("destination_locode" => "CNNGB")["remarks"].to_a.compact).to be_empty
      expect(result.filter("organization_id" => action.organization_id)["remarks"].to_a.compact).to be_empty
    end
  end
end
