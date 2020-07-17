# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TenderCalculator::TenderLineItems do
  let(:section) { FactoryBot.create(:rates_section) }
  let(:descorated_section) { RateExtractor::Decorators::SectionRate.new(section) }
  let!(:quotation) { FactoryBot.create(:quotations_quotation) }
  let(:cargo) { FactoryBot.create(:cargo_cargo, quotation_id: quotation.id) }
  let(:cargo_unit) { FactoryBot.create(:lcl_unit, quantity: 1, cargo: cargo) }

  let(:shipment_targeted_rate) { FactoryBot.create(:rate_extractor_cargo_rate, :shipment_targeted_rate, section: section) }
  let(:section_targeted_rate) { FactoryBot.create(:rate_extractor_cargo_rate, :section_targeted_rate, section: section) }
  let(:cargo_targeted_rate) { FactoryBot.create(:rate_extractor_cargo_rate, :cargo_targeted_rate, :with_target, cargo: cargo_unit, section: section) }

  let!(:shipment_based_fee) { FactoryBot.create(:rates_fee, :shipment_basis, cargo: shipment_targeted_rate.object, percentage: 0.10) }
  let!(:section_based_fee) { FactoryBot.create(:rates_fee, :shipment_basis, cargo: section_targeted_rate.object, percentage: 0.15) }
  let!(:cargo_based_fee) { FactoryBot.create(:cbm_based_fee, cargo: cargo_targeted_rate.object, amount_cents: 250) }
  let(:tender_line_items) { described_class.new(section_rates: [section]) }

  let(:line_items) { tender_line_items.build }
  let(:root) { line_items.root }
  let(:sections) { root.children }
  let(:cargos) { sections[0].children }

  before do
    descorated_section.cargos = [shipment_targeted_rate, section_targeted_rate, cargo_targeted_rate]
  end

  context 'when initialized by section rates' do
    it 'builds a tree with root as the addition of all shipment topmost line items' do
      expect(root).to be_a(TenderCalculator::ParentMap)
    end

    it 'builds shipment percentages as children of the root shipment addition (the root)' do
      shipment_percentage = root.children.first
      percentage_on = shipment_percentage.children.find { |child| !child.is_a? TenderCalculator::Value }.values

      aggregate_failures do
        expect(root.children.count).to eq 1
        expect(shipment_percentage.children.map(&:class)).to match([TenderCalculator::Value, TenderCalculator::Multiplication])
        expect(shipment_percentage.values).to eq(percentage_on.map { |i| i * shipment_based_fee.percentage })
      end
    end

    it 'builds section percentages as children of the parent shipment percentages' do
      section_percentage = root.children.first.children.find { |node| node.is_a?(TenderCalculator::Multiplication) }
      percentage_on = section_percentage.children.find { |child| !child.is_a? TenderCalculator::Value }.values

      aggregate_failures do
        expect(section_percentage.children.count).to eq 2
        expect(section_percentage.children.map(&:class)).to match([TenderCalculator::Value, TenderCalculator::ParentMap])
        expect(section_percentage.values).to eq(percentage_on.map { |i| i * section_based_fee.percentage })
      end
    end

    it 'builds cargo flat line items as children of the parent section percentages' do
      section_percentage = root.children.first.children.find { |node| node.is_a?(TenderCalculator::Multiplication) }
      cargo_rate_branch = section_percentage.children.find { |node| node.is_a?(TenderCalculator::ParentMap) }
      cargo_line_item_amount = cargo_based_fee.amount * cargo_unit.volume_value

      aggregate_failures do
        expect(cargo_rate_branch.children.count).to eq 1
        expect(cargo_rate_branch.values).to eq [cargo_line_item_amount]
      end
    end
  end

  context 'when multiple currencies' do
    let(:cargo_based_eur_rate) { FactoryBot.create(:rate_extractor_cargo_rate, :cargo_targeted_rate, :with_target, cargo: cargo_unit, section: section) }
    let!(:eur_fee) { FactoryBot.create(:cbm_based_fee, cargo: cargo_based_eur_rate.object, amount_cents: 150, amount_currency: :eur) }

    let(:cargo_based_usd_rate) { FactoryBot.create(:rate_extractor_cargo_rate, :cargo_targeted_rate, :with_target, cargo: cargo_unit, section: section) }
    let!(:usd_fee) { FactoryBot.create(:cbm_based_fee, cargo: cargo_based_usd_rate.object, amount_cents: 300, amount_currency: :usd) }

    let(:section_percentage) { root.children.first.children.find { |node| node.is_a?(TenderCalculator::Multiplication) } }
    let(:cargo_rate_branch) { section_percentage.children.find { |node| node.is_a?(TenderCalculator::ParentMap) } }

    before do
      descorated_section.cargos = [shipment_targeted_rate, section_targeted_rate, cargo_based_eur_rate, cargo_based_usd_rate]
    end

    it 'builds cargo node as multiple currency node' do
      cargo_line_item_amounts = [usd_fee.amount * cargo_unit.volume_value, eur_fee.amount * cargo_unit.volume_value]
      section_line_items_amounts = cargo_line_item_amounts.map { |i| i * section_based_fee.percentage }
      shipment_line_items_amounts = section_line_items_amounts.map { |i| i * shipment_based_fee.percentage }

      aggregate_failures do
        expect(cargo_rate_branch.values).to match_array cargo_line_item_amounts
        expect(section_percentage.values).to match_array section_line_items_amounts
        expect(root.values).to match_array shipment_line_items_amounts
      end
    end
  end
end
