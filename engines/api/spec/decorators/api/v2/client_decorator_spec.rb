# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::ClientDecorator do
  let(:user) { FactoryBot.create(:users_client, profile: profile) }
  let(:profile) { FactoryBot.build(:users_client_profile) }
  let(:decorated_user) { described_class.new(user) }

  describe ".decorate" do
    context "with profile" do
      it "returns the first name" do
        expect(decorated_user.first_name).to eq(user.profile.first_name)
      end

      it "returns the last name" do
        expect(decorated_user.last_name).to eq(user.profile.last_name)
      end

      it "returns the company name" do
        expect(decorated_user.company_name).to eq(user.profile.company_name)
      end

      it "returns the phone" do
        expect(decorated_user.phone).to eq(user.profile.phone)
      end

      it "returns the profile" do
        expect(decorated_user.profile).to eq(user.profile)
      end
    end

    context "with profile that has no company_name" do
      let(:profile) { FactoryBot.build(:users_client_profile, company_name: nil) }

      it "returns the empty company name string" do
        expect(decorated_user.company_name).to eq("")
      end
    end
  end
end
