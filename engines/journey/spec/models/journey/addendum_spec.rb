# frozen_string_literal: true

require "rails_helper"

module Journey
  RSpec.describe Addendum, type: :model do
    it "builds a valid object" do
      expect(FactoryBot.build(:journey_addendum)).to be_valid
    end

    context "when creating an addendum for a shipment request" do
      let(:shipment_request) { FactoryBot.create(:journey_shipment_request) }
      let(:addendum) { FactoryBot.build(:journey_addendum, label_name: "test_label", shipment_request_id: shipment_request.id) }

      before do
        FactoryBot.create(:journey_addendum, label_name: "test_label", shipment_request_id: shipment_request.id)
        shipment_request.reload
      end

      it "builds an invalid object", :aggregate_failures do
        expect(addendum).not_to be_valid
        expect(addendum.errors.messages[:label_name]).to eq ["has already been taken"]
      end
    end
  end
end
