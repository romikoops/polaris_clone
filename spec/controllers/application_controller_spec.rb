# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController do
  describe "GET #health" do
    it "returns http success" do
      get :health

      expect(response).to have_http_status(:success)
    end
  end
end
