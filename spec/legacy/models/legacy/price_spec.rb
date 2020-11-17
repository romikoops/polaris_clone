# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe Price, type: :model do
    let(:price) { FactoryBot.build(:legacy_price) }

    context 'when building it returns a valid object' do
      it 'must be valid' do
        expect(price.valid?).to be(true)
      end
    end

    context 'with money gem methods' do
      describe '.money' do
        it 'returns the currency and value as a money object' do
          expect(price.money).to eq(Money.new(999, 'EUR'))
        end
      end

      describe '.money=' do
        it 'sets the currency and value from a money object' do
          price.money = Money.new(1999, 'USD')
          aggregate_failures do
            expect(price.value).to eq(19.99)
            expect(price.currency).to eq('USD')
          end
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: prices
#
#  id         :bigint           not null, primary key
#  currency   :string
#  value      :decimal(, )
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sandbox_id :uuid
#
# Indexes
#
#  index_prices_on_sandbox_id  (sandbox_id)
#
