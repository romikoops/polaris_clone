# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExcelDataServices::Inserters::Companies do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:options) { { organization: organization, data: input_data, options: {} } }
  let(:address) { FactoryBot.create(:gothenburg_address) }
  let(:input_data) do
    [{
      name: "Test Company",
      email: "test@company.com",
      phone: "1234567879",
      vat_number: "987654321",
      address_id: address.id,
      payment_terms: "Show me the money!"
    }]
  end
  let(:result_company) { Companies::Company.find_by(organization: organization, name: input_data.first[:name]) }

  describe ".insert" do
    # rubocop:disable Rails/SkipsModelValidations
    let(:stats) { described_class.insert(options) }
    # rubocop:enable Rails/SkipsModelValidations

    it "inserts correctly and returns correct stats", :aggregate_failures do
      expect(stats[:'companies/companies'][:number_created]).to eq(1)
      expect(result_company.payment_terms).to eq(input_data.first[:payment_terms])
    end

    context "without payment_terms" do
      let(:input_data) do
        [{
          name: "Test Company",
          email: "test@company.com",
          phone: "1234567879",
          vat_number: "987654321",
          address_id: address.id,
          payment_terms: nil
        }]
      end

      it "inserts correctly and returns correct stats", :aggregate_failures do
        expect(stats[:'companies/companies'][:number_created]).to eq(1)
        expect(result_company.payment_terms).to be_blank
      end
    end
  end
end
