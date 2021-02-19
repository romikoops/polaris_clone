# frozen_string_literal: true

require "rails_helper"

RSpec.describe Wheelhouse::ExcelWriterService do
  include_context "journey_pdf_setup"
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:offer) do
    FactoryBot.create(:journey_offer, query: query, line_item_sets: result.line_item_sets)
  end

  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:writer) { described_class.new(offer: offer) }

  before do
    FactoryBot.create(:treasury_exchange_rate, from: "EUR", to: "USD", rate: 1.3, created_at: result.created_at - 30.seconds)
    ::Organizations.current_id = organization.id
    writer.quotation_sheet
  end

  describe ".quotation_sheet" do
    context "with tender ids" do
      it "creates the specified tender worksheets, summary and attaches the file to result" do
        aggregate_failures do
          expect(writer.work_book.sheets.count).to eq(2)
          expect(writer.work_book.sheets.first.name).to eq("Summary")
        end
      end
    end
  end
end
