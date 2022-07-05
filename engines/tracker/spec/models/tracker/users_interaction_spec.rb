# frozen_string_literal: true

require "rails_helper"

module Tracker
  RSpec.describe UsersInteraction, type: :model do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:params) { { client_id: user_client.id, interaction_id: tracker_interaction.id } }
    let(:tracker_interaction) { Tracker::Interaction.create(organization_id: organization.id, name: "profiles") }

    let(:user_client) { FactoryBot.create(:users_client, organization_id: organization.id) }

    before { ::Organizations.current_id = organization.id }

    context "with valid params" do
      it "builds a valid interaction" do
        expect(described_class.new(params)).to be_valid
      end
    end

    context "when interactions for the other organizations exist" do
      let(:tracker_interaction_tutorial) { Tracker::Interaction.create!(organization_id: FactoryBot.create(:organizations_organization).id, name: "tutorials") }

      before do
        described_class.create(params)
        described_class.create({ client_id: user_client.id, interaction_id: tracker_interaction_tutorial.id })
      end

      it "returns the interactions for the current organization" do
        expect(described_class.pluck(:name)).not_to include("tutorial")
      end
    end
  end
end
