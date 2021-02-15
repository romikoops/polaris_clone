# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ResultUpdater do
  describe "#perform" do
    let(:query) { FactoryBot.build(:journey_query, organization: organization) }
    let(:result) { FactoryBot.create(:journey_result, query: query) }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:line_item_set) { result.line_item_sets.first }
    let(:optional) { false }
    let(:included) { false }
    let(:line_item) do
      FactoryBot.create(:journey_line_item,
        line_item_set: line_item_set,
        units: 2,
        optional: optional,
        included: included)
    end
    let(:new_line_item_set) { Journey::LineItemSet.where(result: result).where.not(id: line_item_set).first }
    let(:updated_line_item) { new_line_item_set.line_items.find { |li| li.fee_code == line_item.fee_code } }

    subject(:updater) do
      described_class.new(result: result,
                          line_item_id: line_item.id,
                          value: 50)
    end

    context "when the line itme is valid for editing" do
      before do
        updater.perform
      end

      it "creates a new line item with the new values", :aggregate_failures do
        expect(updated_line_item.total_cents).to eq(5000.0)
        expect(updated_line_item.unit_price_cents).to eq(2500.0)
      end
    end

    context "when the charge is of detail level 3 and uneditable (included)" do
      let(:included) { true }

      it "raises an error" do
        expect { updater.perform }.to raise_error Api::ResultUpdater::UneditableFee
      end
    end

    context "when the charge is of detail level 3 and uneditable (optional)" do
      let(:optional) { true }

      it "raises an error" do
        expect { updater.perform }.to raise_error Api::ResultUpdater::UneditableFee
      end
    end
  end
end
