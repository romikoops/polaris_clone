# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserServices::Client, type: :model do
  let(:user) { FactoryBot.create(:user_services_client) }

  it "builds a valid user" do
    expect(user).to be_valid
  end

  context "when a user is created" do
    it "creates the associated group memberships" do
      expect(user.group_memberships).to be_present
    end

    it "creates the associated company membership" do
      expect(user.company_membership).to be_present
    end
  end

  it "when a user is destroyed, the associated group membership are destroyed" do
    group_membership_id = user.group_memberships.first.id
    user.destroy
    expect { Groups::Membership.find(group_membership_id) }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  it "when a user is destroyed, the associated company memberships are destroyed" do
    company_membership_id = user.company_membership.id
    user.destroy
    expect { Companies::Membership.find(company_membership_id) }.to raise_exception(ActiveRecord::RecordNotFound)
  end

  context "when the destroyed user is recovered" do
    before do
      user.destroy
    end

    it "when a user is restored, the associated client profile are restored" do
      user.restore
      expect(user.profile).to be_present
    end

    it "when a user is restored, the associated group membership are restored" do
      user.restore
      expect(user.group_memberships).to be_present
    end

    it "when a user is restored, the associated company memberships are restored" do
      user.restore
      expect(user.company_membership).to be_present
    end
  end
end
