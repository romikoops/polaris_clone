# frozen_string_literal: true

require 'rails_helper'

module AdmiraltyReports
  RSpec.describe StatsController, type: :controller do
    routes { Engine.routes }
    render_views
    let(:organization_1) { FactoryBot.create(:organizations_organization, slug: 'demo1') }
    let(:organization_2) { FactoryBot.create(:organizations_organization, slug: 'demo2')}
    before do
      allow_any_instance_of(AdmiraltyAuth::AuthorizedController).to receive(:authenticate!).and_return(true)
      FactoryBot.create(:organizations_scope, target: organization_1, content: { 'open_quotation_tool' => true })
      FactoryBot.create(:organizations_scope, target: organization_2, content: { 'open_quotation_tool' => false })
    end

    describe 'GET #index' do
      it 'renders page' do
        get :download
        expect(response).to be_successful
      end
    end
  end
end
