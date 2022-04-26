# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::MarginedRate do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:margined_rate) { described_class.new(fee: fee, margin_rows: margin_rows) }
  let(:margin_rows) do
    Rover::DataFrame.new({ "id" => [],
      "rate" => [],
      "operator" => [],
      "code" => [],
      "margin_id" => [],
      "applicable_id" => [],
      "applicable_type" => [],
      "effective_date" => [],
      "expiration_date" => [],
      "origin_hub_id" => [],
      "destination_hub_id" => [],
      "tenant_vehicle_id" => [],
      "pricing_id" => [],
      "cargo_class" => [],
      "margin_type" => [],
      "rank" => [] })
  end
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
      surcharge: Money.from_amount(0, "USD")
    )
  end

  before { Organizations.current_id = organization.id }

  describe "#surcharge" do
    context "without margins" do
      it "returns zero of the Rate's currency" do
        expect(margined_rate.surcharge).to eq(Money.from_amount(0, "USD"))
      end
    end

    context "with margins" do
      let(:margin) { FactoryBot.create(:pricings_margin, organization: organization, applicable: user) }
      let(:margin_rows) do
        Rover::DataFrame.new({ "id" => [margin.id],
          "rate" => [50],
          "operator" => ["+"],
          "code" => ["bas"],
          "margin_id" => [margin.id],
          "applicable_id" => [margin.applicable_id],
          "applicable_type" => [margin.applicable_type],
          "effective_date" => [margin.effective_date],
          "expiration_date" => [margin.expiration_date],
          "origin_hub_id" => [margin.origin_hub_id],
          "destination_hub_id" => [margin.destination_hub_id],
          "tenant_vehicle_id" => [margin.tenant_vehicle_id],
          "pricing_id" => [margin.pricing_id],
          "cargo_class" => ["lcl"],
          "source_id" => [margin.id],
          "source_type" => [margin.class.to_s],
          "margin_type" => ["freight_margin"],
          "rank" => [1] })
      end

      it "returns the summed surcharges in the Rate's currency" do
        expect(margined_rate.surcharge).to eq(Money.from_amount(50, "USD"))
      end
    end
  end

  describe "#rate" do
    context "without margins" do
      it "returns original rate as is" do
        expect(margined_rate.rate).to eq(Money.from_amount(100, "USD"))
      end
    end

    context "with '&' margins" do
      let(:margin) { FactoryBot.create(:pricings_margin, organization: organization, applicable: user) }
      let(:margin_rows) do
        Rover::DataFrame.new({ "id" => [margin.id],
          "rate" => [50],
          "operator" => ["&"],
          "code" => ["bas"],
          "margin_id" => [margin.id],
          "applicable_id" => [margin.applicable_id],
          "applicable_type" => [margin.applicable_type],
          "effective_date" => [margin.effective_date],
          "expiration_date" => [margin.expiration_date],
          "origin_hub_id" => [margin.origin_hub_id],
          "destination_hub_id" => [margin.destination_hub_id],
          "tenant_vehicle_id" => [margin.tenant_vehicle_id],
          "pricing_id" => [margin.pricing_id],
          "cargo_class" => ["lcl"],
          "source_id" => [margin.id],
          "source_type" => [margin.class.to_s],
          "margin_type" => ["freight_margin"],
          "rank" => [1] })
      end

      it "returns the rate adjusted for the margin" do
        expect(margined_rate.rate).to eq(Money.from_amount(150, "USD"))
      end
    end

    context "with '%' margins" do
      let(:margin) { FactoryBot.create(:pricings_margin, organization: organization, applicable: user) }
      let(:margin_rows) do
        Rover::DataFrame.new({ "id" => [margin.id],
          "rate" => [0.25],
          "operator" => ["%"],
          "code" => ["bas"],
          "margin_id" => [margin.id],
          "applicable_id" => [margin.applicable_id],
          "applicable_type" => [margin.applicable_type],
          "effective_date" => [margin.effective_date],
          "expiration_date" => [margin.expiration_date],
          "origin_hub_id" => [margin.origin_hub_id],
          "destination_hub_id" => [margin.destination_hub_id],
          "tenant_vehicle_id" => [margin.tenant_vehicle_id],
          "pricing_id" => [margin.pricing_id],
          "cargo_class" => ["lcl"],
          "source_id" => [margin.id],
          "source_type" => [margin.class.to_s],
          "margin_type" => ["freight_margin"],
          "rank" => [1] })
      end

      it "returns the rate adjusted for the margin" do
        expect(margined_rate.rate).to eq(Money.from_amount(12_5, "USD"))
      end
    end

    context "with sequential '%' margins" do
      let(:margin) { FactoryBot.create(:pricings_margin, organization: organization, applicable: user) }
      let(:second_margin) { FactoryBot.create(:pricings_margin, organization: organization, applicable: user) }
      let(:margin_rows) do
        Rover::DataFrame.new({ "id" => [margin.id, second_margin.id],
          "rate" => [0.25, 0.33],
          "operator" => ["%", "%"],
          "code" => %w[bas bas],
          "margin_id" => [margin.id, second_margin.id],
          "applicable_id" => [margin.applicable_id, second_margin.applicable_id],
          "applicable_type" => [margin.applicable_type, second_margin.applicable_type],
          "effective_date" => [margin.effective_date, second_margin.effective_date],
          "expiration_date" => [margin.expiration_date, second_margin.expiration_date],
          "origin_hub_id" => [margin.origin_hub_id, second_margin.origin_hub_id],
          "destination_hub_id" => [margin.destination_hub_id, second_margin.destination_hub_id],
          "tenant_vehicle_id" => [margin.tenant_vehicle_id, second_margin.tenant_vehicle_id],
          "pricing_id" => [margin.pricing_id, second_margin.pricing_id],
          "cargo_class" => %w[lcl lcl],
          "source_id" => [margin.id, second_margin.id],
          "source_type" => [margin.class.to_s] * 2,
          "margin_type" => %w[freight_margin freight_margin],
          "rank" => [1, 2] })
      end

      it "returns the rate adjusted for the margin, applying the percentages correctly" do
        expect(margined_rate.rate).to eq(Money.from_amount((100 * 1.25 * 1.33), "USD"))
      end
    end
  end

  describe "#breakdowns" do
    context "without margins" do
      let(:first_breakdown) { margined_rate.breakdowns.first }

      it "returns a single Breakdown linking to the original record", :aggregate_failures do
        expect(margined_rate.breakdowns).to eq([first_breakdown])
        expect(first_breakdown.source).to be_nil
        expect(first_breakdown.delta).to be_zero
        expect(first_breakdown.data).to eq(fee.to_h)
      end
    end
  end
end
