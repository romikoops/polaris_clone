# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::LineItemDecorator do
  let(:charge_category) { FactoryBot.create(:bas_charge) }
  let(:line_item) { FactoryBot.create(:quotations_line_item, charge_category: charge_category) }
  let(:scope) { { fee_detail: 'key_and_name' }.with_indifferent_access }

  describe '.decorate' do
    let(:decorated_line_item) { described_class.new(line_item, context: { scope: scope }) }

    context 'with fee_detail = key_and_name' do
      it 'decorates the line item with the correct name' do
        aggregate_failures do
          expect(decorated_line_item.description).to eq('BAS - Ocean Freight Rate')
        end
      end

      it 'returns the right total amount for the line item' do
        aggregate_failures do
          expect(decorated_line_item.total.amount).to eq(0.30)
        end
      end
    end

    context 'with fee_detail = key' do
      let(:scope) do
        { fee_detail: 'key' }.with_indifferent_access
      end

      it 'decorates the line item with the correct name' do
        aggregate_failures do
          expect(decorated_line_item.description).to eq('BAS')
        end
      end
    end

    context 'with fee_detail = name' do
      let(:scope) do
        { fee_detail: 'name' }.with_indifferent_access
      end

      it 'decorates the line item with the correct name' do
        aggregate_failures do
          expect(decorated_line_item.description).to eq('Ocean Freight Rate')
        end
      end
    end

    context 'when trucking' do
      let(:line_item) { FactoryBot.create(:quotations_line_item, charge_category: charge_category, section: 1) }

      it 'decorates the line item with the correct name' do
        aggregate_failures do
          expect(decorated_line_item.description).to eq('Trucking Rate')
        end
      end
    end

    context 'with fee_detail = key_and_name & fine_fee_detail' do
      let(:scope) do
        { fee_detail: 'key_and_name', fine_fee_detail: true }.with_indifferent_access
      end

      it 'decorates the line item with the correct name' do
        aggregate_failures do
          expect(decorated_line_item.description).to eq('BAS - Basic Ocean Freight')
        end
      end
    end

    context 'with fee_detail = key_and_name & fine_fee_detail & unknown fee' do
      let(:scope) do
        { fee_detail: 'key_and_name', fine_fee_detail: true }.with_indifferent_access
      end
      let(:charge_category) { FactoryBot.create(:legacy_charge_categories, code: 'unknown_bas', name: 'Ocean Freight') }

      it 'decorates the line item with the correct name' do
        aggregate_failures do
          expect(decorated_line_item.description).to eq('BAS - Ocean Freight')
        end
      end
    end

    context 'with fee_detail = key and name and consolidated cargo scope' do
      let(:scope) do
        { fee_detail: 'key_and_name', consolidated_cargo: true }.with_indifferent_access
      end

      it 'decorates the line item with the correct name' do
        aggregate_failures do
          expect(decorated_line_item.description).to eq('BAS - Consolidated Freight Rate')
        end
      end
    end
  end
end
