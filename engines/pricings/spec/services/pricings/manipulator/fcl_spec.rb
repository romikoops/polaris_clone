# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pricings::Manipulator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:vehicle) { FactoryBot.create(:vehicle, tenant_vehicles: [tenant_vehicle]) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly", organization: organization) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let(:group) do
    FactoryBot.create(:groups_group, organization: organization).tap do |group|
      FactoryBot.create(:groups_membership, member: user, group: group)
    end
  end

  let(:fcl_shipment) {
    FactoryBot.create(:legacy_shipment, organization: organization, user: user, load_type: "container")
  }
  let(:itinerary) { FactoryBot.create(:default_itinerary, organization: organization) }
  let(:trips) do
    [1, 3, 5, 7, 11, 12].map do |num|
      base_date = num.days.from_now
      FactoryBot.create(:legacy_trip,
        itinerary: itinerary,
        tenant_vehicle: tenant_vehicle,
        closing_date: base_date - 4.days,
        start_date: base_date,
        end_date: base_date + 30.days)
    end
  end

  let(:dates) { {start_date: schedules.first.etd, end_date: schedules.last.etd} }
  let(:schedules) { trips.map { |t| Legacy::Schedule.from_trip(t) } }
  let(:puf_charge_category) { FactoryBot.create(:puf_charge, organization: organization) }
  let(:solas_charge_category) { FactoryBot.create(:solas_charge, organization: organization) }
  let(:bas_charge_category) {
    Legacy::ChargeCategory.find_by(code: "bas") || FactoryBot.create(:bas_charge, organization: organization)
  }
  let(:baf_charge_category) { FactoryBot.create(:baf_charge, organization: organization) }
  let(:trucking_pre_charge_category) { FactoryBot.create(:trucking_pre_charge_category, organization: organization) }
  let(:trucking_on_charge_category) { FactoryBot.create(:trucking_on_charge_category, organization: organization) }

  let(:args) do
    {
      pricing: pricing,
      dates: dates,
      cargo_class_count: target_shipment.cargo_classes.count,
      without_meta: true
    }
  end
  let(:attribute_args) do
    {
      itinerary_id: pricing.itinerary_id,
      tenant_vehicle_id: pricing.tenant_vehicle_id,
      cargo_class: pricing.cargo_class,
      schedules: schedules,
      cargo_class_count: target_shipment.cargo_classes.count
    }
  end
  let(:klass) do
    described_class.new(
      target: user,
      organization: organization,
      type: :freight_margin,
      args: args
    )
  end
  let(:pricing) {
    FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle, organization: organization)
  }
  let(:local_charge) {
    FactoryBot.create(:legacy_local_charge,
      hub: hub, tenant_vehicle: tenant_vehicle, organization: organization, load_type: "fcl_20")
  }
  let(:target_shipment) { fcl_shipment }
  let(:hub) { itinerary.hubs.first }
  let(:manipulated_results) { klass.perform }

  before do
    %w[ocean air rail truck trucking local_charge].flat_map do |mot|
      [
        FactoryBot.create(:freight_margin,
          default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:trucking_on_margin,
          default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:trucking_pre_margin,
          default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:import_margin,
          default_for: mot, organization: organization, applicable: organization, value: 0),
        FactoryBot.create(:export_margin,
          default_for: mot, organization: organization, applicable: organization, value: 0)
      ]
    end
  end

  describe ".perform" do
    context "with freight pricings and user margin" do
      before do
        FactoryBot.create(:freight_margin, pricing: pricing, organization: organization, applicable: user)
      end

      it "returns the manipulated freight pricing attached to the user" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(275)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
        end
      end
    end

    context "with freight pricings and user margin (total)" do
      before do
        FactoryBot.create(:freight_margin,
          pricing: pricing, organization: organization, applicable: user, operator: "+", value: 100)
      end

      it "returns the manipulated freight pricing attached to the user (single total margin)" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(250)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
          expect(manipulated_results.map(&:flat_margins)).to eq([{"bas" => 100}])
        end
      end
    end

    context "with freight pricings and user margin (absolute)" do
      before do
        FactoryBot.create(:freight_margin,
          pricing: pricing, organization: organization, applicable: user, operator: "%", value: 0)
          .tap do |tapped_margin|
          FactoryBot.create(:bas_margin_detail,
            margin: tapped_margin, value: 25, operator: "&", charge_category: bas_charge_category)
        end
      end

      it "returns the manipulated freight pricing attached to the user (single absolute margin)" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(275)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
          expect(manipulated_results.map(&:flat_margins)).to eq([{}])
        end
      end
    end

    context "with freight pricings and multiple user margin" do
      before do
        FactoryBot.create(:freight_margin,
          pricing: pricing,
          organization: organization,
          applicable: user,
          effective_date: (Time.zone.today + 1.day).beginning_of_day,
          expiration_date: (Time.zone.today + 10.days).end_of_day)
        FactoryBot.create(:freight_margin,
          itinerary_id: pricing.itinerary_id,
          organization: organization,
          applicable: group,
          value: 10,
          operator: "+",
          effective_date: (Time.zone.today + 1.day).beginning_of_day,
          expiration_date: (Time.zone.today + 30.days).end_of_day)
      end

      it "returns the manipulated freight pricing attached to the user with multiple margins" do
        aggregate_failures do
          expect(manipulated_results.map(&:id).uniq).to eq([pricing.id])
          expect(manipulated_results.flat_map { |result| result.result["data"].keys }.uniq).to match_array(["bas"])
          expect(
            manipulated_results.map { |result| result.result.dig("data", "bas", "rate") }
          ).to match_array([250, 275, 250, 250])
          expect(manipulated_results.map(&:flat_margins)).to match_array([{}, {"bas" => 0.1e2}, {"bas" => 0.1e2}, {}])
          expect(
            manipulated_results.map { |result| result.result.dig("data", "bas", "rate_basis") }.uniq
          ).to match_array(["PER_CONTAINER"])
        end
      end
    end

    context "with freight pricings and group margin" do
      before do
        FactoryBot.create(:freight_margin, pricing: pricing, organization: organization, applicable: group)
      end

      it "returns the manipulated freight pricing attached to the group" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(275)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
        end
      end
    end

    context "with freight pricings, group margin, identified by attributes" do
      before do
        FactoryBot.create(:freight_margin,
          itinerary_id: pricing.itinerary_id,
          tenant_vehicle_id: pricing.tenant_vehicle_id,
          cargo_class: pricing.cargo_class,
          organization: organization,
          applicable: group)
      end

      let(:args) { attribute_args }

      it "returns the manipulated freight pricing attached to the group without pricing" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(275)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
        end
      end
    end

    context "with multiple manipulated freight pricings when margins overlap attached to the group without pricing" do
      Timecop.freeze(Time.zone.now) do
        let!(:margin_a) do
          FactoryBot.create(:freight_margin,
            pricing: pricing,
            effective_date: Time.zone.today - 3.days,
            expiration_date: (Time.zone.today + 10.days).end_of_day,
            organization: organization,
            applicable: group)
        end
        let!(:margin_b) do
          FactoryBot.create(:freight_margin,
            pricing: pricing,
            effective_date: Time.zone.today + 8.days,
            expiration_date: (Time.zone.today + 22.days).end_of_day,
            organization: organization,
            value: 0.5,
            applicable: group)
        end
        let(:args) do
          {
            itinerary_id: pricing.itinerary_id,
            tenant_vehicle_id: pricing.tenant_vehicle_id,
            cargo_class: pricing.cargo_class,
            dates: dates,
            shipment: target_shipment,
            without_meta: true
          }
        end

        let!(:results) { klass.perform.sort_by(&:effective_date) }
        let(:first_result) { results.first }
        let(:second_result) { results.second }
        let(:third_result) { results[2] }
        it "returns the correct data for the first period" do
          aggregate_failures do
            expect(first_result.id).to eq(pricing.id)
            expect(first_result.expiration_date.end_of_minute).to eq((margin_b.effective_date - 1.day).end_of_day)
            expect(first_result.result.dig("data").keys).to eq(["bas"])
            expect(first_result.result.dig("data", "bas", "rate")).to eq(275)
            expect(first_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
          end
        end

        it "returns the correct data for the middle period" do
          aggregate_failures do
            expect(second_result.id).to eq(pricing.id)
            expect(second_result.effective_date).to eq(margin_b.effective_date)
            expect(second_result.expiration_date.end_of_minute).to eq(margin_a.expiration_date)
            expect(second_result.result.dig("data").keys).to eq(["bas"])
            expect(second_result.result.dig("data", "bas", "rate")).to eq(412.5)
            expect(second_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
          end
        end

        it "returns the correct data for the last period" do
          aggregate_failures do
            expect(third_result.id).to eq(pricing.id)
            expect(third_result.effective_date).to eq((margin_a.expiration_date + 1.day).beginning_of_day)
            expect(third_result.expiration_date.end_of_minute).to eq(margin_b.expiration_date)
            expect(third_result.result.dig("data").keys).to eq(["bas"])
            expect(third_result.result.dig("data", "bas", "rate")).to eq(375)
            expect(third_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
          end
        end
      end
    end

    context "with freight pricings and group through the company margin" do
      before do
        company = FactoryBot.create(:companies_company, :with_member, organization: organization, member: user)
        FactoryBot.create(:groups_group, organization: organization).tap do |company_group|
          FactoryBot.create(:groups_membership, member: company, group: company_group)
          FactoryBot.create(:freight_margin, pricing: pricing, organization: organization, applicable: company_group)
        end
      end

      it "returns the manipulated freight pricing attached to the group via company" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(275)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
        end
      end
    end

    context "with manipulated freight pricing with specific detail attached to the user" do
      let(:pricing) do
        FactoryBot.create(:pricings_pricing,
          tenant_vehicle: tenant_vehicle, itinerary: itinerary).tap do |tapped_pricing|
          FactoryBot.create(:fee_per_container,
            organization: organization, charge_category: bas_charge_category, pricing: tapped_pricing, rate: 40)
          FactoryBot.create(:freight_margin,
            pricing: tapped_pricing, organization: organization, applicable: user).tap do |tapped_margin|
            FactoryBot.create(:bas_margin_detail,
              margin: tapped_margin, value: 0.25, charge_category: bas_charge_category)
          end
        end
      end

      it "returns the manipulated freight pricing with specific detail attached to the user" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(50)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
        end
      end
    end

    context "with manipulated freight pricing with one specific detail and general attached to the user" do
      let(:pricing) do
        FactoryBot.create(:pricings_pricing, tenant_vehicle: tenant_vehicle, itinerary: itinerary)
          .tap do |tapped_pricing|
          FactoryBot.create(:fee_per_container,
            organization: organization, charge_category: bas_charge_category, pricing: tapped_pricing, rate: 40)
          FactoryBot.create(:fee_per_container,
            organization: organization, charge_category: baf_charge_category, pricing: tapped_pricing, rate: 40)
          FactoryBot.create(:freight_margin,
            pricing: tapped_pricing, organization: organization, applicable: user).tap do |tapped_margin|
            FactoryBot.create(:bas_margin_detail,
              margin: tapped_margin, value: 0.25, charge_category: bas_charge_category)
          end
        end
      end

      let!(:target_result) { manipulated_results.first }

      it "returns the manipulated freight pricing with one specific detail and general attached to the user" do
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys.sort).to eq(%w[baf bas])
        end
      end

      it "returns the manipulated bas rate correctly" do
        aggregate_failures do
          expect(target_result.result.dig("data", "bas", "rate")).to eq(50)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
        end
      end

      it "returns the manipulated baf rate correctly" do
        aggregate_failures do
          expect(target_result.result.dig("data", "baf", "rate")).to eq(44)
          expect(target_result.result.dig("data", "baf", "rate_basis")).to eq("PER_CONTAINER")
        end
      end
    end

    context "with manipulated freight pricing attached to the user with a range" do
      let(:pricing) do
        FactoryBot.create(:lcl_range_pricing, tenant_vehicle: tenant_vehicle, itinerary: itinerary)
          .tap do |tapped_pricing|
          FactoryBot.create(:freight_margin,
            pricing: tapped_pricing, organization: organization, applicable: user, value: 0, operator: "%")
            .tap do |tapped_margin|
            FactoryBot.create(:bas_margin_detail,
              margin: tapped_margin, value: 0.25, charge_category: bas_charge_category)
          end
        end
      end

      it "returns the manipulated freight pricing attached to the user with a range" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "range", 0, "rate")).to eq(12.5)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_KG_RANGE")
        end
      end
    end

    context "with manipulated freight pricing attached to the user for total margin" do
      before do
        FactoryBot.create(:freight_margin,
          pricing: pricing, organization: organization, applicable: user, value: 10, operator: "+")
      end

      it "returns the manipulated freight pricing attached to the user for total margin" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(250)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
          expect(target_result.flat_margins).to eq("bas" => 0.1e2)
        end
      end
    end

    context "with manipulated freight pricing attached to the user for addition margin with total margins" do
      before do
        FactoryBot.create(:freight_margin,
          pricing: pricing, organization: organization, applicable: user, value: 10, operator: "+")
          .tap do |tapped_margin|
          FactoryBot.create(:pricings_detail,
            margin: tapped_margin, value: 10, operator: "+", charge_category: bas_charge_category)
        end
      end

      let(:charge_category) { pricing.fees.first.charge_category }

      it "returns the manipulated freight pricing attached to the user for addition margin with total margins" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(250)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
          expect(target_result.flat_margins).to eq("bas" => 0.1e2)
        end
      end
    end

    context "with manipulated freight pricing attached to the tenant without pricing" do
      before do
        FactoryBot.create(:freight_margin,
          itinerary_id: pricing.itinerary_id,
          tenant_vehicle_id: pricing.tenant_vehicle_id,
          cargo_class: pricing.cargo_class,
          organization: organization,
          applicable: organization)
      end

      let(:args) { attribute_args }

      it "returns the manipulated freight pricing attached to the tenant without pricing" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(275)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
        end
      end
    end

    context "with manipulated freight pricing attached to the tenant with itinerary only" do
      before do
        FactoryBot.create(:freight_margin,
          itinerary_id: pricing.itinerary_id,
          organization: organization,
          applicable: organization)
      end

      let(:args) { attribute_args }

      it "returns the manipulated freight pricing attached to the tenant with itinerary only" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(275)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
        end
      end
    end

    context "with manipulated freight pricing attached to the tenant with default_for" do
      let(:args) { attribute_args }

      it "returns the manipulated freight pricing attached to the tenant with default_for" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(250)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
        end
      end
    end

    context "with manipulated freight pricing attached to the tenant with nothing else" do
      before do
        FactoryBot.create(:freight_margin, organization: organization, applicable: organization)
      end

      let(:args) { attribute_args }

      it "returns the manipulated freight pricing attached to the tenant with nothing else" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(275)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
        end
      end
    end

    context "with manipulated freight pricing attached to hub and cargo class" do
      before do
        FactoryBot.create(:freight_margin,
          organization: organization,
          origin_hub: pricing.itinerary.hubs.first,
          cargo_class: pricing.cargo_class,
          applicable: organization)
      end

      let(:args) { attribute_args }

      it "returns the manipulated freight pricing attached to hub and cargo class" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(pricing.id)
          expect(target_result.result["data"].keys).to eq(["bas"])
          expect(target_result.result.dig("data", "bas", "rate")).to eq(275)
          expect(target_result.result.dig("data", "bas", "rate_basis")).to eq("PER_CONTAINER")
        end
      end
    end

    context "with manipulated freight pricing with metadata attached to the user - single margin" do
      let!(:margin) {
        FactoryBot.create(:freight_margin, pricing: pricing, organization: organization, applicable: user)
      }
      let!(:target_result) { manipulated_results.first }

      it "returns the manipulated freight pricing with metadata attached to the user - single margin" do
        aggregate_failures do
          expect(target_result.id).to eq(pricing.id)
          expect(target_result.breakdowns.map(&:code).uniq).to eq(%w[bas])
          expect(target_result.breakdowns.length).to eq(2)
          expect(target_result.breakdowns.second.source).to eq(margin)
          expect(target_result.breakdowns.second.delta).to eq(margin.value)
        end
      end
    end

    context "with manipulated freight pricing with metadata attached to the user - double margin" do
      let!(:margin1) {
        FactoryBot.create(:freight_margin, pricing: pricing, organization: organization, applicable: user)
      }
      let!(:margin2) {
        FactoryBot.create(:freight_margin,
          pricing: pricing, organization: organization, applicable: user, value: 50, operator: "+")
      }
      let!(:target_result) { manipulated_results.first }

      it "returns the manipulated freight pricing with metadata attached to the user - general info" do
        aggregate_failures do
          expect(target_result.id).to eq(pricing.id)
          expect(target_result.breakdowns.map(&:code).uniq).to eq(%w[bas])
        end
      end

      it "returns the manipulated freight pricing with metadata attached to the user - first margin" do
        aggregate_failures do
          expect(target_result.breakdowns.length).to eq(3)
          expect(target_result.breakdowns.second.source).to eq(margin1)
          expect(target_result.breakdowns.second.delta).to eq(margin1.value)
        end
      end

      it "returns the manipulated freight pricing with metadata attached to the user - second margin" do
        aggregate_failures do
          expect(target_result.breakdowns.length).to eq(3)
          expect(target_result.breakdowns.third.source).to eq(margin2)
          expect(target_result.breakdowns.third.delta).to eq(margin2.value)
        end
      end
    end

    context "with manipulated freight pricing with metadata attached to the user - flat margin, many fees" do
      let(:pricing) do
        FactoryBot.create(:lcl_pricing, tenant_vehicle: tenant_vehicle, itinerary: itinerary).tap do |tapped_pricing|
          FactoryBot.create(:pricings_fee, pricing: tapped_pricing, charge_category: FactoryBot.create(:baf_charge))
        end
      end
      let!(:margin1) {
        FactoryBot.create(:freight_margin, pricing: pricing, organization: organization, applicable: user)
      }
      let!(:margin2) {
        FactoryBot.create(:freight_margin,
          pricing: pricing, organization: organization, applicable: user, value: 50, operator: "+")
      }
      let!(:target_result) { manipulated_results.first }

      it "returns the manipulated freight pricing with metadata attached to the user - flat margin, general info" do
        aggregate_failures do
          expect(target_result.id).to eq(pricing.id)
          expect(target_result.breakdowns.map(&:code).uniq).to match_array(%w[bas baf])
          expect(target_result.breakdowns.length).to eq(6)
        end
      end

      it "returns the manipulated freight pricing with metadata attached to the user - flat margin, first fee" do
        bas_breakdowns = target_result.breakdowns.select { |br| br.code == "bas" }
        aggregate_failures do
          expect(bas_breakdowns.second.source).to eq(margin1)
          expect(bas_breakdowns.second.delta).to eq(margin1.value)
          expect(bas_breakdowns.third.source).to eq(margin2)
          expect(bas_breakdowns.third.delta).to eq(margin2.value / 2)
        end
      end

      it "returns the manipulated freight pricing with metadata attached to the user - flat margin, second fee" do
        baf_breakdowns = target_result.breakdowns.select { |br| br.code == "baf" }
        aggregate_failures do
          expect(baf_breakdowns.second.source).to eq(margin1)
          expect(baf_breakdowns.second.delta).to eq(margin1.value)
          expect(baf_breakdowns.third.source).to eq(margin2)
          expect(baf_breakdowns.third.delta).to eq(margin2.value / 2)
        end
      end
    end
  end
end
