# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ColliTypesController, type: :controller do
    routes { Engine.routes }

    let!(:organization) { FactoryBot.create(:organizations_organization) }
    let(:legacy_cargo_item_type_pallet) { FactoryBot.create(:legacy_cargo_item_type, category: "Pallet") }
    let(:legacy_cargo_item_type_drum) { FactoryBot.create(:legacy_cargo_item_type, category: "Drum") }

    describe "GET #show" do
      before do
        FactoryBot.create(:legacy_tenant_cargo_item_type, organization: organization, cargo_item_type: legacy_cargo_item_type_pallet)
        FactoryBot.create(:legacy_tenant_cargo_item_type, organization: organization, cargo_item_type: legacy_cargo_item_type_drum)
      end

      it "successfully returns colli types for the organization" do
        get :show, params: { organization_id: organization.id }, as: :json
        expect(response_data).to match_array(%w[pallet drum])
      end
    end
  end
end
