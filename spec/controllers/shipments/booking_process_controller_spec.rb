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
    allow(Carta::Client).to receive(:suggest).with(query: itinerary.origin_hub.nexus.locode).and_return(
      FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: itinerary.origin_hub.nexus.locode)
    )
    allow(Carta::Client).to receive(:suggest).with(query: itinerary.destination_hub.nexus.locode).and_return(
      FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: itinerary.destination_hub.nexus.locode)
    )
  end

  context "when sending admin emails on quote download" do
    let(:result) { FactoryBot.create(:journey_result) }
    let(:offer) { FactoryBot.create(:journey_offer, line_item_sets: result.line_item_sets) }
    let(:quotes) do
      [
        {
          meta: { tender_id: result.id },
          quote: { "total" => "100" }
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

      it "fails when quotes are missing" do
        expect do
          post :send_quotes, params: { organization_id: organization.id, shipment_id: result.id, quotes: [] }
        end.to raise_error(ActionController::ParameterMissing)
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
      expect(query.parent_id).to be_nil
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

    context "when parent query is specified" do
      let(:parent_query) { FactoryBot.create(:journey_query) }

      before do
        params[:shipment][:parent_id] = parent_query.id
      end

      it "returns the desired result with associated parent id", :aggregate_failures do
        post :get_offers, params: params
        expect(query.parent_id).to eq(parent_query.id)
        expect(response).to have_http_status(:success)
        expect(response_data["quotationId"]).to eq(query.id)
        expect(response_data["completed"]).to be true
      end
    end

    context "when an InvalidQuery error is raised" do
      before do
        query_generator_double = instance_double(OfferCalculator::Service::QueryGenerator)
        allow(OfferCalculator::Service::QueryGenerator).to receive(:new).and_return(query_generator_double)
        allow(query_generator_double).to receive(:query).and_raise(OfferCalculator::Errors::InvalidQuery)
      end

      it "catches the error and returns the ApplicationError version of the original OfferCalculator::Error", :aggregate_failures do
        post :get_offers, params: params

        expect(json[:code]).to eq(1012)
        expect(json[:message]).to eq("The params provided were not valid")
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
