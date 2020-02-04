# frozen_string_literal: true

require 'rails_helper'

module Legacy
  RSpec.describe ChargeBreakdown, type: :model do
    context 'instance methods' do
      let(:charge_breakdown) { FactoryBot.create(:legacy_charge_breakdown) }
      let(:price) { FactoryBot.create(:legacy_price) }
      let(:grand_total_category) { ChargeCategory.find_by(code: 'grand_total') }

      let(:charge) do
        FactoryBot.create(
          :legacy_charge,
          charge_breakdown: charge_breakdown,
          charge_category: ChargeCategory.base_node,
          children_charge_category: ChargeCategory.grand_total,
          price: price
        )
      end

      describe '.charges.from_category' do
        it 'returns a collection of charges' do
          result = charge_breakdown.charges.from_category(ChargeCategory.base_node.code)

          expect(result).not_to be_empty
          expect(result).to all be_a Charge
        end
      end

      describe '.charge_categories.detail' do
        it 'returns a collection of charge categories' do
          result = charge_breakdown.charge_categories.detail(0)

          expect(result).not_to be_empty
          expect(result).to all be_a ChargeCategory
        end
      end

      describe '.selected' do
        before do
          charge.touch
        end

        it 'selects' do
          expect(described_class.selected).to match(charge_breakdown)
        end
      end

      describe '.charge' do
        it 'gets charge' do
          charges = charge_breakdown.charge(charge.charge_category.code)
          expect(charges).to be_nil
        end
      end

      describe '.grand_total' do
        it 'gets grand_total' do
          result = charge_breakdown.grand_total
          expect(result).to eq(
            Charge.find_by(
              charge_breakdown_id: charge_breakdown.id,
              children_charge_category: grand_total_category
            )
          )
        end
      end

      describe '.grand_total=' do
        it 'sets grand_total' do
          charge_breakdown.grand_total = charge
          expect(charge_breakdown.charges).to include(charge)
        end
      end

      describe '.to_nested_hash' do
        it 'gets nested_hash' do
          expected = {
            'total' => { 'value' => 0.999e1, 'currency' => 'EUR' },
            'edited_total' => nil,
            'name' => 'Grand Total',
            'cargo' =>
          { 'total' => { 'value' => 0.999e1, 'currency' => 'EUR' },
            'edited_total' => nil,
            'name' => 'Cargo',
            'legacy/container' =>
            { 'total' => { 'value' => 0.999e1, 'currency' => 'EUR' },
              'edited_total' => nil,
              'name' => 'Legacy::container',
              'bas' => { 'currency' => 'EUR', 'sandbox_id' => nil, 'value' => 0.999e1, 'name' => 'Basic Freight' } } },
            'trip_id' => 2107
          }

          expect(charge_breakdown.to_nested_hash['cargo']).to eq(expected['cargo'])
        end
      end

      describe '#dup_charges' do
        it 'duplicate the charges' do
          pending('we have due circular reference between Legacy and Pricing engines')
          second_charge_breakdown = FactoryBot.create(:legacy_charge_breakdown)
          charge_breakdown.dup_charges(charge_breakdown: second_charge_breakdown)
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: charge_breakdowns
#
#  id          :bigint           not null, primary key
#  valid_until :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  sandbox_id  :uuid
#  shipment_id :integer
#  trip_id     :integer
#
# Indexes
#
#  index_charge_breakdowns_on_sandbox_id  (sandbox_id)
#
