# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationManager::ScopeService do
  describe "#fetch" do
    let(:organization) { FactoryBot.create(:organizations_organization, scope: organizations_scope) }
    let(:organizations_scope) { FactoryBot.build(:organizations_scope, content: content) }
    let(:company) { FactoryBot.create(:companies_company, organization: organization) }
    let(:user) { FactoryBot.create(:users_client, organization: organization) }
    let!(:member) { FactoryBot.create(:companies_membership, member: user, company: company) }

    let(:content) { {} }

    let(:scope) { described_class.new(target: user, organization: organization) }

    before do
      Organizations.current_id = organization.id
    end

    context "when no key given" do
      it "returns the entire correct scope" do
        expect(scope.fetch).to eq(Organizations::DEFAULT_SCOPE)
      end
    end

    context "when key given" do
      let(:content) { {foo: "bar"} }

      it "returns correct value of the correct scope" do
        expect(scope.fetch(:foo)).to eq("bar")
      end
    end

    context "when merging scopes" do
      before do
        FactoryBot.create(:organizations_scope, target: company, content: {foo: "baz"})
      end

      it "returns combined scope" do
        expect(scope.fetch(:foo)).to eq("baz")
      end
    end

    context "with default scope values present on multiple levels" do
      let(:default_content) { Organizations::DEFAULT_SCOPE }
      let(:content) { default_content }

      before do
        FactoryBot.create(:organizations_scope, target: company, content: default_content.merge({default_direction: "export"}))
      end

      it "returns the highest value in the hierarchy" do
        expect(scope.fetch(:default_direction)).to eq("export")
      end
    end
  end
end
