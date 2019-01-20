# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CountriesController, type: :controller do
  describe 'GET #index' do
    it 'returns http success', pending: 'Outdated spec' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
