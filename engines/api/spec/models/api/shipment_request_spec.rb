# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ShipmentRequest, type: :model do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  context "when sorting" do
    let!(:asc_shipment_request_id) do
      FactoryBot.create(:journey_shipment_request,
        created_at: 2.hours.ago).id
    end
    let!(:desc_shipment_request_id) do
      FactoryBot.create(:journey_shipment_request, created_at: 5.hours.ago).id
    end

    let(:sort_by) { "#{sort_key}_#{direction_key}" }
    let(:sorted_shipment_requests) { described_class.sorted_by(sort_by) }

    before do
      Organizations.current_id = organization.id
    end

    context "when sorted by created_at" do
      let(:sort_key) { "created_at" }

      context "when sorted by created_at desc" do
        let(:direction_key) { "desc" }

        it "sorts quotation load types in descending direction" do
          expect(sorted_shipment_requests.ids).to eq([asc_shipment_request_id, desc_shipment_request_id])
        end
      end

      context "when sorted by created_at asc" do
        let(:direction_key) { "asc" }

        it "sorts quotation load types in ascending direction" do
          expect(sorted_shipment_requests.ids).to eq([desc_shipment_request_id, asc_shipment_request_id])
        end
      end
    end

    context "without matching sort_by scope" do
      let(:sort_key) { "nonsense" }
      let(:direction_key) { "desc" }

      it "returns default direction" do
        expect { sorted_shipment_requests }.to raise_error(ArgumentError)
      end
    end
  end
end
