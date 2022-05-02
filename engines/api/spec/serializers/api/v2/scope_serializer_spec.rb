# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V2::ScopeSerializer do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:scope) { Api::Scope.new(content: Organizations::DEFAULT_SCOPE) }
    let(:serialized_scope) { described_class.new(scope).serializable_hash }
    let(:target) { serialized_scope.dig(:data, :attributes) }

    before { Organizations.current_id = organization.id }

    shared_examples_for "it Returns scope based attributes" do
      it "returns the correct scope based attributes", :aggregate_failures do
        expect(target[:links]).to eq(Organizations::DEFAULT_SCOPE["links"])
        expect(target[:loginMandatory]).to eq(Organizations::DEFAULT_SCOPE["closed_shop"])
        expect(target[:loginSamlText]).to eq(Organizations::DEFAULT_SCOPE["saml_text"])
        expect(target[:registrationProhibited]).to eq(Organizations::DEFAULT_SCOPE["closed_registration"])
      end
    end

    context "when saml is not enabled" do
      it_behaves_like "it Returns scope based attributes"

      it "returns false when no Saml data exists", :aggregate_failures do
        expect(target[:authMethods]).to eq(["password"])
      end
    end

    context "when saml is enabled" do
      before { FactoryBot.create(:organizations_saml_metadatum, organization: organization) }

      it_behaves_like "it Returns scope based attributes"

      it "returns true when no Saml data exists", :aggregate_failures do
        expect(target[:authMethods]).to eq(%w[password saml])
      end
    end
  end
end
