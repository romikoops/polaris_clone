# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Legacy::ExchangeHelper do
  let(:base) { 'EUR' }
  let(:tenant) { FactoryBot.create(:legacy_tenant) }

  describe '.sum_and_convert' do
    it 'sums and converts the hash object sent' do
      currency_input = { 'USD' => 3.34 }
      result = described_class.sum_and_convert(currency_input, base)
      expect(result.round.cents).to eq(265)
    end

    it 'adds to the value if the hash key is the base' do
      currency_input = { 'EUR' => 3.34 }
      expect(described_class.sum_and_convert(currency_input, base)).to eq(Money.new(334, base))
    end
  end

  describe '.convert' do
    it 'converts correctly one currency to the other using the live results' do
      value = 12
      from_currency = 'USD'
      to_currency = 'CNY'
      result = described_class.convert(value, from_currency, to_currency)
      expect(result).to eq(Money.new((value * 7.1 * 100.0), to_currency))
    end

    it 'converts correctly if the from and to currency are the same' do
      value = 12
      from_currency = 'USD'
      to_currency = 'USD'
      result = described_class.convert(value, from_currency, to_currency)
      expect(result).to eq(Money.new(1200, to_currency))
    end
  end

  describe '.sum_and_convert_cargo' do
    it 'converts correctly using the charge in the input object sent' do
      input_hash = { 'USD' => { 'currency' => 'USD', 'value' => 12 } }
      result = described_class.sum_and_convert_cargo(input_hash, base)
      expect(result.round.cents).to eq(952)
    end

    it 'converts correctly using the charge in the input object sent (with Base currency)' do
      currency_input = { 'EUR' => { 'currency' => 'EUR', 'value' => 12 } }
      result = described_class.sum_and_convert_cargo(currency_input, base)
      expect(result).to eq(Money.new(1200, base))
    end
  end
end
