# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExchangeRate, type: :model do
  it "creates a valid object" do
    expect(FactoryBot.build(:exchange_rate)).to be_valid
  end

  context "class methods" do
    let(:currencies) { %w[USD AUD GBP] }
    let(:base) { "EUR" }
    let(:prior_rate_dates) { [2.days.ago, 1.day.ago] }

    before do
      prior_rate_dates.each do |timestamp|
        currencies.each do |currency|
          FactoryBot.create(:exchange_rate, from: base, to: currency, created_at: timestamp)
        end
      end
    end

    describe "self.current" do
      let!(:desired_currencies) do
        currencies.map do |currency|
          FactoryBot.create(:exchange_rate, from: base, to: currency)
        end
      end

      it "returns the latest exchanges rates uniq by pair" do
        expect(described_class.current).to match_array(desired_currencies)
      end
    end

    describe "self.for_date" do
      let(:date) { 60.minutes.ago }
      let!(:desired_currencies) do
        currencies.map do |currency|
          FactoryBot.create(:exchange_rate, from: base, to: currency, created_at: 61.minutes.ago)
        end
      end

      it "returns the latest exchanges rates uniq by pair" do
        expect(described_class.for_date(date: date)).to match_array(desired_currencies)
      end
    end
  end
end

# == Schema Information
#
# Table name: exchange_rates
#
#  id         :bigint           not null, primary key
#  from       :string
#  rate       :decimal(, )
#  to         :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_exchange_rates_on_from  (from)
#  index_exchange_rates_on_to    (to)
#
