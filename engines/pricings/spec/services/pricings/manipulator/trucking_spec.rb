# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pricings::Manipulator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:vehicle) { FactoryBot.create(:vehicle, tenant_vehicles: [tenant_vehicle]) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly", organization: organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:group) do
    FactoryBot.create(:groups_group, organization: organization).tap do |group|
      FactoryBot.create(:groups_membership, member: user, group: group)
    end
  end
  let(:lcl_shipment) { FactoryBot.create(:legacy_shipment, organization: organization, user: user) }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, organization: organization) }
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
  let(:schedules) { trips.map { |t| Legacy::Schedule.from_trip(t) } }
  let!(:puf_charge_category) { FactoryBot.create(:puf_charge, organization: organization) }
  let(:bas_charge_category) { FactoryBot.create(:bas_charge, organization: organization) }
  let(:baf_charge_category) { FactoryBot.create(:baf_charge, organization: organization) }
  let(:dates) { { start_date: schedules.first.etd, end_date: schedules.last.etd } }
  let(:target_shipment) { lcl_shipment }
  let(:hub) { itinerary.origin_hub }
  let(:manipulated_results) { klass.perform }

  before do
    Organizations.current_id = organization.id
    FactoryBot.create(:legacy_currency)
    %w[ocean trucking local_charge].flat_map do |mot|
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
    let(:margin_type) { :trucking_pre_margin }
    let(:args) do
      {
        trucking_pricing: trucking_pricing,
        cargo_class_count: target_shipment.cargo_classes.count,
        dates: dates,
        without_meta: true
      }
    end
    let(:klass) do
      described_class.new(
        target: user,
        organization: organization,
        type: margin_type,
        args: args
      )
    end
    let(:trucking_pricing) do
      FactoryBot.create(:trucking_trucking, hub: hub, organization: organization, carriage: "pre")
    end
    let(:target_result) { manipulated_results.first }

    context "with manipulated trucking pricing attached to the user" do
      before do
        FactoryBot.create(:trucking_pre_margin, destination_hub: hub, organization: organization, applicable: user)
      end

      it "returns the manipulated trucking pricing attached to the user", :aggregate_failures do
        expect(target_result.result["id"]).to eq(trucking_pricing.id)
        expect(target_result.result["fees"].keys).to eq(["puf"])
        expect(target_result.result.dig("fees", "puf", "value")).to eq(275)
        expect(target_result.result.dig("fees", "puf", "rate_basis")).to eq("PER_SHIPMENT")
        expect(target_result.result["rates"].dig("kg", 0, "rate", "value")).to eq(261.25)
      end
    end

    context "with manipulated trucking pricing attached to the user (newly formatted rates)" do
      before do
        FactoryBot.create(:trucking_pre_margin, destination_hub: hub, organization: organization, applicable: user)
      end

      let(:trucking_pricing) do
        FactoryBot.create(:trucking_trucking, :new_rates, hub: hub, organization: organization, carriage: "pre")
      end

      it "returns the manipulated trucking pricing attached to the user", :aggregate_failures do
        expect(target_result.result["id"]).to eq(trucking_pricing.id)
        expect(target_result.result.dig("fees", "puf", "rate_basis")).to eq("PER_SHIPMENT")
        expect(target_result.result["rates"].dig("kg", 0, "rate", "rate")).to eq(261.25)
      end
    end

    context "with manipulated trucking pricing attached to the user with multiple margins" do
      before do
        FactoryBot.create(:trucking_pre_margin,
          destination_hub: hub,
          organization: organization,
          applicable: user,
          effective_date: (Time.zone.today + 1.day).beginning_of_day,
          expiration_date: (Time.zone.today + 10.days).end_of_day)
        FactoryBot.create(:trucking_pre_margin,
          destination_hub: hub,
          organization: organization,
          applicable: group,
          value: 10,
          operator: "+",
          effective_date: (Time.zone.today + 1.day).beginning_of_day,
          expiration_date: (Time.zone.today + 30.days).end_of_day)
      end

      it "returns the manipulated trucking pricing attached to the user with multiple margins", :aggregate_failures do
        expect(target_result.result["id"]).to eq(trucking_pricing.id)
        expect(manipulated_results.map(&:flat_margins)).to match_array([{}, { "puf" => 5, "trucking_lcl" => 5 }, { "puf" => 5, "trucking_lcl" => 5 }, {}])
        expect(manipulated_results.map { |pricing| pricing.result.dig("fees", "puf", "value") }).to match_array([250.0, 275.0, 250.0, 250.0])
        expect(manipulated_results.map { |pricing| pricing.result.dig("fees", "puf", "rate_basis") }.uniq).to eq(["PER_SHIPMENT"])
        expect(manipulated_results.map { |pricing| pricing.result.dig("rates", "kg", 0, "rate", "value") }).to eq([237.5, 261.25, 237.5, 237.5])
        expect(manipulated_results.flat_map(&:breakdowns).flat_map(&:data)).to include({ rate_basis: "PER_SHIPMENT" })
      end
    end

    context "with manipulated trucking pricing attached to the group" do
      before do
        FactoryBot.create(:trucking_pre_margin, destination_hub: hub, organization: organization, applicable: group)
      end

      it "returns the manipulated trucking pricing attached to the group", :aggregate_failures do
        expect(target_result.result["id"]).to eq(trucking_pricing.id)
        expect(target_result.result["fees"].keys).to eq(["puf"])
        expect(target_result.result.dig("fees", "puf", "value")).to eq(275)
        expect(target_result.result.dig("fees", "puf", "rate_basis")).to eq("PER_SHIPMENT")
        expect(target_result.result["rates"].dig("kg", 0, "rate", "value")).to eq(261.25)
      end
    end

    context "with multiple manipulated trucking pricings when margins overlap attached to the group" do
      Timecop.freeze(Time.zone.now) do
        before do
          FactoryBot.create(:trucking_pre_margin,
            destination_hub: hub,
            effective_date: Time.zone.today.beginning_of_day,
            expiration_date: (Time.zone.today + 12.days).end_of_day,
            organization: organization,
            applicable: group)
          FactoryBot.create(:trucking_pre_margin,
            destination_hub: hub,
            effective_date: (Time.zone.today + 10.days).beginning_of_day,
            expiration_date: (Time.zone.today + 22.days).end_of_day,
            organization: organization,
            value: 0.5,
            applicable: group)
        end

        it "returns multiple manipulated trucking pricings when margins overlap attached to the group", :aggregate_failures do
          expect(manipulated_results.map { |tp| tp.result["id"] }.uniq).to match_array([trucking_pricing.id])
          expect(manipulated_results.map { |mp| mp.result.dig("rates", "kg", 0, "rate", "value") }).to match_array([261.25, 391.875, 356.25, 237.5])
          expect(manipulated_results.map { |mp| mp.result.dig("fees", "puf", "value") }).to match_array([275, 412.5, 375, 250])
        end
      end

      context "with manipulated trucking pricing attached to the group via company" do
        before do
          company = FactoryBot.create(:companies_company, :with_member, organization: organization, member: user)
          FactoryBot.create(:groups_group, organization: organization).tap do |company_group|
            FactoryBot.create(:groups_membership, member: company, group: company_group)
            FactoryBot.create(:trucking_on_margin, origin_hub: hub, organization: organization, applicable: company_group)
          end
        end

        let(:trucking_pricing) do
          FactoryBot.create(:trucking_trucking, hub: hub, organization: organization, carriage: "on")
        end
        let(:margin_type) { :trucking_on_margin }

        it "returns the manipulated trucking pricing attached to the group via company", :aggregate_failures do
          expect(target_result.result["id"]).to eq(trucking_pricing.id)
          expect(target_result.result["fees"].keys).to eq(["puf"])
          expect(target_result.result.dig("fees", "puf", "value")).to eq(275)
          expect(target_result.result.dig("fees", "puf", "rate_basis")).to eq("PER_SHIPMENT")
          expect(target_result.result["rates"].dig("kg", 0, "rate", "value")).to eq(261.25)
        end
      end

      context "with manipulated trucking pricing with specific detail attached to the user" do
        before do
          FactoryBot.create(:trucking_on_margin, origin_hub: hub, organization: organization, applicable: user)
            .tap do |tapped_margin|
            FactoryBot.create(:pricings_detail, margin: tapped_margin, value: 0.25, charge_category: puf_charge_category)
          end
        end

        let(:trucking_pricing) do
          FactoryBot.create(:trucking_trucking, hub: hub, organization: organization, carriage: "on")
        end
        let(:margin_type) { :trucking_on_margin }

        it "returns the manipulated trucking pricing with specific detail attached to the user", :aggregate_failures do
          expect(target_result.result["id"]).to eq(trucking_pricing.id)
          expect(target_result.result["fees"].keys).to eq(["puf"])
          expect(target_result.result.dig("fees", "puf", "value")).to eq(312.5)
          expect(target_result.result.dig("fees", "puf", "rate_basis")).to eq("PER_SHIPMENT")
          expect(target_result.result["rates"].dig("kg", 0, "rate", "value")).to eq(261.25)
        end
      end

      context "with manipulated trucking pricing with specific detail and range fee attached to the user" do
        before do
          FactoryBot.create(:trucking_on_margin, origin_hub: hub, organization: organization, applicable: user)
            .tap do |tapped_margin|
            FactoryBot.create(:pricings_detail, margin: tapped_margin, value: 0.25, charge_category: puf_charge_category)
          end
        end

        let(:trucking_pricing) do
          FactoryBot.create(:trucking_trucking,
            hub: hub,
            organization: organization,
            carriage: "on",
            fees: {
              PUF: {
                key: "PUF",
                max: nil,
                min: 17.5,
                name: "PUF",
                value: 17.5,
                currency: "EUR",
                rate_basis: "PER_CBM_TON_RANGE",
                range: [
                  { min: 0, max: 10, cbm: 10, ton: 40 }
                ]
              }
            })
        end
        let(:margin_type) { :trucking_on_margin }

        it "returns the manipulated trucking correct keys and ids", :aggregate_failures do
          expect(target_result.result["id"]).to eq(trucking_pricing.id)
          expect(target_result.result["fees"].keys).to eq(["puf"])
        end

        it "returns the manipulated trucking pricing with range fee", :aggregate_failures do
          expect(target_result.result.dig("fees", "puf", "value")).to eq(21.875)
          expect(target_result.result["rates"].dig("kg", 0, "rate", "value")).to eq(261.25)
          expect(target_result.result.dig("fees", "puf", "range", 0, "cbm")).to eq(12.5)
          expect(target_result.result.dig("fees", "puf", "range", 0, "ton")).to eq(50)
          expect(target_result.result.dig("fees", "puf", "rate_basis")).to eq("PER_CBM_TON_RANGE")
        end
      end
    end

    context "with manipulated trucking pricing with metadata attached to the user" do
      let!(:margin1) do
        FactoryBot.create(:trucking_pre_margin, destination_hub: hub, organization: organization, applicable: user)
      end
      let!(:target_result) { manipulated_results.first }
      let(:puf_breakdowns) { target_result.breakdowns.select { |br| br.code == "puf" } }
      let(:trucking_breakdowns) { target_result.breakdowns.select { |br| br.code == "trucking_lcl" } }

      it "returns the manipulated trucking pricing with metadata attached to the user - general info", :aggregate_failures do
        expect(target_result.breakdowns.map(&:code).uniq).to eq(%w[puf trucking_lcl])
        expect(puf_breakdowns.length).to eq(2)
        expect(trucking_breakdowns.length).to eq(2)
      end

      it "returns the manipulated trucking pricing with metadata attached to the user - fee", :aggregate_failures do
        expect(puf_breakdowns.second.source).to eq(margin1)
        expect(puf_breakdowns.second.delta).to eq(margin1.value)
      end

      it "returns the manipulated trucking pricing with metadata attached to the user -main rate", :aggregate_failures do
        expect(trucking_breakdowns.second.source).to eq(margin1)
        expect(trucking_breakdowns.second.delta).to eq(margin1.value)
      end
    end
  end
end
