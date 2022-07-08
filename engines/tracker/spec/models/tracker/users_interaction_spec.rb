# frozen_string_literal: true

require "rails_helper"

module Tracker
  RSpec.describe UsersInteraction, type: :model do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:params) { { client_id: user_client.id, interaction_id: tracker_interaction.id } }
    let(:tracker_interaction) { Tracker::Interaction.create(name: "profiles") }

    let(:user_client) { FactoryBot.create(:users_client, organization_id: organization.id) }

    before { ::Organizations.current_id = organization.id }

    context "with valid params" do
      it "builds a valid interaction" do
        expect(described_class.new(params)).to be_valid
      end
    end

    context "when trying to create interactions with the same name" do
      it "returns the interactions for the current organization" do
        tracker_interaction
        expect { Tracker::Interaction.create!(name: "profiles") }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end
end
