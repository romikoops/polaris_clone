# frozen_string_literal: true

require "rails_helper"

RSpec.describe BackFillExchangeRateOntoLineItemsWorker, type: :worker do
  let!(:todays_datetime) { DateTime.parse("2021/03/02T14:00:00UTC") }
  let!(:yesterday_datetime) { DateTime.parse("2021/03/01T14:00:00UTC") }
  let!(:january_datetime) { DateTime.parse("2021/01/01T14:00:00UTC") }

  let(:todays_query) { FactoryBot.build(:journey_query, created_at: todays_datetime) }
  let(:yesterday_query) { FactoryBot.build(:journey_query, created_at: yesterday_datetime) }
  let(:january_query) { FactoryBot.build(:journey_query, created_at: january_datetime) }

  let(:todays_result_set) { FactoryBot.build(:journey_result_set, query: todays_query, currency: "USD", created_at: todays_datetime) }
  let(:yesterday_result_set) { FactoryBot.build(:journey_result_set, query: yesterday_query, currency: "USD", created_at: yesterday_datetime) }
  let(:january_result_set) { FactoryBot.build(:journey_result_set, query: january_query, currency: "USD", created_at: january_datetime) }

  let(:todays_result) { FactoryBot.build(:journey_result, result_set: todays_result_set) }
  let(:yesterday_result) { FactoryBot.build(:journey_result, result_set: yesterday_result_set) }
  let(:january_result) { FactoryBot.build(:journey_result, result_set: january_result_set) }

  let(:todays_line_item_set) { FactoryBot.build(:journey_line_item_set, result: todays_result) }
  let(:yesterday_line_item_set) { FactoryBot.build(:journey_line_item_set, result: yesterday_result) }
  let(:january_line_item_set) { FactoryBot.build(:journey_line_item_set, result: january_result) }

  let(:todays_route_section) { FactoryBot.build(:journey_route_section, result: todays_result) }
  let(:yesterday_route_section) { FactoryBot.build(:journey_route_section, result: yesterday_result) }
  let(:january_route_section) { FactoryBot.build(:journey_route_section, result: january_result) }

  let!(:todays_line_item) { FactoryBot.create(:journey_line_item, route_section: todays_route_section, line_item_set: todays_line_item_set, total_currency: "EUR", created_at: todays_datetime) }
  let!(:yesterday_line_item) { FactoryBot.create(:journey_line_item, route_section: yesterday_route_section, line_item_set: yesterday_line_item_set, total_currency: "EUR", created_at: yesterday_datetime) }
  let!(:january_line_item) { FactoryBot.create(:journey_line_item, route_section: january_route_section, line_item_set: january_line_item_set, total_currency: "EUR", created_at: january_datetime) }

  let!(:todays_exchange_rate) do
    FactoryBot.create(:treasury_exchange_rate,
      rate: 1.1,
      to: "USD",
      from: "EUR",
      created_at: todays_datetime.beginning_of_day + 2.hours)
  end
  let!(:yesterday_exchange_rate) do
    FactoryBot.create(:treasury_exchange_rate,
      rate: 1.2,
      to: "USD",
      from: "EUR",
      created_at: yesterday_datetime.beginning_of_day + 2.hours)
  end
  let!(:january_exchange_rate) do
    FactoryBot.create(:treasury_exchange_rate,
      rate: 1.3,
      to: "USD",
      from: "EUR",
      created_at: january_datetime.beginning_of_day + 2.hours)
  end

  describe "perform" do
    before { described_class.new.perform }

    it "sets the correct rate on the Line Item from the Exchange rate that was valid at the time", :aggregate_failures do
      expect(todays_line_item.reload.exchange_rate).to eq(todays_exchange_rate.rate)
      expect(yesterday_line_item.reload.exchange_rate).to eq(yesterday_exchange_rate.rate)
      expect(january_line_item.reload.exchange_rate).to eq(january_exchange_rate.rate)
    end
  end
end
