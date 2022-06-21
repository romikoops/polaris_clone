# frozen_string_literal: true

require "rails_helper"

RSpec.describe OfferCalculator::Service::Charges::ApplicableMargins do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:client) { FactoryBot.create(:users_client, organization: organization) }
  let(:period) { Range.new(Time.zone.now, 2.weeks.from_now) }
  let(:expansion_value) { OfferCalculator::Service::Charges::Margins::EXPANSION_VALUE }
  let(:margin_frame) do
    described_class.new(
      type: type,
      applicables: applicables,
      period: period,
      cargo_classes: cargo_classes,
      expansion_value: expansion_value
    ).frame
  end
  let(:applicables) { [client, organization] }
  let(:cargo_classes) { ["lcl"] }

  before { Organizations.current_id = organization.id }

  describe "#frame" do
    context "when the 'type' is Pricing" do
      let(:type) { "Pricing" }

      context "when there are no Margins" do
        expected_keys = %w[id
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
          rate
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
            "code" => expansion_value,
            "margin_id" => nil,
            "applicable_id" => client.id,
            "applicable_type" => client.class.to_s,
            "effective_date" => margin.effective_date.to_date,
            "expiration_date" => margin.expiration_date.to_date,
            "origin_hub_id" => nil,
            "destination_hub_id" => nil,
            "tenant_vehicle_id" => nil,
            "itinerary_id" => nil,
            "pricing_id" => nil,
            "cargo_class" => "lcl",
            "margin_type" => margin.margin_type,
            "range_max" => Float::INFINITY,
            "range_min" => 0,
            "range_unit" => "percentage",
            "rate_basis" => "PERCENTAGE",
            "currency" => "EUR",
            "charge_category_id" => nil,
            "rank" => 0 }
        end

        it "returns the margin data in a DataFrame" do
          expect(margin_frame.to_a).to eq([expected_margin_row])
        end
      end

      context "when the Margin has no Details and multiple cargo classes are provided" do
        let!(:margin) { FactoryBot.create(:pricings_margin, :freight, applicable: client, organization: organization) }
        let(:expected_margin_rows) do
          cargo_classes.map do |cc|
            { "id" => margin.id,
              "rate" => margin.value.to_f,
              "operator" => "%",
              "code" => expansion_value,
              "margin_id" => nil,
              "applicable_id" => client.id,
              "applicable_type" => client.class.to_s,
              "effective_date" => margin.effective_date.to_date,
              "expiration_date" => margin.expiration_date.to_date,
              "origin_hub_id" => nil,
              "destination_hub_id" => nil,
              "tenant_vehicle_id" => nil,
              "itinerary_id" => nil,
              "pricing_id" => nil,
              "cargo_class" => cc,
              "margin_type" => margin.margin_type,
              "range_max" => Float::INFINITY,
              "range_min" => 0,
              "range_unit" => "percentage",
              "rate_basis" => "PERCENTAGE",
              "currency" => "EUR",
              "charge_category_id" => nil,
              "rank" => 0 }
          end
        end
        let(:cargo_classes) { %w[fcl_20 fcl_40] }

        it "returns the margin data in a DataFrame, expanded for cargo classes" do
          expect(margin_frame.to_a).to eq(expected_margin_rows)
        end
      end

      context "when the Margin has Details" do
        let(:margin) { FactoryBot.create(:pricings_margin, :freight, applicable: client, organization: organization) }
        let!(:detail) { FactoryBot.create(:pricings_detail, :bas_addition_detail, margin: margin, organization: organization) }
        let(:expected_margin_row) do
          { "id" => detail.id,
            "rate" => detail.value.to_f,
            "operator" => detail.operator,
            "code" => detail.charge_category.code,
            "margin_id" => margin.id,
            "applicable_id" => client.id,
            "applicable_type" => client.class.to_s,
            "effective_date" => margin.effective_date.to_date,
            "expiration_date" => margin.expiration_date.to_date,
            "origin_hub_id" => nil,
            "destination_hub_id" => nil,
            "tenant_vehicle_id" => nil,
            "itinerary_id" => nil,
            "pricing_id" => nil,
            "cargo_class" => "lcl",
            "margin_type" => margin.margin_type,
            "range_max" => Float::INFINITY,
            "range_min" => 0,
            "range_unit" => "shipment",
            "rate_basis" => "PER_SHIPMENT",
            "currency" => "EUR",
            "charge_category_id" => detail.charge_category_id,
            "rank" => 0 }
        end

        it "returns the margin fee specific data in a DataFrame" do
          expect(margin_frame.to_a).to eq([expected_margin_row])
        end
      end

      context "when multiple margins exist, applicable to different parts of the hierarchy" do
        let!(:margin) { FactoryBot.create(:pricings_margin, :freight, applicable: client, organization: organization) }
        let(:group) { FactoryBot.create(:groups_group, memberships: [FactoryBot.build(:groups_membership, member: client)], organization: organization) }
        let!(:group_margin) { FactoryBot.create(:pricings_margin, :freight, applicable: group, organization: organization) }
        let(:company) { FactoryBot.create(:companies_company, memberships: [FactoryBot.build(:companies_membership, client: client)], organization: organization) }
        let!(:company_margin) { FactoryBot.create(:pricings_margin, :freight, applicable: company, organization: organization) }
        let(:applicables) { [client, group, company, organization] }

        it "returns the margins order of the hierarchy", :aggregate_failures do
          expect(margin_frame["rank"].to_a).to eq([0, 1, 2])
          expect(margin_frame["id"].to_a).to eq([margin.id, group_margin.id, company_margin.id])
          expect(margin_frame["applicable_id"].to_a).to eq([client.id, group.id, company.id])
        end
      end
    end

    context "when the type is LocalCharge" do
      let(:type) { "LocalCharge" }

      context "when `applicables` only has the organization" do
        let(:applicables) { [organization] }
        let!(:margin) { FactoryBot.create(:pricings_margin, :export, applicable: organization, organization: organization, default_for: "ocean") }

        it "returns the default margins for the organization", :aggregate_failures do
          expect(margin_frame["id"].to_a).to eq([margin.id])
          expect(margin_frame["applicable_id"].to_a).to eq([organization.id])
        end
      end

      context "when the Margin is a `total_margin`" do
        let!(:margin) { FactoryBot.create(:pricings_margin, :total, applicable: client, organization: organization) }
        let(:expected_margin_rows) do
          %w[export_margin import_margin].map do |margin_type|
            { "id" => margin.id,
              "rate" => margin.value.to_f,
              "operator" => "%",
              "code" => expansion_value,
              "margin_id" => nil,
              "applicable_id" => client.id,
              "applicable_type" => client.class.to_s,
              "effective_date" => margin.effective_date.to_date,
              "expiration_date" => margin.expiration_date.to_date,
              "origin_hub_id" => nil,
              "destination_hub_id" => nil,
              "tenant_vehicle_id" => nil,
              "itinerary_id" => nil,
              "pricing_id" => nil,
              "cargo_class" => "lcl",
              "margin_type" => margin_type,
              "range_max" => Float::INFINITY,
              "range_min" => 0,
              "range_unit" => "percentage",
              "rate_basis" => "PERCENTAGE",
              "currency" => "EUR",
              "charge_category_id" => nil,
              "rank" => 0 }
          end
        end

        it "returns the margin data expanded for all LocalCharge margin types" do
          expect(margin_frame.to_a).to eq(expected_margin_rows)
        end
      end
    end

    context "when the type is Trucking" do
      let(:type) { "Trucking" }

      context "when the Margin is a `total_margin`" do
        let!(:margin) { FactoryBot.create(:pricings_margin, :total, applicable: client, organization: organization) }
        let(:expected_margin_rows) do
          %w[trucking_pre_margin trucking_on_margin].map do |margin_type|
            { "id" => margin.id,
              "rate" => margin.value.to_f,
              "operator" => "%",
              "code" => expansion_value,
              "margin_id" => nil,
              "applicable_id" => client.id,
              "applicable_type" => client.class.to_s,
              "effective_date" => margin.effective_date.to_date,
              "expiration_date" => margin.expiration_date.to_date,
              "origin_hub_id" => nil,
              "destination_hub_id" => nil,
              "tenant_vehicle_id" => nil,
              "itinerary_id" => nil,
              "pricing_id" => nil,
              "cargo_class" => "lcl",
              "margin_type" => margin_type,
              "range_max" => Float::INFINITY,
              "range_min" => 0,
              "range_unit" => "percentage",
              "rate_basis" => "PERCENTAGE",
              "currency" => "EUR",
              "charge_category_id" => nil,
              "rank" => 0 }
          end
        end

        it "returns the margin data expanded for all LocalCharge margin types" do
          expect(margin_frame.to_a).to eq(expected_margin_rows)
        end
      end

      context "when the margin_type doesn't match the ones present in the database" do
        before { FactoryBot.create(:pricings_margin, :freight, applicable: client, organization: organization) }

        it "returns an empty frame" do
          expect(margin_frame).to be_empty
        end
      end
    end
  end
end
