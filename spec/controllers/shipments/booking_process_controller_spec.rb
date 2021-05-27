# frozen_string_literal: true

require "rails_helper"

RSpec.describe Shipments::BookingProcessController do
  let(:organization) { FactoryBot.create(:organizations_organization, scope: scope) }
  let(:scope) { FactoryBot.create(:organizations_scope, content: scope_content) }
  let(:scope_content) { {} }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:shipment) do
    FactoryBot.create(:completed_legacy_shipment,
      organization: organization,
      trip: trip,
      user: user,
      itinerary: itinerary,
      with_breakdown: true,
      with_tenders: true)
  end
  let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary) }

  before do
    ::Organizations.current_id = organization.id
    append_token_header
    shipment.charge_breakdowns.map(&:tender).each do |tender|
      Treasury::ExchangeRate.create(from: tender.amount.currency.iso_code,
                                    to: "USD", rate: 1.3,
                                    created_at: tender.created_at - 30.seconds)
    end
  end

  context "when sending admin emails on quote download" do
    let(:result) { FactoryBot.create(:journey_result) }
    let(:offer) { FactoryBot.create(:journey_offer, line_item_sets: result.line_item_sets) }
    let(:quotes) do
      [
        {
          meta: { tender_id: result.id }
        }.with_indifferent_access
      ]
    end

    before do
      quote_mailer = object_double("Mailer")
      allow(Wheelhouse::OfferBuilder).to receive(:offer).and_return(offer)
      allow(Notifications::ClientMailer).to receive(:offer_email).at_least(:once).and_return(quote_mailer)
      allow(quote_mailer).to receive(:deliver_now).at_least(:once)
    end

    describe ".save_and_send_quotes" do
      it "successfully calls the mailer and return the quote Document" do
        post :send_quotes, params: { organization_id: organization.id, shipment_id: result.id, quotes: quotes }
      end
    end

    describe ".download_quotations" do
      it "successfully calls the mailer and return the quote Document" do
        post :download_quotations, params: {
          organization_id: organization.id, shipment_id: result.id, options: { quotes: quotes }
        }
        expect(response_data["url"]).to include("active_storage/blobs")
      end
    end
  end

  describe "POST #get_offers" do
    let(:shipment_params) do
      shipment.as_json.merge(
        origin: {
          longitude: itinerary.origin_hub.longitude,
          latitude: itinerary.origin_hub.latitude,
          nexus_id: itinerary.origin_hub.nexus.id,
          nexus_name: itinerary.origin_hub.nexus.name,
          country: itinerary.origin_hub.nexus.country.name
        },
        destination: {
          longitude: itinerary.destination_hub.longitude,
          latitude: itinerary.destination_hub.latitude,
          nexus_id: itinerary.destination_hub.nexus.id,
          nexus_name: itinerary.destination_hub.nexus.name,
          country: itinerary.destination_hub.nexus.country.name
        },
        direction: "export",
        selected_day: Time.zone.today,
        containers_attributes: [{
          size_class: "fcl_40",
          quantity: 1,
          payload_in_kg: 12,
          dangerous_goods: false
        }]
      )
    end
    let(:params) do
      {
        organization_id: shipment.organization,
        shipment_id: shipment.id,
        shipment: shipment_params,
        async: true
      }
    end
    let(:query) { Journey::Query.find(response_data["quotationId"]) }

    it "returns the desired result", :aggregate_failures do
      post :get_offers, params: params
      expect(query.load_type).to eq("fcl")
      expect(response_data.dig("shipment", "load_type")).to eq("container")
      expect(response_data["completed"]).to be_truthy
    end

    context "when user is nil" do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
      end

      it "returns the desired result when user is nil", :aggregate_failures do
        post :get_offers, params: params
        expect(response).to have_http_status(:success)
        expect(response_data["quotationId"]).to eq(query.id)
        expect(response_data["completed"]).to be_truthy
      end
    end

    context "when user is nil and is ineligible" do
      before do
        allow(controller).to receive(:current_user).and_return(nil)
      end

      let(:scope_content) { { closed_quotation_tool: true } }

      it "returns the desired result when user is nil" do
        post :get_offers, params: params

        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe "GET #refresh_quotes" do
    it "returns an http status of success", :aggregate_failures do
      get :refresh_quotes, params: { organization_id: shipment.organization, shipment_id: shipment.id }
      expect(response).to have_http_status(:success)
      expect(response_data.length).to eq(1)
      expect(response_data.dig(0, "quote", "total", "value")).to eq("9.99")
    end
  end

  describe "POST #create_shipment" do
    it "returns an http status of success", :aggregate_failures do
      post :create_shipment, params: {
        organization_id: shipment.organization, details: { loadType: "cargo_item", direction: "import" }
      }
      expect(response).to have_http_status(:success)
      expect(response_data.dig("shipment", "id")).to be_present
    end
  end
end
