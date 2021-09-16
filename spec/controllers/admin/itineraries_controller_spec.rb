# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::ItinerariesController, type: :controller do
  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_user) }
  let!(:itineraries) do
    [
      gothenburg_shanghai,
      shanghai_gothenburg,
      felixstowe_shanghai,
      shanghai_felixstowe,
      hamburg_shanghai,
      shanghai_hamburg
    ]
  end

  let(:gothenburg_shanghai) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:shanghai_gothenburg) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }
  let(:felixstowe_shanghai) { FactoryBot.create(:felixstowe_shanghai_itinerary, organization: organization) }
  let(:shanghai_felixstowe) { FactoryBot.create(:shanghai_felixstowe_itinerary, organization: organization) }
  let(:hamburg_shanghai) { FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization) }
  let(:shanghai_hamburg) { FactoryBot.create(:shanghai_hamburg_itinerary, organization: organization) }

  before do
    FactoryBot.create(:groups_group, :default, organization: organization)
    append_token_header
  end

  describe "GET #index" do
    let(:params) do
      {
        organization_id: organization.id,
        per_page: 6,
        page: 1
      }
    end
    let(:response_ids) { response_data["itinerariesData"].pluck("id") }

    context "without any search params" do
      it "returns http success and index data" do
        get :index, params: params

        expect(response_ids).to match_array(itineraries.pluck(:id))
      end
    end

    context "when filtered by name" do
      let(:search_params) do
        {
          name: "Gothenburg",
          name_desc: true
        }.merge(params)
      end

      it "returns http success and index data filtered by name" do
        get :index, params: search_params

        expect(response_ids).to match_array([gothenburg_shanghai, shanghai_gothenburg].pluck(:id))
      end
    end

    context "when filtered by mot" do
      let!(:air_itinerary) { FactoryBot.create(:shanghai_hamburg_itinerary, mode_of_transport: "air", organization: organization) }
      let(:search_params) do
        {
          mot: "air",
          mot_desc: true
        }.merge(params)
      end

      it "returns http success and index data filtered by mot" do
        get :index, params: search_params

        expect(response_ids).to match_array([air_itinerary.id])
      end
    end

    context "when filtered by origin" do
      let(:search_params) do
        {
          origin: "Felix",
          origin_desc: true
        }.merge(params)
      end

      it "returns http success and index data filtered by origin" do
        get :index, params: search_params

        expect(response_ids).to match_array([felixstowe_shanghai.id])
      end
    end

    context "when filtered by destination" do
      let(:search_params) do
        {
          destination: "Felix",
          destination_desc: true
        }.merge(params)
      end

      it "returns http success and index data filtered by destination" do
        get :index, params: search_params

        expect(response_ids).to match_array([shanghai_felixstowe.id])
      end
    end
  end

  describe "GET #show" do
    it "returns http success", :aggregate_failures do
      get :show, params: { organization_id: organization.id, id: itineraries.first.id }

      expect(response_data.keys).to match_array(%w[itinerary validationResult notes])
      expect(response_data.dig("itinerary", "id")).to eq(itineraries.first.id)
    end
  end

  describe "GET #stops" do
    it "returns http success", :aggregate_failures do
      get :stops, params: { organization_id: organization.id, id: itineraries.first.id }

      expect(response_data.length).to eq(2)
      expect(response_data.pluck("id")).to eq(itineraries.first.stops.ids)
    end
  end
end
