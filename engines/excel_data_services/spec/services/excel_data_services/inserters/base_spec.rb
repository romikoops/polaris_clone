# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::Base do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:data) {}
  let(:options) { {organization: organization, data: data, options: {}} }

  describe ".get" do
    it "finds the correct child class" do
      expect(described_class.get("Pricing")).to eq(ExcelDataServices::Inserters::Pricing)
    end
  end

  describe ".insert" do
    it "raises a NotImplementedError" do
      expect { described_class.insert(options) }.to raise_error(NotImplementedError)
    end
  end
end
