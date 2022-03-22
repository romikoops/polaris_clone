# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::LineItemDecorator do
  let!(:line_item) { FactoryBot.create(:journey_line_item) }
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:decorated_line_item) { described_class.new(line_item, context: context) }
  let(:context) { {} }

  before do
    Organizations.current_id = organization.id
  end

  describe "#value" do
    context "when no currency is provided" do
      it "returns the original total" do
        expect(decorated_line_item.value).to eq(line_item.total)
      end
    end

    context "when 'EUR' currency is provided" do
      let(:context) { { currency: "EUR" } }

      it "returns the total converted to the desired currency" do
        expect(decorated_line_item.value).to eq(line_item.total.exchange_to("EUR"))
      end
    end
  end
end
