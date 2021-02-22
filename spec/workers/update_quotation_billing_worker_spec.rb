# frozen_string_literal: true
require "rails_helper"

RSpec.describe UpdateQuotationBillingWorker, type: :worker do
  let!(:errored_quotation) { FactoryBot.create(:quotations_quotation, completed: nil, error_class: "StandardError") }
  let!(:empty_quotation) { FactoryBot.create(:quotations_quotation, completed: nil) }
  let!(:unset_quotation) do
    FactoryBot.create(:quotations_quotation,
      tenders: [FactoryBot.build(:quotations_tender)],
      completed: nil)
  end

  before do
    described_class.new.perform
  end

  it "sets completed tag on Quotations" do
    expect(Quotations::Quotation.exists?(completed: nil)).to be(false)
  end
end
