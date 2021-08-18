# frozen_string_literal: true

require "rails_helper"

module Companies
  RSpec.describe Company, type: :model do
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:user) { FactoryBot.create(:users_client, organization: organization) }
    let(:company) { FactoryBot.create(:companies_company, organization: organization) }

    it "builds a valid company" do
      expect(company).to be_valid
    end

    it "sets the payment_terms field to nil, when it is an empty string" do
      expect(FactoryBot.create(:companies_company, payment_terms: "", organization: organization).payment_terms).to be_nil
    end

    it "sets the payment_terms field to the current value provided" do
      expect(FactoryBot.create(:companies_company, payment_terms: "foo_bar", organization: organization).payment_terms).to eq("foo_bar")
    end
  end
end
