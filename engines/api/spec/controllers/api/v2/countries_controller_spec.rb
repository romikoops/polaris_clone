# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe Api::V2::CountriesController, type: :controller do
    routes { Engine.routes }

    describe "GET #index" do
      before { FactoryBot.create(:country) }

      it "returns a 200" do
        get :index
        expect(response).to have_http_status(:ok)
      end

      it "returns all the countries available and its ids" do
        get :index
        expect(response_data.pluck("id")).to match_array(Country.all.ids.map(&:to_s))
      end
    end
  end
end
