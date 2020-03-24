# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Quotations::TenderUpdater do
  describe '#perform' do
    let(:tender) { FactoryBot.create(:quotations_tender) }
    let(:charge_breakdown) { FactoryBot.create(:legacy_charge_breakdown, tender_id: tender.id) }

    context 'when the charge is of detail level 0' do
      subject(:updater) do
        described_class.new(tender: tender,
                            line_item_id: nil,
                            charge_category_id: level_0_charge.children_charge_category_id,
                            value: 50,
                            section: 'cargo')
      end

      let(:level_0_charge) { charge_breakdown.charges.find_by(detail_level: 0) }

      before do
        updater.perform
      end

      it 'updates the edited price of the charge' do
        expect(updater.charge.edited_price.money).to eq Money.new(5000.0, level_0_charge.price.currency)
      end

      it 'updates grand total of the breakdown' do
        expect(charge_breakdown.grand_total.edited_price.money).to eq Money.new(5000.0, level_0_charge.price.currency)
      end

      it 'updates the tender amount' do
        expect(tender.amount).to eq Money.new(5000.0, level_0_charge.price.currency)
      end
    end

    context 'when the charge is of detail level 1' do
      subject(:updater) do
        described_class.new(tender: tender,
                            line_item_id: nil,
                            charge_category_id: level_1_charge.children_charge_category_id,
                            value: 50,
                            section: 'cargo')
      end

      let(:level_1_charge) { charge_breakdown.charges.find_by(detail_level: 1) }

      before do
        updater.perform
      end

      it 'updates the edited price of the charge' do
        expect(updater.charge.edited_price.money).to eq Money.new(5000.0, level_1_charge.price.currency)
      end

      it 'updates grand total of the breakdown' do
        expect(charge_breakdown.grand_total.edited_price.money).to eq Money.new(5000.0, level_1_charge.price.currency)
      end

      it 'updates the tender amount' do
        expect(tender.amount).to eq Money.new(5000.0, level_1_charge.price.currency)
      end
    end

    context 'when the charge is of detail level 2' do
      subject(:updater) do
        described_class.new(tender: tender,
                            line_item_id: nil,
                            charge_category_id: level_2_charge.children_charge_category_id,
                            value: 50,
                            section: 'cargo')
      end

      let(:level_2_charge) { charge_breakdown.charges.find_by(detail_level: 2) }

      before do
        updater.perform
      end

      it 'updates the edited price of the charge' do
        expect(updater.charge.edited_price.money).to eq Money.new(5000.0, level_2_charge.price.currency)
      end

      it 'updates grand total of the breakdown' do
        expect(charge_breakdown.grand_total.edited_price.money).to eq Money.new(5000.0, level_2_charge.price.currency)
      end

      it 'updates the tender amount' do
        expect(tender.amount).to eq Money.new(5000.0, level_2_charge.price.currency)
      end
    end

    context 'when the charge is of detail level 3' do
      subject(:updater) do
        described_class.new(tender: line_item.tender,
                            line_item_id: line_item.id,
                            charge_category_id: line_item.charge_category_id,
                            value: 50,
                            section: level_3_charge.parent.charge_category.code)
      end

      let(:level_3_charge) { charge_breakdown.charges.find_by(detail_level: 3) }
      let(:line_item) do
        FactoryBot.create(:quotations_line_item,
                          tender: tender,
                          charge_category: level_3_charge.children_charge_category,
                          cargo: charge_breakdown.shipment.cargo_units.first)
      end

      before do
        updater.perform
      end

      it 'updates the edited price of the charge' do
        expect(updater.charge.edited_price.money).to eq Money.new(5000.0, level_3_charge.price.currency)
      end

      it 'updates grand total of the breakdown' do
        expect(charge_breakdown.grand_total.edited_price.money).to eq Money.new(5000.0, level_3_charge.price.currency)
      end

      it 'updates the tender amount' do
        expect(tender.amount).to eq Money.new(5000.0, level_3_charge.price.currency)
      end

      it 'updates the specified line item' do
        expect(updater.line_item.amount).to eq Money.new(5000.0, level_3_charge.price.currency)
      end
    end

    context 'when there are two charges of the same charge category' do
      let(:container_1) { FactoryBot.build(:fcl_40_container) }
      let(:container_2) { FactoryBot.build(:fcl_20_container) }
      let(:shipment) { FactoryBot.create(:legacy_shipment, with_tenders: true, with_breakdown: true, containers: [container_1, container_2]) }
      let(:breakdown) { shipment.charge_breakdowns.first }
      let(:tender) { breakdown.tender }
      let(:line_item) { tender.line_items.find_by(cargo: container_1) }
      let(:level_3_charge) { breakdown.charges.find_by(detail_level: 3, children_charge_category: line_item.charge_category) }

      subject(:updater) do
        described_class.new(tender: tender,
                            line_item_id: line_item.id,
                            charge_category_id: line_item.charge_category_id,
                            value: 50,
                            section: level_3_charge.parent.charge_category.code)
      end

      before do
        breakdown.update(tender_id: tender.id)
        updater.perform
      end

      it 'updates the edited price of the charge of the specific cargo charge' do
        expect(updater.charge.edited_price.money).to eq Money.new(5000.0, level_3_charge.price.currency)
      end

      it 'does not update the edited price of the charge of unspecified cargo charge' do
        unupdated_charge_category = breakdown.charge_categories.where(cargo_unit_id: container_2)
        expect(breakdown.charges.where(detail_level: 3, charge_category: unupdated_charge_category).first.edited_price).to be_nil
      end
    end
  end
end
