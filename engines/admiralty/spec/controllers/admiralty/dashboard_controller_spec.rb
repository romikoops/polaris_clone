# frozen_string_literal: true

require 'rails_helper'

module Admiralty
  RSpec.describe DashboardController, type: :controller do
    routes { Engine.routes }
    render_views

    before do
      allow_any_instance_of(AdmiraltyAuth::AuthorizedController).to receive(:authenticate!).and_return(true)
      FactoryBot.create_list(:shipments_shipment_request, 10)
      FactoryBot.create_list(:quotations_quotation, 10)
    end

    describe 'GET #index' do
      it 'renders page' do
        get :index
        expect(response).to be_successful
      end
    end
  end
end
