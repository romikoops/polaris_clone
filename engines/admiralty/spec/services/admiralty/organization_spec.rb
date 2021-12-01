# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admiralty::Organization, type: :model do
  let(:organization) { FactoryBot.create(:admiralty_organization) }
  let!(:shop_admin_user) { FactoryBot.create(:users_user, email: "shopadmin@itsmycargo.com") }

  before do
    FactoryBot.create(:legacy_cargo_item_type, description: "Pallet")
    organization
  end

  describe "#create_shop_defaults" do
    it "creates default group" do
      expect(Groups::Group.find_by(name: "default", organization: organization)).to be_present
    end

    it "creates user membership with shopadmin" do
      expect(Users::Membership.find_by(user: shop_admin_user, organization: organization)).to be_present
    end
  end
end
