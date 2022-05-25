# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::V4::Distributors::Actions::AdjustFee do
  include_context "V4 setup"

  let(:result) { described_class.new(frame: frame, action: action).perform }
  let(:origins) { %w[DEHAM] }
  let(:destinations) { %w[CNSGH CNNGB] }
  let(:locode_pairings) { origins.product(destinations) }
  let(:action) { FactoryBot.create(:distributions_action, :adjust_fee, where: { destination_locode: "CNNGB" }, arguments: { operator: operator, value: value }) }

  describe "#perform" do
    let(:rows) do
      locode_pairings.map.with_index do |(origin, destination), index|
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
          "row" => index + 2,
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

    context "when the operator is '*'" do
      let(:operator) { "*" }
      let(:value) { "1.5" }

      it "only adjusts the CNNGB rate by the amount described", :aggregate_failures do
        expect(result.filter("destination_locode" => "CNNGB")["rate"].to_a).to match_array([150.0])
        expect(result.filter("destination_locode" => "CNSGH")["rate"].to_a).to match_array([100.0])
      end
    end

    context "when the operator is 'x'" do
      let(:operator) { "x" }
      let(:value) { "1.5" }

      it "only adjusts the CNNGB rate by the amount described", :aggregate_failures do
        expect(result.filter("destination_locode" => "CNNGB")["rate"].to_a).to match_array([150.0])
        expect(result.filter("destination_locode" => "CNSGH")["rate"].to_a).to match_array([100.0])
      end
    end

    context "when the operator is '%'" do
      let(:operator) { "%" }
      let(:value) { "0.15" }

      it "only adjusts the CNNGB rate by the amount described", :aggregate_failures do
        expect(result.filter("destination_locode" => "CNNGB")["rate"].to_a).to match_array([115.0])
        expect(result.filter("destination_locode" => "CNSGH")["rate"].to_a).to match_array([100.0])
      end
    end

    context "when the operator is '%' and the value is greater than 1" do
      let(:operator) { "%" }
      let(:value) { "15" }

      it "only adjusts the CNNGB rate by the amount described", :aggregate_failures do
        expect(result.filter("destination_locode" => "CNNGB")["rate"].to_a).to match_array([115.0])
        expect(result.filter("destination_locode" => "CNSGH")["rate"].to_a).to match_array([100.0])
      end
    end

    context "when the operator is '+'" do
      let(:operator) { "+" }
      let(:value) { "33" }

      it "only adjusts the CNNGB rate by the amount described", :aggregate_failures do
        expect(result.filter("destination_locode" => "CNNGB")["rate"].to_a).to match_array([133.0])
        expect(result.filter("destination_locode" => "CNSGH")["rate"].to_a).to match_array([100.0])
      end
    end
  end
end
