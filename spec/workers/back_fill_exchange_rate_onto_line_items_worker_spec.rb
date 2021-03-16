require 'rails_helper'
RSpec.describe BackFillExchangeRateOntoLineItemsWorker, type: :worker do
  let!(:todays_datetime) { DateTime.parse("2021/03/02T14:00:00UTC") }
  let!(:yesterday_datetime) { DateTime.parse("2021/03/01T14:00:00UTC") }
  let!(:january_datetime) { DateTime.parse("2021/01/01T14:00:00UTC") }

  let!(:todays_result_set) { FactoryBot.create(:journey_result_set, results: [todays_result], currency: 'USD', created_at: todays_datetime) }
  let!(:yesterday_result_set) { FactoryBot.create(:journey_result_set, results: [yesterday_result], currency: 'USD', created_at: yesterday_datetime) }
  let!(:january_result_set) { FactoryBot.create(:journey_result_set, results: [january_result], currency: 'USD', created_at: january_datetime) }

  let(:todays_result) { FactoryBot.build(:journey_result, line_item_sets: [todays_line_item_set]) }
  let(:yesterday_result) { FactoryBot.build(:journey_result, line_item_sets: [yesterday_line_item_set]) }
  let(:january_result) { FactoryBot.build(:journey_result, line_item_sets: [january_line_item_set]) }

  let(:todays_line_item_set) { FactoryBot.build(:journey_line_item_set, line_items: [todays_line_item]) }
  let(:yesterday_line_item_set) { FactoryBot.build(:journey_line_item_set, line_items: [yesterday_line_item]) }
  let(:january_line_item_set) { FactoryBot.build(:journey_line_item_set, line_items: [january_line_item]) }

  let(:todays_line_item) { FactoryBot.build(:journey_line_item, total_currency: 'EUR', created_at: todays_datetime) }
  let(:yesterday_line_item) { FactoryBot.build(:journey_line_item, total_currency: 'EUR', created_at: yesterday_datetime) }
  let(:january_line_item) { FactoryBot.build(:journey_line_item, total_currency: 'EUR', created_at: january_datetime) }

  let!(:todays_exchange_rate) {
    FactoryBot.create(:treasury_exchange_rate,
      rate: 1.1,
      to: 'USD',
      from: 'EUR',
      created_at: todays_datetime.beginning_of_day + 2.hours)
  }
  let!(:yesterday_exchange_rate) {
    FactoryBot.create(:treasury_exchange_rate,
      rate: 1.2,
      to: 'USD',
      from: 'EUR',
      created_at: yesterday_datetime.beginning_of_day + 2.hours)
  }
  let!(:january_exchange_rate) {
    FactoryBot.create(:treasury_exchange_rate,
      rate: 1.3,
      to: 'USD',
      from: 'EUR',
      created_at: january_datetime + 2.hours)
  }


  describe "perform" do
    before { described_class.new.perform }

    it "sets the correct rate on the Line Item from the Exchange rate that was valid at the time", :aggregate_failures do
      expect(todays_line_item.reload.exchange_rate).to eq(todays_exchange_rate.rate)
      expect(yesterday_line_item.reload.exchange_rate).to eq(yesterday_exchange_rate.rate)
      expect(january_line_item.reload.exchange_rate).to eq(january_exchange_rate.rate)
    end
  end
end
