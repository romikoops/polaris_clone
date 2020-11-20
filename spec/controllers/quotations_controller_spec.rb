require "rails_helper"

RSpec.describe QuotationsController, type: :controller do
  include_context "organization"

  let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization_id: organization.id) }
  let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
  let(:token_header) { "Bearer #{access_token.token}" }
  let(:shipment) do
    FactoryBot.create(
      :completed_legacy_shipment,
      with_breakdown: true,
      with_tenders: true,
      organization_id: organization.id,
      user: user
    )
  end
  let(:quotation) { Quotations::Quotation.find_by(legacy_shipment_id: shipment.id) }

  before do
    request.headers["Authorization"] = token_header
    shipment.charge_breakdowns.map(&:tender).each do |tender|
      Legacy::ExchangeRate.create(from: tender.amount.currency.iso_code,
                                  to: "USD", rate: 1.3,
                                  created_at: tender.created_at - 30.seconds)
    end
  end

  describe "GET #show" do
    context "when successful quotation " do
      it "renders error code and message" do
        get :show, params: {organization_id: organization.id, id: quotation.id}

        expect(json.dig(:data, :quotationId)).to eq quotation.id
      end
    end

    context "when async error has occurred " do
      let(:quotation) {
        FactoryBot.create(:quotations_quotation, error_class: "OfferCalculator::Errors::LoadMeterageExceeded")
      }

      it "renders error code and message" do
        get :show, params: {organization_id: organization.id, id: quotation.id}

        aggregate_failures do
          expect(json.dig(:code)).to eq(3002)
          expect(json.dig(:message)).to eq "Your shipment has exceeded the load meterage limits for online booking."
        end
      end
    end
  end

  describe "GET #download_pdf" do
    context "when successful quotation " do
      it "renders error code and message" do
        get :download_pdf, params: {organization_id: organization.id, id: shipment.id}

        expect(json.dig(:data, :url)).to include("quotation_#{shipment.imc_reference}")
      end
    end
  end
end
