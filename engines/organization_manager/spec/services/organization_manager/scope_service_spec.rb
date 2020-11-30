# frozen_string_literal: true

require "rails_helper"

RSpec.describe OrganizationManager::ScopeService do
  describe "#fetch" do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:company) { FactoryBot.create(:companies_company, organization: organization) }
    let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
    let!(:member) { FactoryBot.create(:companies_membership, member: user, company: company) }

    let(:content) { {} }

    let(:scope) { described_class.new(target: user) }

    before do
      FactoryBot.create(:organizations_scope, target: user, content: content)
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
  end
end
