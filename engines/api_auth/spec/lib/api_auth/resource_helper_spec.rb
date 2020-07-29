# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApiAuth::ResourceHelper do
  let(:organization) { FactoryBot.create(:organizations_organization) }

  before do
    Organizations.current_id = organization.id
  end

  describe ".resource_for_login" do
    context "when bridge is true" do
      before do
        allow(Authentication::User).to receive(:with_membership)
        FactoryBot.create(:organizations_user, organization: organization)
      end

      let(:client) { double("client", name: "bridge") }

      it "returns Authentication::User with the with_membership" do
        described_class.resource_for_login(client: client)

        expect(Authentication::User).to have_received(:with_membership)
      end
    end

    context "when bridge is false" do
      before do
        allow(Authentication::User).to receive(:authentication_scope)
      end

      let(:client) { nil }

      it "returns Authentication::User " do
        described_class.resource_for_login(client: client)

        expect(Authentication::User).to have_received(:authentication_scope)
      end
    end
  end
end
