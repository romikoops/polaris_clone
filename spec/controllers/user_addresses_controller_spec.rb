# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserAddressesController do
  describe "GET #index" do
    let(:org_user) { FactoryBot.create(:organizations_user) }
    let(:organization) { org_user.organization }
    let(:user) { org_user.becomes(Authentication::User) }

    let(:addresses) { FactoryBot.create_list(:address, 5) }

    before do
      ::Organizations.current_id = organization.id
      addresses.each do |address|
        FactoryBot.create(:legacy_user_address, user: org_user, address: address)
      end
    end

    it "returns http success" do
      get :index, params: {organization_id: organization.id, user_id: user.id}

      expect(JSON.parse(response.body).dig("data").count).to eq addresses.count
    end
  end
end
