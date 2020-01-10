# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Legacy::CurrencyTools do
  let(:currency_converter) { described_class.new }
  let(:base) { 'EUR' }
  let(:tenant) { FactoryBot.create(:legacy_tenant) }

  before do
    %w[EUR USD BIF AED].each do |currency|
      stub_request(:get, "http://data.fixer.io/latest?access_key=&base=#{currency}")
        .to_return(status: 200, body: { rates: { AED: 4.11, BIF: 1.1456, EUR: 1.34 } }.to_json, headers: {})
    end
  end

  describe '.get_rates' do
    it 'returns the new rates' do
      result = currency_converter.get_rates(base, tenant.id)
      expect(result.today['AED']).to eq(4.11)
    end
  end

  describe '.get_currency_array' do
    it 'returns an array containing the rates' do
      result = currency_converter.get_currency_array(base, tenant.id)
      expect(result.first[:key]).to eq(base)
    end
  end

  describe '.sum_and_convert' do
    it 'sums and converts the hash object sent' do
      currency_input = { 'AED' => 3.34 }
      expect(currency_converter.sum_and_convert(currency_input, base, tenant.id)).to eq(0.8126520681265206)
    end

    it 'adds to the value if the hash key is the base' do
      currency_input = { 'EUR' => 3.34 }
      expect(currency_converter.sum_and_convert(currency_input, base, tenant.id)).to eq(3.34)
    end
  end

  describe '.convert' do
    it 'converts correctly one currency to the other using the live results' do
      value = 12
      from_currency = 'AED'
      to_currency = 'BIF'
      result = currency_converter.convert(value, from_currency, to_currency, tenant.id)
      expect(result).to eq((value * (1 / 4.11)))
    end

    it 'converts correctly if the from and to currency are the same' do
      value = 12
      from_currency = 'AED'
      to_currency = 'AED'
      result = currency_converter.convert(value, from_currency, to_currency, tenant.id)
      expect(result).to eq(12)
    end
  end

  describe '.sum_and_convert_cargo' do
    it 'converts correctly using the charge in the input object sent' do
      input_hash = { 'AED' => { 'currency' => 'AED', 'value' => 12 } }
      result = currency_converter.sum_and_convert_cargo(input_hash, base, tenant.id)
      expect(result).to eq(2.9197080291970803)
    end

    it 'converts correctly using the charge in the input object sent (with Base currency)' do
      currency_input = { 'EUR' => { 'currency' => 'EUR', 'value' => 12 } }
      result = currency_converter.sum_and_convert_cargo(currency_input, base, tenant.id)
      expect(result).to eq(12)
    end
  end

  describe '.refresh_rates_array' do
    let(:base) { 'EUR' }

    it 'returns the refreshed rates of the base currency in an array' do
      result = currency_converter.refresh_rates_array(base, tenant.id)
      expect(result.last[:key]).to eq('EUR')
    end

    it 'updates the database with updated rates' do
      mock = double(today: { EUR: 123 })

      allow(mock).to receive(:update).with(anything)
      allow(Legacy::Currency).to receive(:find_by).with(base: base, tenant_id: tenant.id).and_return(mock)

      currency_converter.refresh_rates_array(base, tenant.id)
    end
  end
end
