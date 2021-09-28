# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResultFormatter::LineItemDecorator do
  include_context "journey_pdf_setup"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:line_item) { freight_line_items_with_cargo.first }
  let(:scope) { { fee_detail: "key_and_name" }.with_indifferent_access }
  let(:mode_of_transport) { "ocean" }
  let(:decorated_line_item) { described_class.new(line_item, context: { scope: scope, mode_of_transport: mode_of_transport }) }

  describe ".description" do
    context "with fee_detail = key_and_name" do
      it "decorates the line item with the correct name" do
        expect(decorated_line_item.description).to eq("#{line_item.fee_code.upcase} - Ocean Freight Rate")
      end
    end

    context "with fee_detail = key" do
      let(:scope) do
        { fee_detail: "key" }.with_indifferent_access
      end

      it "decorates the line item with the correct name" do
        aggregate_failures do
          expect(decorated_line_item.description).to eq(line_item.fee_code.upcase)
        end
      end
    end

    context "with fee_detail = name" do
      let(:scope) do
        { fee_detail: "name" }.with_indifferent_access
      end

      it "decorates the line item with the correct name" do
        aggregate_failures do
          expect(decorated_line_item.description).to eq("Ocean Freight Rate")
        end
      end
    end

    context "with fee_detail = key_and_name & fine_fee_detail" do
      let(:scope) do
        { fee_detail: "key_and_name", fine_fee_detail: true }.with_indifferent_access
      end

      it "decorates the line item with the correct name" do
        aggregate_failures do
          expect(decorated_line_item.description).to eq("#{line_item.fee_code.upcase} - #{line_item.description}")
        end
      end
    end

    context "with fee_detail = key_and_name & fine_fee_detail & unknown fee" do
      let(:scope) do
        { fee_detail: "key_and_name", fine_fee_detail: true }.with_indifferent_access
      end
      let(:line_item) do
        FactoryBot.create(:journey_line_item,
          line_item_set: line_item_set,
          route_section: freight_section,
          optional: true)
      end

      it "decorates the line item with the correct name" do
        expect(decorated_line_item.description).to eq("#{line_item.fee_code.upcase} - #{line_item.description}")
      end
    end

    context "with fee_detail = key and name and consolidated cargo scope" do
      let(:scope) do
        { fee_detail: "key_and_name", consolidated_cargo: true }.with_indifferent_access
      end
      let(:freight_mot) { "air" }

      it "decorates the line item with the correct name" do
        expect(decorated_line_item.description).to eq("#{line_item.fee_code.upcase} - Consolidated Freight Rate")
      end
    end

    context "with fee_detail = key and name and consolidated cargo scope and ocean mot" do
      let(:scope) do
        { fee_detail: "key_and_name", consolidated_cargo: true }.with_indifferent_access
      end

      it "decorates the line item with the correct name" do
        expect(decorated_line_item.description).to eq("#{line_item.fee_code.upcase} - Ocean Freight")
      end
    end
  end

  describe "#fee_context" do
    context "with included fee (no value for calculation)" do
      let(:line_item) do
        FactoryBot.create(:journey_line_item,
          line_item_set: line_item_set,
          route_section: freight_section,
          included: true)
      end

      let(:expected_result) do
        {
          included: true,
          excluded: false
        }
      end

      it "decorates the line item and returns included when the fee is included" do
        expect(decorated_line_item.fee_context).to eq(expected_result)
      end
    end

    context "with normal fee (value used in calculation)" do
      let(:expected_result) do
        {
          included: false,
          excluded: false
        }
      end

      it "decorates the line item and returns included false when the fee isnt included" do
        expect(decorated_line_item.fee_context).to eq(expected_result)
      end
    end
  end

  describe "#rate_factor" do
    before { allow(decorated_line_item).to receive(:breakdown).and_return(breakdown) }

    let(:breakdown) do
      FactoryBot.build(:pricings_breakdown, data: breakdown_rate_data, rate_origin: { "type" => rate_type })
    end
    let(:rate_type) { "Pricings::Pricing" }

    context "with Pricings/LocalCharge/Trucking aux Fee structure" do
      let(:breakdown_rate_data) do
        {
          "rate_basis" => "PER_WM",
          "rate" => 10.0
        }
      end

      it "return the value" do
        expect(decorated_line_item.rate_factor).to eq("3 wm")
      end
    end

    context "with PER_CONTAINER rate_basis" do
      let(:breakdown_rate_data) do
        {
          "rate_basis" => "PER_CONTAINER",
          "rate" => 10.0
        }
      end

      it "return the value" do
        expect(decorated_line_item.rate_factor).to eq("#{line_item.units} containers")
      end
    end

    context "with Trucking main rate structure" do
      let(:breakdown_rate_data) do
        {
          "kg" => [{
            "rate" => {
              "rate_basis" => "PER_KG",
              "rate" => 1.0
            }
          }]
        }
      end
      let(:rate_type) { "Trucking::Trucking" }

      it "return the value" do
        expect(decorated_line_item.rate_factor).to eq("30 kg")
      end
    end

    context "without a Breakdown" do
      let(:breakdown) { nil }

      it "return the value" do
        expect(decorated_line_item.rate_factor).to be_nil
      end
    end
  end

  describe "#rate" do
    before { allow(decorated_line_item).to receive(:breakdown).and_return(breakdown) }

    let(:breakdown) do
      FactoryBot.build(:pricings_breakdown, data: breakdown_rate_data, rate_origin: { "type" => rate_type })
    end
    let(:rate_type) { "Pricings::Pricing" }

    context "with Pricings/LocalCharge/Trucking aux Fee structure" do
      let(:breakdown_rate_data) do
        {
          "rate_basis" => "PER_WM",
          "rate" => 10.0
        }
      end

      it "return the value" do
        expect(decorated_line_item.rate).to eq("USD10.00 / wm")
      end
    end

    context "with PER_CONTAINER rate_basis" do
      let(:breakdown_rate_data) do
        {
          "rate_basis" => "PER_CONTAINER",
          "rate" => 10.0
        }
      end

      it "return the value" do
        expect(decorated_line_item.rate).to eq("USD10.00 / container")
      end
    end

    context "with PERCENTAGE rate_basis" do
      let(:breakdown_rate_data) do
        {
          "rate_basis" => "PERCENTAGE",
          "rate" => 0.1
        }
      end

      it "return the value" do
        expect(decorated_line_item.rate).to eq("10%")
      end
    end

    context "with Trucking main rate structure" do
      let(:breakdown_rate_data) do
        {
          "kg" => [{
            "rate" => {
              "rate_basis" => "PER_KG",
              "rate" => 1.0
            }
          }]
        }
      end
      let(:rate_type) { "Trucking::Trucking" }

      it "return the value" do
        expect(decorated_line_item.rate).to eq("USD1.00 / kg")
      end
    end

    context "without a Breakdown" do
      let(:breakdown) { nil }

      it "return the value" do
        expect(decorated_line_item.rate).to be_nil
      end
    end
  end
end
