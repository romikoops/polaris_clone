# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChargeBreakdown, type: :model do
  context 'instance methods' do
    let(:charge_breakdown)          { create(:charge_breakdown) }
    let(:price)                     { create(:price) }

    let!(:charge) do
      create(
        :charge,
        charge_breakdown: charge_breakdown,
        charge_category: ChargeCategory.base_node,
        children_charge_category: ChargeCategory.grand_total,
        price: price
      )
    end

    context '.charges.from_category' do
      it 'returns a collection of charges' do
        result = charge_breakdown.charges.from_category(ChargeCategory.base_node.code)
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

# == Schema Information
#
# Table name: charge_breakdowns
#
#  id          :bigint           not null, primary key
#  shipment_id :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  trip_id     :integer
#  sandbox_id  :uuid
#  valid_until :datetime
#
