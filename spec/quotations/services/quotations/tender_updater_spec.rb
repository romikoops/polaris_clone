# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Quotations::TenderUpdater do
  describe '#perform' do
    let(:tender) { FactoryBot.create(:quotations_tender) }
    let(:charge_breakdown) { FactoryBot.create(:legacy_charge_breakdown, tender_id: tender.id) }
    let(:organization) { FactoryBot.create(:organizations_organization) }
    let(:level_3_charge) { charge_breakdown.charges.find_by(detail_level: 3) }

    context 'when the charge is of detail level 3' do
      subject(:updater) do
        described_class.new(tender: line_item.tender,
                            line_item_id: line_item.id,
                            charge_category_id: line_item.charge_category_id,
                            value: 50,
                            section: level_3_charge.parent.charge_category.code)
      end
      let(:original_value) { charge_breakdown.grand_total.price.money }
      let!(:original_tender_value) { tender.amount }
      let(:line_item) do
        FactoryBot.create(:quotations_line_item,
                          tender: tender,
                          amount: original_value,
                          original_amount: original_value,
                          charge_category: level_3_charge.children_charge_category,
                          cargo: charge_breakdown.shipment.cargo_units.first)
      end

      before do
        level_3_charge.price.update(currency: 'USD')
        level_3_charge.update(line_item_id: line_item.id)
        updater.perform
      end

      it 'updates the edited price of the charge' do
        expect(updater.charge.edited_price.money).to eq Money.new(5000.0, level_3_charge.price.currency)
      end

      it 'updates grand total of the breakdown' do
        expect(charge_breakdown.grand_total.edited_price.money).to eq Money.new(5000.0, level_3_charge.price.currency).exchange_to(original_value.currency)
      end

      it 'updates the tender amount' do
        aggregate_failures do
          expect(tender.amount).to eq Money.new(5000.0, level_3_charge.price.currency).exchange_to('USD')
          expect(tender.original_amount).to eq original_tender_value
        end
      end

      it 'updates the specified line item' do
        aggregate_failures do
          expect(updater.line_item.amount).to eq Money.new(5000.0, level_3_charge.price.currency)
          expect(updater.line_item.original_amount).to eq Money.new(original_value)
        end
      end
    end

    context 'when there are two charges of the same charge category' do
      let(:container_1) { FactoryBot.build(:fcl_40_container) }
      let(:container_2) { FactoryBot.build(:fcl_20_container) }
      let(:shipment) { FactoryBot.create(:legacy_shipment, with_tenders: true, organization: organization, with_breakdown: true, containers: [container_1, container_2]) }
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
        level_3_charge.update(line_item_id: line_item.id)
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

    context 'when the charge is of detail level 3 and consolidated cargo' do
      subject(:updater) do
        described_class.new(tender: line_item.tender,
                            line_item_id: line_item.id,
                            charge_category_id: line_item.charge_category_id,
                            value: 50,
                            section: level_3_charge.parent.charge_category.code)
      end

      let(:level_3_charge) { charge_breakdown.charges.find_by(detail_level: 3) }
      let(:original_value) { Money.new(1000, 'EUR') }
      let!(:original_tender_value) { tender.amount }
      let(:line_item) do
        FactoryBot.create(:quotations_line_item,
                          tender: tender,
                          amount: original_value,
                          original_amount: original_value,
                          charge_category: level_3_charge.children_charge_category,
                          cargo: nil)
      end

      before do
        level_3_charge.update(line_item_id: line_item.id)
        charge_breakdown.charge_categories.where(code: 'container').update_all(cargo_unit_id: nil)
        updater.perform
      end

      it 'updates the edited price of the charge' do
        expect(updater.charge.edited_price.money).to eq Money.new(5000.0, level_3_charge.price.currency)
      end

      it 'updates grand total of the breakdown' do
        expect(charge_breakdown.grand_total.edited_price.money).to eq Money.new(5000.0, level_3_charge.price.currency)
      end

      it 'updates the tender amount' do
        aggregate_failures do
          expect(tender.amount).to eq Money.new(5000.0, level_3_charge.price.currency)
          expect(tender.original_amount).to eq original_tender_value
        end
      end

      it 'updates the specified line item' do
        aggregate_failures do
          expect(updater.line_item.amount).to eq Money.new(5000.0, level_3_charge.price.currency)
          expect(updater.line_item.original_amount).to eq Money.new(original_value)
        end
      end
    end

    context 'when the charge is of detail level 3 and uneditable (included)' do
      subject(:updater) do
        described_class.new(tender: line_item.tender,
                            line_item_id: line_item.id,
                            charge_category_id: line_item.charge_category_id,
                            value: 50,
                            section: level_3_charge.parent.charge_category.code)
      end

      let(:invalid_charge_category) { FactoryBot.create(:legacy_charge_categories, organization: organization, code: 'included_baf') }
      let(:line_item) do
        FactoryBot.create(:quotations_line_item,
                          tender: tender,
                          charge_category: invalid_charge_category,
                          cargo: charge_breakdown.shipment.cargo_units.first)
      end

      before do
        level_3_charge.update(children_charge_category: invalid_charge_category)
      end

      it 'raises an error' do
        expect { updater.perform }.to raise_error Quotations::TenderUpdater::UneditableFee
      end
    end

    context 'when the charge is of detail level 3 and uneditable (excluded)' do
      subject(:updater) do
        described_class.new(tender: line_item.tender,
                            line_item_id: line_item.id,
                            charge_category_id: line_item.charge_category_id,
                            value: 50,
                            section: level_3_charge.parent.charge_category.code)
      end

      let(:line_item) do
        FactoryBot.create(:quotations_line_item,
                          tender: tender,
                          charge_category: level_3_charge.children_charge_category,
                          cargo: charge_breakdown.shipment.cargo_units.first)
      end

      before do
        level_3_charge.children_charge_category.update(code: 'excluded_baf')
      end

      it 'raises an error' do
        expect { updater.perform }.to raise_error Quotations::TenderUpdater::UneditableFee
      end
    end

    context 'when the charge is of detail level 3 and uneditable (unknown)' do
      subject(:updater) do
        described_class.new(tender: line_item.tender,
                            line_item_id: line_item.id,
                            charge_category_id: line_item.charge_category_id,
                            value: 50,
                            section: level_3_charge.parent.charge_category.code)
      end

      let(:line_item) do
        FactoryBot.create(:quotations_line_item,
                          tender: tender,
                          charge_category: level_3_charge.children_charge_category,
                          cargo: charge_breakdown.shipment.cargo_units.first)
      end

      before do
        level_3_charge.children_charge_category.update(code: 'unknown_baf')
      end

      it 'raises an error' do
        expect { updater.perform }.to raise_error Quotations::TenderUpdater::UneditableFee
      end
    end
  end
end
