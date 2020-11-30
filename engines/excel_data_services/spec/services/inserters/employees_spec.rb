# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::Employees do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { {organization: organization, data: input_data, options: {}} }
  let(:input_data) do
    [{
      first_name: "Test",
      last_name: "User",
      email: "testuser@itsmycargo.com",
      password: "password",
      phone: "123456789"
    }]
  end

  before do
    stub_request(:get, "https://fonts.googleapis.com/css?family=Ubuntu:300,400,500,700")
      .to_return(status: 200, body: "", headers: {})
    FactoryBot.create(:organizations_theme, organization: organization)
  end

  describe ".insert" do
    it "inserts correctly and returns correct stats" do
      stats = described_class.insert(options)
      expect(stats[:'organizations/users'][:number_created]).to eq(1)
    end
  end
end
