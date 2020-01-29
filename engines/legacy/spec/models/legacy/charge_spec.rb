# frozen_string_literal: true

require 'rails_helper'
module Legacy
  RSpec.describe Charge, type: :model do
    describe 'instance methods' do
      let(:charge) { FactoryBot.create(:legacy_charge) }
      let!(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }

      before do
        FactoryBot.create(:legacy_charge, parent: charge)
        stub_request(:get, 'http://data.fixer.io/latest?access_key=&base=EUR')
          .to_return(status: 200, body: { rates: { EUR: 1, USD: 1.26 } }.to_json)
      end

      it 'updats quote price' do
        expect(charge.update_price!).to be true
      end

      it 'updates edited price' do
        expect(charge.update_edited_price!).to be true
      end

      it 'updates dup tree' do
        pending('we have due circular reference between Legacy and Pricing engines')
        charge_breakdown = FactoryBot.create(:legacy_charge_breakdown)
        expect(charge.dup_tree(charge_breakdown: charge_breakdown)).to be true
      end
    end
  end
end

# == Schema Information
#
# Table name: charges
#
#  id                          :bigint           not null, primary key
#  detail_level                :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  charge_breakdown_id         :integer
#  charge_category_id          :integer
#  children_charge_category_id :integer
#  edited_price_id             :integer
#  parent_id                   :integer
#  price_id                    :integer
#  sandbox_id                  :uuid
#
# Indexes
#
#  index_charges_on_sandbox_id  (sandbox_id)
#
