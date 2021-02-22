# frozen_string_literal: true
require "rails_helper"

module Treasury
  RSpec.describe ExchangeRate, type: :model do
    it "creates a valid object" do
      expect(FactoryBot.build(:exchange_rate)).to be_valid
    end

    context "class methods" do
      let(:currencies) { %w[USD AUD GBP] }
      let(:base) { "EUR" }

      before do
        [2.days.ago, 1.day.ago, 30.minutes.ago].each do |timestamp|
          currencies.each do |currency|
            FactoryBot.create(:treasury_exchange_rate, from: base, to: currency, created_at: timestamp)
          end
        end
      end

      describe "self.current" do
        let!(:current_currencies) do
          currencies.map do |currency|
            FactoryBot.create(:treasury_exchange_rate, from: base, to: currency)
          end
        end

        it "returns the latest exchanges rates uniq by pair" do
          expect(described_class.current).to match_array(current_currencies)
        end
      end

      describe "self.for_date" do
        let(:date) { 1.month.ago }
        let!(:desired_currencies) do
          currencies.map do |currency|
            FactoryBot.create(:treasury_exchange_rate, from: base, to: currency, created_at: 1.month.ago + 1.minute)
          end
        end

        it "returns the exchanges rates uniq by pair for the given date" do
          expect(described_class.for_date(date: date)).to match_array(desired_currencies)
        end
      end
    end
  end
end
