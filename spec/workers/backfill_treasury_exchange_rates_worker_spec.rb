require 'rails_helper'

RSpec.describe BackfillTreasuryExchangeRatesWorker, type: :worker do
  let(:legacy_exchange_rates) { FactoryBot.create_list(:legacy_exchange_rate, 5) }
  let(:new_exchange_rates) { Treasury::ExchangeRate.all }

  before {
    legacy_exchange_rates.pluck(:from).each do |currency|
      FactoryBot.create(:quotations_line_item, amount_currency: currency)
    end
    described_class.new.perform
   }

  describe '.perform' do
    it 'clones the existing Legacy::ExchangeRates', :aggregate_failures do
      expect(new_exchange_rates.pluck(:from)).to match_array(legacy_exchange_rates.pluck(:from))
      expect(new_exchange_rates.pluck(:to)).to match_array(legacy_exchange_rates.pluck(:to))
      expect(new_exchange_rates.pluck(:rate)).to match_array(legacy_exchange_rates.pluck(:rate))
    end
  end
end
