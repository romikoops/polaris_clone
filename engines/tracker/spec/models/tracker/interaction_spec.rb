# frozen_string_literal: true

require "rails_helper"

module Tracker
  RSpec.describe Interaction, type: :model do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:params) { { organization_id: organization.id, name: "profiles" } }

    before { ::Organizations.current_id = organization.id }

    context "with valid params" do
      it "builds a valid interaction" do
        expect(described_class.new(params)).to be_valid
      end
    end

    context "when interaction with the same name exists for an organization" do
      before do
        described_class.create(params)
      end

      it "raises validation error" do
        expect { described_class.create!(params) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when interactions for the other organizations exist" do
      before do
        described_class.create(params)
        described_class.create(organization_id: FactoryBot.create(:organizations_organization).id, name: "tutorial")
      end

      it "returns the interactions for the current organization" do
        expect(described_class.all.pluck(:name)).not_to include("tutorial")
      end
    end
  end
end
