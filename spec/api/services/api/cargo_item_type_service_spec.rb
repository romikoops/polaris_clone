# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe CargoItemTypeService, type: :service do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:organization_group) { Organizations::Group.create(organization: organization) }
    let(:user) {
      FactoryBot.create(:organizations_user, email: "test@example.com",
                                             password: "veryspeciallysecurehorseradish", organization: organization)
    }
    let(:access_token) { Doorkeeper::AccessToken.create(resource_owner_id: user.id, scopes: "public") }
    let(:token_header) { "Bearer #{access_token.token}" }
    let(:cargo_item_type) { FactoryBot.create(:legacy_cargo_item_type) }

    before do
      FactoryBot.create(:legacy_tenant_cargo_item_type, organization: organization, cargo_item_type: cargo_item_type)
    end

    describe ".perform" do
      it "returns all the cargo item types" do
        results = described_class.new(organization: organization).perform

        expect(results.first.id).to eq(cargo_item_type.id)
      end
    end
  end
end
