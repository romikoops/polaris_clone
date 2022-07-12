# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::Margins do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:period) { Range.new(Time.zone.now, 2.weeks.from_now) }
  let(:margin_frame) { described_class.new(type: type, applicables: applicables, period: period, fee_codes: fee_codes, cargo_classes: cargo_classes).perform }
  let(:applicables) { [client] }
  let(:type) { "Pricing" }
  let(:fee_codes) { Rover::DataFrame.new({ "code" => %w[bas] }) }
  let(:cargo_classes) { ["lcl"] }

  before { Organizations.current_id = organization.id }

  describe "#perform" do
    context "when there are no Margins" do
      expected_keys = %w[id
        rate
        operator
        code
        margin_id
        applicable_id
        applicable_type
        effective_date
        expiration_date
        origin_hub_id
        destination_hub_id
        tenant_vehicle_id
        itinerary_id
        pricing_id
        cargo_class
        currency
        range_max
        range_min
        range_unit
        margin_type
        source_type
        rank]

      it "returns an empty frame with all the correct keys", :aggregate_failures do
        expect(margin_frame).to be_empty
        expect(margin_frame.keys).to match_array(expected_keys)
      end
    end

    context "when the Margin has no Details" do
      let!(:margin) { FactoryBot.create(:pricings_margin, :freight, applicable: client, organization: organization) }
      let(:expected_margin_row) do
        { "id" => margin.id,
          "rate" => margin.value.to_f,
          "operator" => "%",
          "code" => "bas",
          "margin_id" => nil,
          "applicable_id" => client.id,
          "applicable_type" => "Users::Client",
          "currency" => "EUR",
          "range_min" => 0,
          "range_max" => Float::INFINITY,
          "range_unit" => "percentage",
          "charge_category_id" => nil,
          "effective_date" => margin.effective_date.to_date,
          "expiration_date" => margin.expiration_date.to_date,
          "origin_hub_id" => nil,
          "destination_hub_id" => nil,
          "tenant_vehicle_id" => nil,
          "itinerary_id" => nil,
          "pricing_id" => nil,
          "cargo_class" => "lcl",
          "rate_basis" => "PERCENTAGE",
          "margin_type" => margin.margin_type,
          "source_type" => "Pricings::Margin",
          "rank" => 0 }
      end

      it "returns the margin data in a DataFrame expanded for each fee code" do
        expect(margin_frame.to_a).to eq([expected_margin_row])
      end
    end

    context "when the Margin is a `total_margin` and type is `LocalCharge`" do
      let!(:margin) { FactoryBot.create(:pricings_margin, :total, applicable: client, organization: organization) }
      let(:type) { "LocalCharge" }
      let(:expected_margin_rows) do
        %w[export_margin import_margin].map do |margin_type|
          { "id" => margin.id,
            "rate" => margin.value.to_f,
            "operator" => "%",
            "code" => "bas",
            "margin_id" => nil,
            "applicable_id" => client.id,
            "applicable_type" => "Users::Client",
            "currency" => "EUR",
            "range_min" => 0,
            "range_max" => Float::INFINITY,
            "range_unit" => "percentage",
            "charge_category_id" => nil,
            "effective_date" => margin.effective_date.to_date,
            "expiration_date" => margin.expiration_date.to_date,
            "origin_hub_id" => nil,
            "destination_hub_id" => nil,
            "tenant_vehicle_id" => nil,
            "itinerary_id" => nil,
            "pricing_id" => nil,
            "cargo_class" => "lcl",
            "rate_basis" => "PERCENTAGE",
            "margin_type" => margin_type,
            "source_type" => "Pricings::Margin",
            "rank" => 0 }
        end
      end

      it "returns the margin data in a DataFrame expanded for each `margin_type`" do
        expect(margin_frame.to_a).to eq(expected_margin_rows)
      end
    end

    context "when the Margin has Details but not for all fee codes" do
      let(:margin) { FactoryBot.create(:pricings_margin, :freight, applicable: client, organization: organization) }
      let!(:detail) { FactoryBot.create(:pricings_detail, :bas_addition_detail, margin: margin, organization: organization) }
      let(:expected_margin_row) do
        { "id" => detail.id,
          "rate" => detail.value.to_f,
          "operator" => detail.operator,
          "code" => detail.charge_category.code,
          "margin_id" => margin.id,
          "effective_date" => margin.effective_date.to_date,
          "expiration_date" => margin.expiration_date.to_date,
          "origin_hub_id" => nil,
          "destination_hub_id" => nil,
          "tenant_vehicle_id" => nil,
          "itinerary_id" => nil,
          "pricing_id" => nil,
          "cargo_class" => "lcl",
          "applicable_type" => "Users::Client",
          "currency" => "EUR",
          "range_min" => 0,
          "range_max" => Float::INFINITY,
          "range_unit" => "shipment",
          "rate_basis" => "PER_SHIPMENT",
          "charge_category_id" => detail.charge_category_id,
          "applicable_id" => client.id,
          "margin_type" => margin.margin_type,
          "source_type" => "Pricings::Detail",
          "rank" => 0 }
      end
      let(:fee_codes) { Rover::DataFrame.new({ "code" => %w[bas baf] }) }

      it "returns the margin fee specific data in a DataFrame, only for the fee code  listed in the Detail" do
        expect(margin_frame.to_a).to eq([expected_margin_row])
      end
    end

    context "when the Margin has no Details, multiple fee codes provided" do
      let!(:margin) { FactoryBot.create(:pricings_margin, :freight, applicable: client, organization: organization, operator: "%") }
      let(:expected_margin_rows) do
        fee_codes["code"].to_a.map do |code|
          { "id" => margin.id,
            "rate" => margin.value.to_f,
            "operator" => "%",
            "code" => code,
            "margin_id" => nil,
            "applicable_id" => client.id,
            "applicable_type" => "Users::Client",
            "currency" => "EUR",
            "range_min" => 0,
            "range_max" => Float::INFINITY,
            "range_unit" => "percentage",
            "rate_basis" => "PERCENTAGE",
            "charge_category_id" => nil,
            "effective_date" => margin.effective_date.to_date,
            "expiration_date" => margin.expiration_date.to_date,
            "origin_hub_id" => nil,
            "destination_hub_id" => nil,
            "tenant_vehicle_id" => nil,
            "itinerary_id" => nil,
            "pricing_id" => nil,
            "cargo_class" => "lcl",
            "margin_type" => margin.margin_type,
            "source_type" => "Pricings::Margin",
            "rank" => 0 }
        end
      end
      let(:fee_codes) { Rover::DataFrame.new({ "code" => %w[bas baf] }) }

      it "returns the margin data in a DataFrame expanded for the fee codes provided" do
        expect(margin_frame.to_a).to match_array(expected_margin_rows)
      end
    end

    context "when the Margin has no Details and a flat amount, multiple fee codes provided" do
      let!(:margin) { FactoryBot.create(:pricings_margin, :freight, applicable: client, organization: organization, operator: "+") }
      let(:expected_margin_rows) do
        fee_codes["code"].to_a.map do |code|
          { "id" => margin.id,
            "rate" => margin.value.to_f / fee_codes.count,
            "operator" => "+",
            "code" => code,
            "margin_id" => nil,
            "applicable_id" => client.id,
            "applicable_type" => "Users::Client",
            "currency" => "EUR",
            "range_min" => 0,
            "range_max" => Float::INFINITY,
            "range_unit" => "shipment",
            "rate_basis" => "PER_SHIPMENT",
            "charge_category_id" => nil,
            "effective_date" => margin.effective_date.to_date,
            "expiration_date" => margin.expiration_date.to_date,
            "origin_hub_id" => nil,
            "destination_hub_id" => nil,
            "tenant_vehicle_id" => nil,
            "itinerary_id" => nil,
            "pricing_id" => nil,
            "cargo_class" => "lcl",
            "margin_type" => margin.margin_type,
            "source_type" => "Pricings::Margin",
            "rank" => 0 }
        end
      end
      let(:fee_codes) { Rover::DataFrame.new({ "code" => %w[bas baf] }) }

      it "returns the margin data in a DataFrame expanded for the fee codes provided, with the amount divided amongst the fee codes" do
        expect(margin_frame.to_a).to match_array(expected_margin_rows)
      end
    end

    context "when the Margin has no Details and multiple cargo classes are provided" do
      let!(:margin) { FactoryBot.create(:pricings_margin, :freight, applicable: client, organization: organization) }
      let(:expected_margin_rows) do
        cargo_classes.map do |cc|
          { "id" => margin.id,
            "rate" => margin.value.to_f,
            "operator" => "%",
            "code" => "bas",
            "margin_id" => nil,
            "applicable_id" => client.id,
            "applicable_type" => "Users::Client",
            "currency" => "EUR",
            "range_min" => 0,
            "range_max" => Float::INFINITY,
            "range_unit" => "percentage",
            "rate_basis" => "PERCENTAGE",
            "charge_category_id" => nil,
            "effective_date" => margin.effective_date.to_date,
            "expiration_date" => margin.expiration_date.to_date,
            "origin_hub_id" => nil,
            "destination_hub_id" => nil,
            "tenant_vehicle_id" => nil,
            "itinerary_id" => nil,
            "pricing_id" => nil,
            "cargo_class" => cc,
            "margin_type" => margin.margin_type,
            "source_type" => "Pricings::Margin",
            "rank" => 0 }
        end
      end
      let(:cargo_classes) { %w[fcl_20 fcl_40] }

      it "returns the margin data in a DataFrame, expanded for cargo classes" do
        expect(margin_frame.to_a).to eq(expected_margin_rows)
      end
    end
  end
end
