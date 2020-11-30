# frozen_string_literal: true

require "rails_helper"

module Profiles
  RSpec.describe ProfileDecorator do
    let(:user) { FactoryBot.create(:organizations_user) }
    let(:profile) do
      FactoryBot.build(:profiles_profile,
        first_name: "Guest",
        last_name: "User",
        company_name: "IMC",
        user: user)
    end

    describe "base methods" do
      it "returns the full name of the associated profile" do
        expect(described_class.new(profile).full_name).to eq("Guest User")
      end

      it "returns the full name and company name of the associated profile" do
        expect(described_class.new(profile).full_name_and_company).to eq("Guest User, IMC")
      end

      context "when user is present" do
        it "returns the email of the associated profiles attached user" do
          expect(described_class.new(profile).email).to eq(user.email)
        end
      end

      context "when user is not present" do
        let(:user) { nil }

        it "returns the email of the associated profiles attached user" do
          expect(described_class.new(profile).email).to eq("")
        end
      end
    end
  end
end
