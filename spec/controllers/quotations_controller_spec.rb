require 'rails_helper'

RSpec.describe QuotationsController, type: :controller do

  let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
  let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization_id: organization.id) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: 'public') }
  let(:token_header) { "Bearer #{access_token.token}" }

  before do
    request.headers['Authorization'] = token_header
  end

  describe 'GET #show' do
    let(:shipment) do
      FactoryBot.create(
        :completed_legacy_shipment,
        with_breakdown: true,
        with_tenders: true,
        organization_id: organization.id,
        user: user
      )
    end

    context 'when successful quotation ' do
      let(:quotation) { FactoryBot.create(:quotations_quotation, legacy_shipment_id: shipment.id) }

      it 'renders error code and message' do
        get :show, params: {organization_id: organization.id, id: quotation.id}

        expect(json.dig(:data, :quotationId)).to eq quotation.id
      end
    end

    context 'when async error has occurred ' do
      let(:quotation) { FactoryBot.create(:quotations_quotation, error_class: "OfferCalculator::Errors::LoadMeterageExceeded") }

      it 'renders error code and message' do
        get :show, params: {organization_id: organization.id, id: quotation.id}

        aggregate_failures do
          expect(json.dig(:code)).to eq(3002)
          expect(json.dig(:message)).to eq "Your shipment has exceeded the load meterage limits for online booking."
        end
      end
    end
  end
end
