# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResultFormatter::LineItemDecorator do
  include_context "journey_pdf_setup"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:line_item) { freight_line_items_with_cargo.first }
  let(:scope) { {fee_detail: "key_and_name"}.with_indifferent_access }
  let(:mode_of_transport) { "ocean" }

  describe ".decorate" do
    let(:decorated_line_item) { described_class.new(line_item, context: {scope: scope, mode_of_transport: mode_of_transport}) }

    context "with fee_detail = key_and_name" do
      it "decorates the line item with the correct name" do
        aggregate_failures do
          expect(decorated_line_item.description).to eq("#{line_item.fee_code.upcase} - Ocean Freight Rate")
        end
      end

      it "returns the right total amount for the line item" do
        aggregate_failures do
          expect(decorated_line_item.total.amount).to eq(30)
        end
      end
    end

    context "with fee_detail = key" do
      let(:scope) do
        {fee_detail: "key"}.with_indifferent_access
      end

      it "decorates the line item with the correct name" do
        aggregate_failures do
          expect(decorated_line_item.description).to eq(line_item.fee_code.upcase)
        end
      end
    end

    context "with fee_detail = name" do
      let(:scope) do
        {fee_detail: "name"}.with_indifferent_access
      end

      it "decorates the line item with the correct name" do
        aggregate_failures do
          expect(decorated_line_item.description).to eq("Ocean Freight Rate")
        end
      end
    end

    context "with fee_detail = key_and_name & fine_fee_detail" do
      let(:scope) do
        {fee_detail: "key_and_name", fine_fee_detail: true}.with_indifferent_access
      end

      it "decorates the line item with the correct name" do
        aggregate_failures do
          expect(decorated_line_item.description).to eq("#{line_item.fee_code.upcase} - #{line_item.description}")
        end
      end
    end

    context "with fee_detail = key_and_name & fine_fee_detail & unknown fee" do
      let(:scope) do
        {fee_detail: "key_and_name", fine_fee_detail: true}.with_indifferent_access
      end
      let(:line_item) {
        FactoryBot.create(:journey_line_item,
          line_item_set: line_item_set,
          route_section: freight_section,
          optional: true)
      }

      it "decorates the line item with the correct name" do
        aggregate_failures do
          expect(decorated_line_item.description).to eq("#{line_item.fee_code.upcase} - #{line_item.description}")
          expect(decorated_line_item.fee_context[:excluded]).to be_truthy
        end
      end
    end

    context "with fee_detail = key and name and consolidated cargo scope" do
      let(:scope) do
        {fee_detail: "key_and_name", consolidated_cargo: true}.with_indifferent_access
      end
      let(:mode_of_transport) { "air" }

      it "decorates the line item with the correct name" do
        aggregate_failures do
          expect(decorated_line_item.description).to eq("#{line_item.fee_code.upcase} - Consolidated Freight Rate")
        end
      end
    end

    context "with fee_detail = key and name and consolidated cargo scope and ocean mot" do
      let(:scope) do
        {fee_detail: "key_and_name", consolidated_cargo: true}.with_indifferent_access
      end

      it "decorates the line item with the correct name" do
        aggregate_failures do
          expect(decorated_line_item.description).to eq("#{line_item.fee_code.upcase} - Ocean Freight")
        end
      end
    end

    context "with included fee (no value for calculation)" do
      let(:line_item) {
        FactoryBot.create(:journey_line_item,
          line_item_set: line_item_set,
          route_section: freight_section,
          included: true)
      }

      let(:expected_result) do
        {
          included: true,
          excluded: false
        }
      end

      it "decorates the line item and returns included when the fee is included" do
        aggregate_failures do
          expect(decorated_line_item.fee_context).to eq(expected_result)
        end
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
        aggregate_failures do
          expect(decorated_line_item.fee_context).to eq(expected_result)
        end
      end
    end
  end
end
