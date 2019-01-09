# frozen_string_literal: true

require 'rails_helper'

module Admiralty
  RSpec.describe DashboardController, type: :controller do
    routes { Engine.routes }
    render_views

    before do
      allow_any_instance_of(AdmiraltyAuth::AuthorizedController).to receive(:authenticate_user!).and_return(true)
    end

    describe 'GET #index' do
      it 'renders page' do
        get :index

        # require 'pry'; binding.pry
        expect(response).to be_successful
      end
    end
  end
end
