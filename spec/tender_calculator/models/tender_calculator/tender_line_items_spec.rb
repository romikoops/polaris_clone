# frozen_string_literal: true

require "rails_helper"

RSpec.describe TenderCalculator::TenderLineItems do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:section) { FactoryBot.create(:rates_section) }
  let(:descorated_section) { RateExtractor::Decorators::SectionRate.new(section) }
  let(:cargo_unit) { FactoryBot.create(:lcl_unit, quantity: 1) }
  let(:margins) { Rates::Margin.none }
  let(:discounts) { Rates::Discount.none }
  let!(:quotation) { FactoryBot.create(:quotations_quotation) }
  let(:cargo) { FactoryBot.create(:cargo_cargo, quotation_id: quotation.id) }
  let(:cargo_unit) { FactoryBot.create(:lcl_unit, quantity: 1, cargo: cargo) }
  let(:decorated_cargo) { RateExtractor::Decorators::Cargo.new(cargo) }

  let(:shipment_targeted_rate) {
    FactoryBot.create(:rate_extractor_cargo_rate, :shipment_targeted_rate, section: section)
  }
  let(:section_targeted_rate) {
    FactoryBot.create(:rate_extractor_cargo_rate, :section_targeted_rate, section: section)
  }
  let(:cargo_targeted_rate) {
    FactoryBot.create(:rate_extractor_cargo_rate, :cargo_targeted_rate, :with_target, cargo: cargo_unit,
                                                                                      section: section)
  }

  let!(:shipment_based_fee) {
    FactoryBot.create(:rates_fee, :percentage_basis, cargo: shipment_targeted_rate.object, percentage: 0.10)
  }
  let!(:section_based_fee) {
    FactoryBot.create(:rates_fee, :percentage_basis, cargo: section_targeted_rate.object, percentage: 0.15)
  }
  let!(:cargo_based_fee) { FactoryBot.create(:cbm_based_fee, cargo: cargo_targeted_rate.object, amount_cents: 25000) }
  let(:tender_line_items) {
    described_class.new(section_rates: [section], cargo: decorated_cargo, margins: margins, discounts: discounts)
  }

  let(:line_items) { tender_line_items.build }
  let(:root) { line_items.root }
  let(:sections) { root.children }
  let(:cargos) { sections[0].children }
  let(:cargo_line_item_amount) { cargo_based_fee.amount * cargo.total_volume.value }

  before do
    descorated_section.cargos = [shipment_targeted_rate, section_targeted_rate, cargo_targeted_rate]
  end

  context "when calculating buying rates" do
    it "builds a tree with root as the addition of all shipment top-most line items" do
      expect(root).to be_a(TenderCalculator::ParentMap)
    end

    it "builds shipment percentages as children of the root shipment addition (the root)" do
      shipment_percentage = root.children.first
      amount_with_percentage = Money.new(cargo_line_item_amount * 1.15 * 1.10, "USD")

      aggregate_failures do
        expect(root.children.count).to eq 1
        expect(
          shipment_percentage.children.map(&:class)
        ).to match([TenderCalculator::Multiplication, TenderCalculator::Addition])
        expect(shipment_percentage.values).to eq [amount_with_percentage]
      end
    end

    it "builds section percentages as children of the parent shipment percentages" do
      section_percentage = root.children.first.children.find { |node| node.is_a?(TenderCalculator::Addition) }
      amount_with_percentage = Money.new(cargo_line_item_amount * 1.15, "USD")

      aggregate_failures do
        expect(section_percentage.children.count).to eq 2
        expect(
          section_percentage.children.map(&:class)
        ).to match([TenderCalculator::Multiplication, TenderCalculator::ParentMap])
        expect(section_percentage.values).to eq [amount_with_percentage]
      end
    end

    it "builds cargo flat line items as children of the parent section percentages" do
      section_percentage = root.children.first.children.find { |node| node.is_a?(TenderCalculator::Addition) }
      cargo_rate_branch = section_percentage.children.find { |node| node.is_a?(TenderCalculator::ParentMap) }

      aggregate_failures do
        expect(cargo_rate_branch.children.count).to eq 1
        expect(cargo_rate_branch.values).to eq [cargo_line_item_amount]
      end
    end
  end

  context "when multiple currencies" do
    let(:cargo_based_eur_rate) {
      FactoryBot.create(:rate_extractor_cargo_rate, :cargo_targeted_rate, :with_target, cargo: cargo_unit,
                                                                                        section: section)
    }
    let!(:eur_fee) {
      FactoryBot.create(:cbm_based_fee, cargo: cargo_based_eur_rate.object, amount_cents: 150, amount_currency: :eur)
    }

    let(:cargo_based_usd_rate) {
      FactoryBot.create(:rate_extractor_cargo_rate, :cargo_targeted_rate, :with_target, cargo: cargo_unit,
                                                                                        section: section)
    }
    let!(:usd_fee) {
      FactoryBot.create(:cbm_based_fee, cargo: cargo_based_usd_rate.object, amount_cents: 300, amount_currency: :usd)
    }

    let(:section_percentage) { root.children.first.children.find { |node| node.is_a?(TenderCalculator::Addition) } }
    let(:cargo_rate_branch) { section_percentage.children.find { |node| node.is_a?(TenderCalculator::ParentMap) } }

    before do
      descorated_section.cargos = [
        shipment_targeted_rate, section_targeted_rate, cargo_based_eur_rate, cargo_based_usd_rate
      ]
    end

    it "builds cargo node as multiple currency node" do
      cargo_line_item_amounts = [usd_fee.amount * cargo_unit.volume_value, eur_fee.amount * cargo_unit.volume_value]
      section_line_items_amounts = cargo_line_item_amounts.map { |i| i * 1.15 }
      shipment_line_items_amounts = section_line_items_amounts.map { |i| i * 1.10 }

      aggregate_failures do
        expect(cargo_rate_branch.values).to match_array cargo_line_item_amounts
        expect(section_percentage.values).to match_array section_line_items_amounts
        expect(root.values).to match_array shipment_line_items_amounts
      end
    end
  end

  context "when flat margins apply on cargo rates" do
    let(:margins_arr) {
      FactoryBot.create_list(:rates_margin, 2, target: cargo_targeted_rate.object, operator: :addition,
                                               organization: organization, applicable_to: organization)
    }
    let(:margins) { Rates::Margin.where(id: margins_arr.map(&:id)) }

    it "applies the margins in the fee tree as bottom-most leaves" do
      section_percentage = root.children.first.children.find { |node| node.is_a?(TenderCalculator::Addition) }
      cargo_rate_branch = section_percentage.children.find { |node| node.is_a?(TenderCalculator::ParentMap) }
      margin_amounts = margins.map { |margin| margin.amount * cargo.total_volume.value }

      aggregate_failures do
        expect(cargo_rate_branch.children.count).to eq 1
        expect(cargo_rate_branch.values).to eq [cargo_line_item_amount, margin_amounts].flatten
      end
    end
  end

  context "when flat margins apply on a section rates" do
    let(:margins_arr) {
      FactoryBot.create_list(:rates_margin, 2, target: section, operator: :addition,
                                               organization: organization, applicable_to: organization)
    }
    let(:margins) { Rates::Margin.where(id: margins_arr.map(&:id)) }

    it "applies the margins as value children nodes of the section node" do
      section_with_margins = root.children.first.children.find { |node| node.is_a?(TenderCalculator::ParentMap) }
      section_margins = section_with_margins.children.select { |node| node.is_a?(TenderCalculator::Value) }
      margin_amounts = margins.map { |margin| margin.amount * cargo.total_volume.value }

      aggregate_failures do
        expect(section_with_margins.children.count).to eq 3
        expect(section_margins.map(&:values).flatten).to eq margin_amounts
      end
    end
  end

  context "when flat margins apply on shipment (no target)" do
    let(:margins_arr) {
      FactoryBot.create_list(:rates_margin, 2, operator: :addition, amount_cents: 100,
                                               organization: organization, applicable_to: organization)
    }
    let(:margins) { Rates::Margin.where(id: margins_arr.map(&:id)) }

    it "builds flat margins under the root node" do
      margin_amounts = margins.map { |margin| margin.amount * cargo.total_volume.value }

      aggregate_failures do
        expect(root.children.count).to eq 3
        expect(root.values).to include(margin_amounts.first, margin_amounts.last)
      end
    end
  end

  context "when percentage margins apply on a cargo rates" do
    let(:margins_arr) {
      FactoryBot.create_list(:rates_margin, 1, target: cargo_targeted_rate.object, operator: :multiplication,
                                               percentage: 0.20, organization: organization,
                                               applicable_to: organization)
    }
    let(:margins) { Rates::Margin.where(id: margins_arr.map(&:id)) }

    it "builds margin percentage nodes on top of the cargo node" do
      section_node = root.children.first.children.find { |node| node.is_a?(TenderCalculator::Addition) }
      margin_node = section_node.children.find { |node| node.is_a?(TenderCalculator::ParentMap) }
      amount_with_margin = Money.new(cargo_line_item_amount * 1.20, "USD")

      expect(margin_node.values).to eq [amount_with_margin]
    end
  end

  context "when percentage margins apply on section rates" do
    let(:margins_arr) {
      FactoryBot.create_list(:rates_margin, 1, target: section, operator: :multiplication, percentage: 0.10,
                                               organization: organization, applicable_to: organization)
    }
    let(:margins) { Rates::Margin.where(id: margins_arr.map(&:id)) }

    it "builds margin percentage nodes on top of the section node" do
      section_with_margins = root.children.first.children.find { |node| node.is_a?(TenderCalculator::Addition) }
      amount_with_margin = Money.new(cargo_line_item_amount * 1.15 * 1.10, "USD")

      expect(section_with_margins.values).to eq [amount_with_margin]
    end
  end

  context "when percentage margins apply on shipment (no target)" do
    let(:margins_arr) {
      FactoryBot.create_list(:rates_margin, 1, operator: :multiplication, percentage: 0.05,
                                               organization: organization, applicable_to: organization)
    }
    let(:margins) { Rates::Margin.where(id: margins_arr.map(&:id)) }

    it "builds shipment percentage margins as top most nodes" do
      percentage_on = root.children.find { |child| !child.is_a? TenderCalculator::Multiplication }.values.first
      aggregate_failures do
        expect(root.class).to eq TenderCalculator::Addition
        expect(root.values).to eq [percentage_on * 1.05]
      end
    end
  end

  context "when both percentage and flat margins apply on shipment (no target)" do
    let(:flat_margins) {
      FactoryBot.create_list(:rates_margin, 2, operator: :addition, amount_cents: 100,
                                               organization: organization, applicable_to: organization)
    }
    let(:percentage_margins) {
      FactoryBot.create_list(:rates_margin, 1, operator: :multiplication, percentage: 0.05,
                                               organization: organization, applicable_to: organization)
    }
    let(:margins) { Rates::Margin.where(id: [*flat_margins, *percentage_margins].map(&:id)) }

    it "builds flat margins on the same level of percentage margins" do
      margin_percentage_amount = Money.new(cargo_line_item_amount * 1.15 * 1.10 * 1.05, "USD")
      margin_flat_amounts = flat_margins.map { |margin| margin.amount * cargo.total_volume.value }

      aggregate_failures do
        expect(root.class).to eq TenderCalculator::ParentMap
        expect(root.values).to eq [margin_percentage_amount, *margin_flat_amounts]
      end
    end
  end

  context "when flat discounts apply on cargo rates" do
    let(:discounts_arr) {
      FactoryBot.create_list(:rates_discount, 2, target: cargo_targeted_rate.object, operator: :addition,
                                                 organization: organization, applicable_to: organization)
    }
    let(:discounts) { Rates::Discount.where(id: discounts_arr.map(&:id)) }

    it "applies flat discounts in the fee tree on top of the cargo nodes" do
      section_addition = root.children.first.children.find { |node| node.is_a?(TenderCalculator::Addition) }
      section_percentage = section_addition.children.find { |node| node.is_a?(TenderCalculator::ParentMap) }
      discount_node = section_percentage.children.find { |node| node.is_a?(TenderCalculator::AdditionMap) }
      after_discount = cargo_line_item_amount - (discounts.first.amount * cargo.total_volume.value * 2)

      expect(discount_node.values).to eq [after_discount]
    end
  end

  context "when flat discounts apply on section rates" do
    let(:discounts_arr) {
      FactoryBot.create_list(:rates_discount, 1, target: section, operator: :addition,
                                                 organization: organization, applicable_to: organization)
    }
    let(:discounts) { Rates::Discount.where(id: discounts_arr.map(&:id)) }

    it "applies the discounts as AddtionMap nodes on top of the section node" do
      raw_section_value = Money.new(cargo_line_item_amount * 1.15, "USD")

      section_with_discounts = root.children.first.children.find { |node| node.is_a?(TenderCalculator::AdditionMap) }
      after_discount = raw_section_value - (discounts.first.amount * cargo.total_volume.value)

      expect(section_with_discounts.values).to eq [after_discount]
    end
  end

  context "when flat discounts apply on shipment (no target)" do
    let(:discounts_arr) {
      FactoryBot.create_list(:rates_discount, 1, target: nil, operator: :addition,
                                                 organization: organization, applicable_to: organization)
    }
    let(:discounts) { Rates::Discount.where(id: discounts_arr.map(&:id)) }

    it "applies the discounts as AddtionMap nodes on top of the shipment node" do
      raw_shipment_value = Money.new(cargo_line_item_amount * 1.15 * 1.10, "USD")
      after_discount = raw_shipment_value - (discounts.first.amount * cargo.total_volume.value)

      expect(root.values).to eq [after_discount]
    end
  end

  context "when percentage discounts apply on a cargo rates" do
    let(:discounts_arr) {
      FactoryBot.create_list(:rates_discount, 1, :percentage_basis, target: cargo_targeted_rate.object,
                                                                    operator: :multiplication, percentage: 0.20,
                                                                    organization: organization,
                                                                    applicable_to: organization)
    }
    let(:discounts) { Rates::Discount.where(id: discounts_arr.map(&:id)) }

    it "builds discount percentage nodes on top of the cargo node" do
      section_node = root.children.first.children.find { |node| node.is_a?(TenderCalculator::Addition) }
      discount_node = section_node.children.find { |node| node.is_a?(TenderCalculator::ParentMap) }
      amount_with_discount = Money.new(0.80 * cargo_line_item_amount, "USD")

      expect(discount_node.values).to eq [amount_with_discount]
    end
  end

  context "when percentage discounts apply on section rates" do
    let(:discounts_arr) {
      FactoryBot.create_list(:rates_discount, 1, :percentage_basis, target: section, operator: :multiplication,
                                                                    percentage: 0.10, organization: organization,
                                                                    applicable_to: organization)
    }
    let(:discounts) { Rates::Discount.where(id: discounts_arr.map(&:id)) }

    it "builds discount percentage nodes on top of the section node" do
      section_with_discounts = root.children.first.children.find { |node| node.is_a?(TenderCalculator::Addition) }
      amount_with_discount = Money.new(cargo_line_item_amount * 1.15 * 0.90, "USD")

      expect(section_with_discounts.values).to eq [amount_with_discount]
    end
  end

  context "when percentage discounts apply on shipment (no target)" do
    let(:discounts_arr) {
      FactoryBot.create_list(:rates_discount, 1, :percentage_basis, operator: :multiplication, percentage: 0.05,

                                                                    organization: organization,
                                                                    applicable_to: organization)
    }
    let(:discounts) { Rates::Discount.where(id: discounts_arr.map(&:id)) }

    it "builds shipment percentage discounts as top most nodes" do
      amount_with_discount = Money.new(cargo_line_item_amount * 1.15 * 1.10 * 0.95, "USD")

      expect(root.values).to eq [amount_with_discount]
    end
  end

  context "when both percentage and flat discounts apply on shipment (no target)" do
    let(:flat_discount) {
      FactoryBot.create(:rates_discount, :shipment_basis, operator: :addition, amount_cents: 100, order: 1,
                                                          organization: organization, applicable_to: organization)
    }
    let(:percentage_discounts) {
      FactoryBot.create_list(:rates_discount, 1, :percentage_basis, operator: :multiplication, percentage: 0.05,
                                                                    order: 0, organization: organization,
                                                                    applicable_to: organization)
    }
    let(:discounts) { Rates::Discount.where(id: [flat_discount, *percentage_discounts].map(&:id)) }

    it "applies percentage discounts first, then flat discounts" do
      discount_percentage_amount = Money.new(cargo_line_item_amount * 1.15 * 1.10 * 0.95, "USD")

      expect(root.values).to eq [discount_percentage_amount - flat_discount.amount]
    end
  end

  context "when percentage discounts apply before flats on a rate" do
    let(:flat_discount) {
      FactoryBot.create(:rates_discount, :shipment_basis, target: section, operator: :addition, amount_cents: 100,
                                                          order: 1, organization: organization,
                                                          applicable_to: organization)
    }
    let(:percentage_discount) {
      FactoryBot.create(:rates_discount, :percentage_basis, target: section, operator: :multiplication,
                                                            percentage: 0.05, order: 0, organization: organization,
                                                            applicable_to: organization)
    }
    let(:discounts) { Rates::Discount.where(id: [flat_discount.id, percentage_discount.id]) }

    it "applies discounts according to the order attribute (percentage, then flat)" do
      section_with_discounts = root.children.first.children.find { |node| node.is_a?(TenderCalculator::AdditionMap) }
      discount_percentage_amount = Money.new(cargo_line_item_amount * 1.15 * 0.95, "USD")

      expect(section_with_discounts.values).to eq [discount_percentage_amount - flat_discount.amount]
    end
  end

  context "when flat discounts apply before percentages on a rate" do
    let(:flat_discount) {
      FactoryBot.create(:rates_discount, :shipment_basis, target: section, operator: :addition, amount_cents: 100,
                                                          order: 0, organization: organization,
                                                          applicable_to: organization)
    }
    let(:percentage_discount) {
      FactoryBot.create(:rates_discount, :percentage_basis, target: section, operator: :multiplication,
                                                            percentage: 0.05, order: 1,
                                                            organization: organization,
                                                            applicable_to: organization)
    }
    let(:discounts) { Rates::Discount.where(id: [flat_discount.id, percentage_discount.id]) }

    it "applies discounts according to the order attribute (flat, then percentage)" do
      section_with_discounts = root.children.first.children.find { |node| node.is_a?(TenderCalculator::Addition) }

      before_discount = Money.new(cargo_line_item_amount * 1.15, "USD")
      after_flat_discount = before_discount - flat_discount.amount
      after_percentage_discount = Money.new(after_flat_discount * 0.95, "USD")

      expect(section_with_discounts.values).to eq [after_percentage_discount]
    end
  end

  context "when both margins and discounts apply" do
    let(:margin) {
      FactoryBot.create(:rates_margin, operator: :multiplication, percentage: 0.05,
                                       organization: organization, applicable_to: organization)
    }
    let(:flat_discount) {
      FactoryBot.create(:rates_discount, :shipment_basis, target: nil, operator: :addition, amount_cents: 100,
                                                          organization: organization, applicable_to: organization)
    }

    let(:margins) { Rates::Margin.where(id: margin.id) }
    let(:discounts) { Rates::Discount.where(id: flat_discount.id) }

    it "builds shipment percentage margins as top most nodes" do
      raw_amount = Money.new(cargo_line_item_amount * 1.15 * 1.10, "USD")
      with_margin = raw_amount * 1.05
      with_discount = with_margin - flat_discount.amount

      aggregate_failures do
        expect(root.values).to eq [with_discount]
      end
    end
  end
end
