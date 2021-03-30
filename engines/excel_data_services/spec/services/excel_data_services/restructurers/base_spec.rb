# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Restructurers::Base do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { { organization: organization, data: data } }

  describe ".restructure" do
    let(:data) { { some_data: 123 } }

    it "passes the data on without restructuring" do
      expect(described_class.restructure(options)).to eq("Unknown" => data)
    end
  end
end
