# frozen_string_literal: true

require "rails_helper"

RSpec.describe ResultFormatter::ClientDecorator do
  include_context "organization"
  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:scope) { { default_currency: "EUR" } }
  let(:decorated_client) { described_class.new(client, context: { scope: scope }) }
  let(:profile) { decorated_client.profile }

  describe ".profile" do
    it "returns the clients profile" do
      expect(profile).to eq(client.profile)
    end

    context "when the profile is deleted" do
      before { client.profile.destroy }

      it "returns a new clients profile" do
        expect(profile).to be_a(Users::ClientProfile)
      end
    end
  end
end
