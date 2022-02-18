# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::ShipmentRequest, type: :model do
  let(:result_hamburg_shanghai) do
    FactoryBot.create(:journey_result,
      sections: 0,
      route_sections: [FactoryBot.build(:journey_route_section,
        from: FactoryBot.build(:journey_route_point, name: "hamburg", locode: "DEHAM"),
        to: FactoryBot.build(:journey_route_point, name: "shanghai", locode: "CNSGH"))])
  end

  let(:result_shanghai_hamburg) do
    FactoryBot.create(:journey_result,
      sections: 0,
      route_sections: [FactoryBot.build(:journey_route_section,
        from: FactoryBot.build(:journey_route_point, name: "shanghai", locode: "CNSGH"),
        to: FactoryBot.build(:journey_route_point, name: "hamburg", locode: "DEHAM"))])
  end

  let!(:shipment_request_a_id) do
    FactoryBot.create(:journey_shipment_request,
      result: result_hamburg_shanghai,
      created_at: 2.hours.ago).id
  end

  let!(:shipment_request_b_id) do
    FactoryBot.create(:journey_shipment_request,
      result: result_shanghai_hamburg,
      status: described_class.statuses["completed"],
      created_at: 5.hours.ago).id
  end

  it "supports multiple sort options" do
    expect(described_class::SUPPORTED_SORT_OPTIONS).to eq(%w[created_at origin destination])
  end

  it "supports multiple search options" do
    expect(described_class::SUPPORTED_SEARCH_OPTIONS).to eq(%w[origin destination status reference])
  end

  describe "#sorted_by" do
    let(:sort_by) { "#{sort_key}_#{direction_key}" }
    let(:sorted_shipment_requests) { described_class.sorted_by(sort_by) }

    context "when sorted by created_at" do
      let(:sort_key) { "created_at" }

      context "when sorted by created_at desc" do
        let(:direction_key) { "desc" }

        it "sorts quotation load types in descending direction" do
          expect(sorted_shipment_requests.ids).to eq([shipment_request_a_id, shipment_request_b_id])
        end
      end

      context "when sorted by created_at asc" do
        let(:direction_key) { "asc" }

        it "sorts quotation load types in ascending direction" do
          expect(sorted_shipment_requests.ids).to eq([shipment_request_b_id, shipment_request_a_id])
        end
      end
    end

    context "when sorted by origin" do
      let(:sort_key) { "origin" }

      context "when sorted by origin desc" do
        let(:direction_key) { "desc" }

        it "sorts shipment requests in descending direction" do
          expect(sorted_shipment_requests.ids).to eq([shipment_request_b_id, shipment_request_a_id])
        end
      end

      context "when sorted by origin asc" do
        let(:direction_key) { "asc" }

        it "sorts shipment requests in ascending direction" do
          expect(sorted_shipment_requests.ids.uniq).to eq([shipment_request_a_id, shipment_request_b_id])
        end
      end
    end

    context "when sorted by destination" do
      let(:sort_key) { "destination" }

      context "when sorted by destination desc" do
        let(:direction_key) { "desc" }

        it "sorts shipment requests in descending direction" do
          expect(sorted_shipment_requests.ids).to eq([shipment_request_a_id, shipment_request_b_id])
        end
      end

      context "when sorted by destination asc" do
        let(:direction_key) { "asc" }

        it "sorts shipment requests in ascending direction" do
          expect(sorted_shipment_requests.ids).to eq([shipment_request_b_id, shipment_request_a_id])
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

  describe "when filtering" do
    context "when filtering shipment requests by origin" do
      let(:filter_origin_search) { described_class.origin_search("Hamburg") }

      it "returns shipment requests with origin `Hamburg`" do
        expect(filter_origin_search.ids).to eq([shipment_request_a_id])
      end
    end

    context "when filtering shipment requests by destination" do
      let(:filter_destination_search) { described_class.destination_search("Shanghai") }

      it "returns shipment requests with destination `Shanghai`" do
        expect(filter_destination_search.ids).to eq([shipment_request_a_id])
      end
    end

    context "when filtering shipment requests by status" do
      let(:filter_status_search) { described_class.status_search("completed") }

      it "returns iltering shipment requests with status `completed`" do
        expect(filter_status_search.ids).to eq([shipment_request_b_id])
      end
    end

    context "when filtering shipment requests by reference" do
      let(:reference) { result_shanghai_hamburg.line_item_sets.first.reference }
      let(:filter_status_search) { described_class.reference_search(reference) }

      it "returns iltering shipment requests with specified reference" do
        expect(filter_status_search.ids).to eq([shipment_request_b_id])
      end
    end
  end
end
