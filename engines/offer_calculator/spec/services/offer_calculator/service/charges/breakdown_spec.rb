# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Breakdown do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:fee) do
    OfferCalculator::Service::Charges::Fee.new(
      rate: Money.from_amount(100, "USD"),
      charge_category_id: FactoryBot.create(:legacy_charge_categories).id,
      rate_basis: "PER_SHIPMENT",
      base: 0,
      minimum_charge: Money.from_amount(10, "USD"),
      maximum_charge: Money.from_amount(10_000, "USD"),
      range_min: 0,
      range_max: Float::INFINITY,
      range_unit: "shipment",
      surcharge: Money.from_amount(0, "USD"),
      applied_margin: source
    )
  end
  let(:breakdown) do
    described_class.new(
      fee: fee,
      order: 0,
      metadata: { original_id: 1 }
    )
  end
  let(:source) { FactoryBot.create(:pricings_margin, applicable: applicable, organization: organization) }

  before { Organizations.current_id = organization.id }

  describe "#target_name" do
    context "when the applicable is a Companies::Company" do
      let(:applicable) { FactoryBot.create(:companies_company, organization: organization) }

      it "returns the name of the Company" do
        expect(breakdown.target_name).to eq(applicable.name)
      end
    end

    context "when the applicable is a Groups::Group" do
      let(:applicable) { FactoryBot.create(:groups_group, organization: organization) }

      it "returns the name of the Group" do
        expect(breakdown.target_name).to eq(applicable.name)
      end
    end

    context "when the applicable is a Users::Client" do
      let(:applicable) { FactoryBot.create(:users_client, organization: organization) }

      it "returns the name of the Client via the ClientProfile" do
        expect(breakdown.target_name).to eq(applicable.profile.full_name)
      end
    end
  end

  describe "#data" do
    let(:applicable) { FactoryBot.create(:users_client, organization: organization) }

    it "returns the legacy format of the fee" do
      expect(breakdown.data).to eq(fee.legacy_format)
    end
  end
end
