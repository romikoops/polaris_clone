# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::V2::ProfileDecorator do
  let(:user) { FactoryBot.create(:users_client, profile: profile) }
  let(:profile) { FactoryBot.build(:users_client_profile) }
  let(:decorated_profile) { described_class.new(profile) }
  let(:company) { FactoryBot.create(:companies_company, organization: user.organization) }

  describe ".decorate" do
    context "with profile and company present" do
      before { FactoryBot.create(:companies_membership, client: user, company: company) }

      it "returns the first name" do
        expect(decorated_profile.first_name).to eq(profile.first_name)
      end

      it "returns the last name" do
        expect(decorated_profile.last_name).to eq(profile.last_name)
      end

      it "returns the company name" do
        expect(decorated_profile.company_name).to eq(company.name)
      end

      it "returns the phone" do
        expect(decorated_profile.phone).to eq(profile.phone)
      end

      it "returns the empty new_user as true" do
        expect(decorated_profile.new_user?).to eq(true)
      end
    end

    context "with profile that has no company_name" do
      let(:profile) { FactoryBot.build(:users_client_profile, company_name: nil) }

      it "returns the empty company name string" do
        expect(decorated_profile.company_name).to eq("")
      end
    end

    context "with the user has logged in to Siren before" do
      before do
        FactoryBot.create_list(:access_token, 5, application: application, resource_owner_id: user.id)
      end

      let(:decorated_profile) { described_class.new(profile, context: { application: application }) }
      let(:application) { FactoryBot.create(:application, name: "siren") }

      it "returns the empty new_user as false" do
        expect(decorated_profile.new_user?).to eq(false)
      end
    end
  end
end
