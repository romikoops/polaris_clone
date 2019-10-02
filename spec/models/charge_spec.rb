# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Charge, type: :model do
  schedule_charge = {
    'total' => { 'value' => '248.3048190554238675', 'currency' => 'USD' },
    'cargo' => { '43' => { 'BAS' => { 'value' => '0.0', 'currency' => 'USD' }, 'HAS' => { 'value' => 0, 'currency' => 'USD' }, 'total' => { 'value' => '0.0', 'currency' => 'USD' } }, 'total' => { 'value' => '0.0', 'currency' => 'USD' } },
    'export' => { 'SC' => { 'value' => 50.0, 'currency' => 'SEK' }, 'DOC' => { 'value' => '395.0', 'currency' => 'SEK' }, 'HDF' => { 'value' => 80.0, 'currency' => 'SEK' }, 'HDL' => { 'value' => '650.0', 'currency' => 'SEK' }, 'THC' => { 'value' => 395.0, 'currency' => 'SEK' }, 'VGM' => { 'value' => '25.0', 'currency' => 'USD' }, 'ISPS' => { 'value' => '5.0', 'currency' => 'EUR' }, 'total' => { 'value' => '210.8882307364988775', 'currency' => 'USD' } },
    'import' => {},
    'trucking_on' => {},
    'trucking_pre' => { 'total' => { 'value' => '326.34', 'currency' => 'SEK' }, 'stackable' => { 'value' => '326.34', 'currency' => 'SEK' }, 'non_stackable' => {} }
  }
  context 'class methods' do
    context '.create_from_schedule_charges' do
      it 'creates base node (grand_total)' do
        described_class.create_from_schedule_charges(schedule_charge, create(:charge_breakdown))
        expect(ChargeBreakdown.last.charge('grand_total')).to be_a(Charge)
      end

      it 'creates detail level 1 charges' do
        described_class.create_from_schedule_charges(schedule_charge, create(:charge_breakdown))

        categories = ChargeBreakdown.last.charge_categories.detail(1)
        expect(categories).not_to be_empty
        categories.each do |category|
          expect(ChargeBreakdown.last.charge(category.code)).to be_a(Charge)
        end
      end

      it 'creates detail level 2 charges' do
        described_class.create_from_schedule_charges(schedule_charge, create(:charge_breakdown))

        categories = ChargeBreakdown.last.charge_categories.detail(2)
        expect(categories).not_to be_empty
        categories.each do |category|
          expect(ChargeBreakdown.last.charge(category.code)).to be_a(Charge)
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: charges
#
#  id                          :bigint           not null, primary key
#  parent_id                   :integer
#  price_id                    :integer
#  charge_category_id          :integer
#  children_charge_category_id :integer
#  charge_breakdown_id         :integer
#  detail_level                :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  edited_price_id             :integer
#  sandbox_id                  :uuid
#
