# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReapplyCorrectExchangeRatesWorker, type: :worker do
  let!(:datetime) { DateTime.parse("2021/03/20T14:00:00UTC") }
  let(:result) { FactoryBot.build(:journey_result, line_item_sets: [line_item_set]) }
  let(:line_item_set) { FactoryBot.build(:journey_line_item_set, line_items: [line_item]) }
  let(:line_item) { FactoryBot.build(:journey_line_item, total_currency: "EUR", created_at: datetime) }
  let!(:exchange_rate) do
    FactoryBot.create(:treasury_exchange_rate,
      rate: 1.1,
      to: "USD",
      from: "EUR",
      created_at: datetime.beginning_of_day + 2.hours)
  end

  describe "perform" do
    before do
      FactoryBot.create(:journey_result_set, results: [result], currency: "USD", created_at: datetime)
      described_class.new.perform
    end

    it "sets the correct rate on the Line Item from the Exchange rate that was valid at the time" do
      expect(line_item.reload.exchange_rate).to eq(exchange_rate.rate)
    end
  end
end
