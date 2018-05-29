# frozen_string_literal: true

require 'rails_helper'


describe ChargeBreakdown, type: :model do
  context 'instance methods' do
    let(:charge_breakdown)          { create(:charge_breakdown) }
    let(:charge_category)           { create(:charge_category) }
    let(:children_charge_category)  { create(:charge_category, code: 'export', name: 'Export') }
    let(:price)                     { create(:price) }

    let!(:charge) {
      create(:charge,
        charge_breakdown: charge_breakdown,
        charge_category: charge_category,
        children_charge_category: children_charge_category,
        price: price
      )
    }

    context '.charges.from_category' do
      it 'returns a collection of charges' do
        result = charge_breakdown.charges.from_category(charge_category.code)
        expect(result).not_to be_empty
        expect(result).to all be_a Charge
      end
    end

    context '.charge_categories.detail' do
      it 'returns a collection of charge categories' do
        result = charge_breakdown.charge_categories.detail(0)
        expect(result).not_to be_empty
        expect(result).to all be_a ChargeCategory
      end
    end
  end
end
