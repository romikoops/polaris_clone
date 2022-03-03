# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pricings::Manipulator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:vehicle) { FactoryBot.create(:vehicle, tenant_vehicles: [tenant_vehicle]) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly", organization: organization) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:users_client, organization: organization) }
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

  let!(:solas_charge_category) { FactoryBot.create(:solas_charge, organization: organization) }
  let(:bas_charge_category) { FactoryBot.create(:bas_charge, organization: organization) }
  let(:baf_charge_category) { FactoryBot.create(:baf_charge, organization: organization) }
  let(:margin_type) { :export_margin }
  let(:args) do
    {
      local_charge: local_charge,
      schedules: schedules,
      cargo_class_count: target_shipment.cargo_classes.count,
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
  let(:pricing) {
    FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle, organization: organization)
  }
  let(:local_charge) {
    FactoryBot.create(:legacy_local_charge, hub: hub, tenant_vehicle: tenant_vehicle, organization: organization)
  }
  let(:target_shipment) { lcl_shipment }
  let(:hub) { itinerary.origin_hub }
  let(:manipulated_results) { klass.perform }
  let(:target_result) { manipulated_results.first }

  before do
    FactoryBot.create(:thc_charge, organization: organization)
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
    context "with manipulated local_charge (export) attached to the user" do
      before do
        FactoryBot.create(:export_margin,
          origin_hub: hub,
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          applicable: user)
      end

      it "returns the manipulated local_charge (export) attached to the user" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(local_charge.id)
          expect(target_result.result["fees"].keys).to eq(["solas"])
          expect(target_result.result.dig("fees", "solas", "value")).to eq(19.25)
          expect(target_result.result.dig("fees", "solas", "rate_basis")).to eq("PER_SHIPMENT")
        end
      end
    end

    context "with manipulated local_charge (export) attached to the user not covering entire validity" do
      before do
        FactoryBot.create(:export_margin,
          origin_hub: hub,
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          effective_date: local_charge.effective_date + 10.days,
          expiration_date: local_charge.effective_date + 20.days,
          applicable: user)
      end

      let!(:results) { klass.perform.sort_by!(&:effective_date) }

      it "returns the manipulated local_charge first charge" do
        aggregate_failures do
          expect(results.first.result["id"]).to eq(local_charge.id)
          expect(results.first.result["fees"].keys).to eq(["solas"])
          expect(results.first.result.dig("fees", "solas", "value")).to eq(17.5)
          expect(results.first.result.dig("fees", "solas", "rate_basis")).to eq("PER_SHIPMENT")
        end
      end

      it "returns the manipulated local_charge last charge" do
        aggregate_failures do
          expect(results.last.result["id"]).to eq(local_charge.id)
          expect(results.last.result["fees"].keys).to eq(["solas"])
          expect(results.last.result.dig("fees", "solas", "value")).to eq(19.25)
          expect(results.last.result.dig("fees", "solas", "rate_basis")).to eq("PER_SHIPMENT")
        end
      end
    end

    context "with manipulated local_charge (import) attached to the user" do
      before do
        FactoryBot.create(:import_margin,
          destination_hub: hub,
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          applicable: user)
      end

      let(:margin_type) { :import_margin }
      let(:local_charge) {
        FactoryBot.create(:legacy_local_charge,
          hub: hub, direction: "import", tenant_vehicle: tenant_vehicle, organization: organization)
      }

      it "returns the manipulated local_charge (import) attached to the user" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(local_charge.id)
          expect(target_result.result["fees"].keys).to eq(["solas"])
          expect(target_result.result.dig("fees", "solas", "value")).to eq(19.25)
          expect(target_result.result.dig("fees", "solas", "rate_basis")).to eq("PER_SHIPMENT")
        end
      end
    end

    context "with manipulated local_charge (export) attached to the user with multiple margins" do
      let!(:margin_a) do
        FactoryBot.create(:export_margin,
          origin_hub: hub,
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          applicable: user,
          effective_date: (Time.zone.today + 1.day).beginning_of_day,
          expiration_date: (Time.zone.today + 10.days).end_of_day)
      end
      let!(:margin_b) do
        FactoryBot.create(:export_margin,
          origin_hub: hub,
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          applicable: group,
          value: 10,
          operator: "+",
          effective_date: (Time.zone.today + 1.day).beginning_of_day,
          expiration_date: (Time.zone.today + 30.days).end_of_day)
      end
      let!(:results) { klass.perform.sort_by!(&:effective_date) }

      it "returns the manipulated local_charge (export) attached to the user with multiple margins" do
        aggregate_failures do
          expect(results.map { |mp| mp.result["id"] }.uniq).to match_array([local_charge.id])
          expect(results.map { |mp| mp.result.dig("fees", "solas", "value") }).to match_array([17.5, 19.25, 17.5, 17.5])
          expect(results.map(&:flat_margins)).to eq([{}, {"solas" => 0.1e2}, {"solas" => 0.1e2}, {}])
        end
      end

      it "returns the manipulated local_charge with the correct dates" do
        aggregate_failures do
          expect(results[0].expiration_date.end_of_minute).to eq((margin_b.effective_date - 1.day).end_of_day)
          expect(results[1].effective_date).to eq(margin_b.effective_date)
          expect(results[1].expiration_date.end_of_minute).to eq(margin_a.expiration_date)
          expect(results[2].effective_date).to eq((margin_a.expiration_date + 1.day).beginning_of_day)
          expect(results[2].expiration_date.end_of_minute).to eq(margin_b.expiration_date)
        end
      end
    end

    context "with manipulated local_charge (import) attached to the user with multiple margins" do
      before do
        FactoryBot.create(:import_margin,
          destination_hub: hub,
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          applicable: user,
          effective_date: (Time.zone.today + 1.day).beginning_of_day,
          expiration_date: (Time.zone.today + 10.days).end_of_day)
        FactoryBot.create(:import_margin,
          destination_hub: hub,
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          applicable: group,
          value: 10,
          operator: "+",
          effective_date: (Time.zone.today + 1.day).beginning_of_day,
          expiration_date: (Time.zone.today + 30.days).end_of_day)
      end

      let(:margin_type) { :import_margin }
      let(:local_charge) {
        FactoryBot.create(:legacy_local_charge,
          hub: hub, direction: "import", tenant_vehicle: tenant_vehicle, organization: organization)
      }

      it "returns the manipulated local_charge (import) attached to the user with multiple margins" do
        aggregate_failures do
          expect(manipulated_results.map(&:id).uniq).to eq([local_charge.id])
          expect(manipulated_results.flat_map { |pricing| pricing.result["fees"].keys }.uniq).to eq(["solas"])
          expect(manipulated_results.map(&:flat_margins)).to eq([{}, {"solas" => 0.1e2}, {"solas" => 0.1e2}, {}])
          expect(
            manipulated_results.map { |pricing| pricing.result.dig("fees", "solas", "value") }
          ).to match_array([17.5, 19.25, 17.5, 17.5])
          expect(
            manipulated_results.map { |pricing| pricing.result.dig("fees", "solas", "rate_basis") }.uniq
          ).to eq(["PER_SHIPMENT"])
        end
      end
    end

    context "with manipulated local_charge attached to the group" do
      before do
        FactoryBot.create(:export_margin, origin_hub: hub, organization: organization, applicable: group)
      end

      it "returns the manipulated local_charge attached to the group" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(local_charge.id)
          expect(target_result.result["fees"].keys).to eq(["solas"])
          expect(target_result.result.dig("fees", "solas", "value")).to eq(19.25)
          expect(target_result.result.dig("fees", "solas", "rate_basis")).to eq("PER_SHIPMENT")
        end
      end
    end

    context "with multiple manipulated local_charges when margins overlap attached to the group" do
      Timecop.freeze(Time.zone.now) do
        let!(:margin_a) do
          FactoryBot.create(:export_margin,
            origin_hub: hub,
            tenant_vehicle: tenant_vehicle,
            effective_date: (Time.zone.today - 3.days).beginning_of_day,
            expiration_date: (Time.zone.today + 2.days).end_of_day,
            organization: organization,
            applicable: group)
        end
        let!(:margin_b) do
          FactoryBot.create(:export_margin,
            origin_hub: hub,
            tenant_vehicle: tenant_vehicle,
            effective_date: (Time.zone.today + 8.days).beginning_of_day,
            expiration_date: (Time.zone.today + 22.days).end_of_day,
            organization: organization,
            value: 0.5,
            applicable: group)
        end
        let!(:results) { klass.perform.sort_by!(&:effective_date) }

        it "returns multiple manipulated local_charges when margins overlap attached to the group" do
          aggregate_failures do
            expect(results.map(&:id).uniq).to eq([local_charge.id])
            expect(results.flat_map { |pricing| pricing.result["fees"].keys }.uniq).to eq(["solas"])
            expect(
              results.map { |pricing| pricing.result.dig("fees", "solas", "value") }
            ).to eq([19.25, 17.5, 26.25, 17.5])
            expect(
              results.map { |pricing| pricing.result.dig("fees", "solas", "rate_basis") }.uniq
            ).to eq(["PER_SHIPMENT"])
          end
        end

        it "returns multiple manipulated local_charges with the correct dates" do
          aggregate_failures do
            expect(results[0].expiration_date.end_of_minute).to eq(margin_a.expiration_date)
            expect(results[1].effective_date).to eq((margin_a.expiration_date + 1.day).beginning_of_day)
            expect(results[1].expiration_date.end_of_minute).to eq((margin_b.effective_date - 1.day).end_of_day)
            expect(results[2].effective_date).to eq(margin_b.effective_date)
            expect(results[2].expiration_date.end_of_minute).to eq(margin_b.expiration_date)
          end
        end
      end
    end

    context "with manipulated local_charge attached to the group via company" do
      before do
        company = FactoryBot.create(:companies_company, :with_member, organization: organization, member: user)
        FactoryBot.create(:groups_group, organization: organization).tap do |company_group|
          FactoryBot.create(:groups_membership, member: company, group: company_group)
          FactoryBot.create(:export_margin,
            origin_hub: hub, tenant_vehicle: tenant_vehicle, organization: organization, applicable: company_group)
        end
      end

      it "returns the manipulated local_charge attached to the group via company" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(local_charge.id)
          expect(target_result.result["fees"].keys).to eq(["solas"])
          expect(target_result.result.dig("fees", "solas", "value")).to eq(19.25)
          expect(target_result.result.dig("fees", "solas", "rate_basis")).to eq("PER_SHIPMENT")
        end
      end
    end

    context "with manipulated local_charge with specific detail attached to the user" do
      before do
        FactoryBot.create(:export_margin, origin_hub: hub, organization: organization, applicable: user, value: 0)
          .tap do |tapped_margin|
          FactoryBot.create(:pricings_detail,
            margin: tapped_margin, value: 0.25, charge_category: solas_charge_category)
        end
      end

      it "returns the manipulated local_charge with specific detail attached to the user" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(local_charge.id)
          expect(target_result.result["fees"].keys).to eq(["solas"])
          expect(target_result.result.dig("fees", "solas", "value")).to eq(21.875)
          expect(target_result.result.dig("fees", "solas", "rate_basis")).to eq("PER_SHIPMENT")
        end
      end
    end

    context "with manipulated local_charge with one specific detail and general attached to the user" do
      before do
        FactoryBot.create(:export_margin, origin_hub: hub, organization: organization, applicable: user)
          .tap do |tapped_margin|
          FactoryBot.create(:pricings_detail, margin: tapped_margin, value: 0.25, charge_category: baf_charge_category)
        end
      end

      let(:local_charge) do
        FactoryBot.create(:legacy_local_charge,
          hub: hub,
          direction: "export",
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          fees: {
            "SOLAS" => {
              "key" => "SOLAS",
              "max" => nil,
              "min" => 17.5,
              "name" => "SOLAS",
              "value" => 17.5,
              "currency" => "EUR",
              "rate_basis" => "PER_SHIPMENT"
            },
            "baf" => {
              "key" => "baf",
              "max" => nil,
              "min" => 20,
              "name" => "Bunker Adjustment Fee",
              "value" => 20,
              "currency" => "EUR",
              "rate_basis" => "PER_SHIPMENT"
            }
          })
      end
      let!(:results) { klass.perform }

      it "returns the manipulated local_charge with one specific detail and general attached to the user" do
        aggregate_failures do
          expect(results.first.id).to eq(local_charge.id)
          expect(results.first.result["fees"].keys).to eq(%w[solas baf])
        end
      end

      it "returns the manipulated solas fee" do
        aggregate_failures do
          expect(results.first.result.dig("fees", "solas", "value")).to eq(19.25)
          expect(results.first.result.dig("fees", "solas", "rate_basis")).to eq("PER_SHIPMENT")
        end
      end

      it "returns the manipulated baf fee" do
        aggregate_failures do
          expect(results.first.result.dig("fees", "baf", "value")).to eq(25)
          expect(results.first.result.dig("fees", "baf", "rate_basis")).to eq("PER_SHIPMENT")
        end
      end
    end

    context "with manipulated local_charge attached to the user with a range" do
      before do
        FactoryBot.create(:export_margin, origin_hub: hub, organization: organization, applicable: user)
      end

      let(:fees) do
        {
          "SOLAS": {
            "key": "SOLAS",
            "max": nil,
            "min": 17.5,
            "name": "SOLAS",
            "value": 17.5,
            "currency": "EUR",
            "rate_basis": "PER_CBM_TON_RANGE",
            "range": [
              {'min': 0, 'max': 10, 'cbm': 10, 'ton': 40}
            ]
          }
        }
      end
      let(:local_charge) {
        FactoryBot.create(:legacy_local_charge,
          hub: hub, direction: "export", fees: fees, tenant_vehicle: tenant_vehicle, organization: organization)
      }

      it "returns the manipulated local_charge attached to the user with a range" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(local_charge.id)
          expect(target_result.result["fees"].keys).to eq(["solas"])
          expect(target_result.result.dig("fees", "solas", "range", 0, "cbm")).to eq(11)
          expect(target_result.result.dig("fees", "solas", "range", 0, "ton")).to eq(44)
          expect(target_result.result.dig("fees", "solas", "rate_basis")).to eq("PER_CBM_TON_RANGE")
        end
      end
    end

    context "with manipulated local_charge attached to the user for addition margin" do
      before do
        FactoryBot.create(:export_margin,
          origin_hub: hub, organization: organization, applicable: user, value: 10, operator: "+")
      end
      let!(:results) { klass.perform }

      it "returns the manipulated local_charge attached to the user for addition margin", :aggregate_failures do
        expect(target_result.result.dig("fees", "solas", "value")).to eq(17.5)
        expect(target_result.flat_margins).to eq("solas" => 1.0e1)
        expect(target_result.result.dig("fees", "solas", "rate_basis")).to eq("PER_SHIPMENT")
        expect(manipulated_results.map(&:flat_margins)).to match_array([{ "solas" => 1.0e1 }])
        expect(target_result.breakdowns.flat_map(&:data)).to include({ rate_basis: "PER_SHIPMENT" })
      end
    end

    context "with manipulated local_charge attached to the tenant with nothing else" do
      before do
        FactoryBot.create(:export_margin, organization: organization, applicable: organization)
      end

      it "returns the manipulated local_charge attached to the tenant with nothing else" do
        target_result = manipulated_results.first
        aggregate_failures do
          expect(target_result.result["id"]).to eq(local_charge.id)
          expect(target_result.result["fees"].keys).to eq(["solas"])
          expect(target_result.result.dig("fees", "solas", "value")).to eq(19.25)
          expect(target_result.result.dig("fees", "solas", "rate_basis")).to eq("PER_SHIPMENT")
        end
      end
    end

    context "with manipulated local charge with metadata attached to the user - single margin" do
      before do
        FactoryBot.create(:export_margin, organization: organization, applicable: organization)
      end

      let!(:margin) {
        FactoryBot.create(:export_margin,
          origin_hub: hub, tenant_vehicle: tenant_vehicle, organization: organization, applicable: user)
      }
      let!(:target_result) { manipulated_results.first }

      it "returns the manipulated local charge with metadata attached to the user - general info" do
        aggregate_failures do
          expect(target_result.id).to eq(local_charge.id)
          expect(target_result.breakdowns.map(&:code).uniq).to eq(%w[solas])
          expect(target_result.breakdowns.length).to eq(2)
        end
      end

      it "returns the manipulated local charge with metadata attached to the user - single margin" do
        aggregate_failures do
          expect(target_result.breakdowns.second.source).to eq(margin)
          expect(target_result.breakdowns.second.delta).to eq(margin.value)
        end
      end
    end

    context "with manipulated local charge with metadata attached to the user - double margin" do
      let!(:margin1) do
        FactoryBot.create(:export_margin,
          origin_hub: hub,
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          applicable: user)
      end
      let!(:margin2) do
        FactoryBot.create(:export_margin,
          origin_hub: hub,
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          applicable: user,
          value: 50,
          operator: "+")
      end
      let!(:target_result) { manipulated_results.first }

      it "returns the manipulated local charge with metadata attached to the user - general info" do
        aggregate_failures do
          expect(target_result.id).to eq(local_charge.id)
          expect(target_result.breakdowns.map(&:code).uniq).to eq(%w[solas])
          expect(target_result.breakdowns.length).to eq(3)
        end
      end

      it "returns the manipulated local charge with metadata attached to the user - first margin" do
        aggregate_failures do
          expect(target_result.breakdowns.second.source).to eq(margin1)
          expect(target_result.breakdowns.second.delta).to eq(margin1.value)
        end
      end

      it "returns the manipulated local charge with metadata attached to the user - second margin" do
        aggregate_failures do
          expect(target_result.breakdowns.third.source).to eq(margin2)
          expect(target_result.breakdowns.third.delta).to eq(margin2.value)
        end
      end
    end

    context "with manipulated local charge with metadata attached to the user - flat margin, many fees" do
      let(:fees) do
        {
          "SOLAS" => {
            "key" => "SOLAS",
            "max" => nil,
            "min" => 17.5,
            "name" => "SOLAS",
            "value" => 17.5,
            "currency" => "EUR",
            "rate_basis" => "PER_SHIPMENT"
          },
          "THC" => {
            "key" => "THC",
            "max" => nil,
            "min" => 15,
            "name" => "THC",
            "value" => 15,
            "currency" => "EUR",
            "rate_basis" => "PER_WM"
          }
        }
      end
      let(:local_charge) do
        FactoryBot.create(:legacy_local_charge,
          hub: hub,
          direction: "export",
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          fees: fees)
      end

      let!(:margin1) do
        FactoryBot.create(:export_margin,
          origin_hub: hub,
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          applicable: user)
      end
      let!(:margin2) do
        FactoryBot.create(:export_margin,
          origin_hub: hub,
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          applicable: user,
          value: 50,
          operator: "+")
      end
      let!(:target_result) { manipulated_results.first }

      it "returns the manipulated local charge with metadata attached to the user - general info" do
        aggregate_failures do
          expect(target_result.id).to eq(local_charge.id)
          expect(target_result.breakdowns.map(&:code).uniq).to eq(%w[solas thc])
          expect(target_result.breakdowns.length).to eq(6)
        end
      end

      it "returns the manipulated local charge with metadata attached to the user - first fee" do
        solas_breakdowns = target_result.breakdowns.select { |br| br.code == "solas" }
        aggregate_failures do
          expect(solas_breakdowns.length).to eq(3)
          expect(solas_breakdowns.second.source).to eq(margin1)
          expect(solas_breakdowns.second.delta).to eq(margin1.value)
          expect(solas_breakdowns.third.source).to eq(margin2)
          expect(solas_breakdowns.third.delta).to eq(margin2.value / 2)
        end
      end

      it "returns the manipulated local charge with metadata attached to the user - second fee" do
        thc_breakdowns = target_result.breakdowns.select { |br| br.code == "thc" }
        aggregate_failures do
          expect(thc_breakdowns.length).to eq(3)
          expect(thc_breakdowns.second.source).to eq(margin1)
          expect(thc_breakdowns.second.delta).to eq(margin1.value)
          expect(thc_breakdowns.third.source).to eq(margin2)
          expect(thc_breakdowns.third.delta).to eq(margin2.value / 2)
        end
      end
    end

    context "with with atypical json data" do
      let(:fees) do
        {
          "SOLAS" => {
            "key" => "SOLAS",
            "max" => nil,
            "min" => 17.5,
            "name" => "SOLAS",
            "value" => 17.5,
            "currency" => "EUR",
            "rate_basis" => "PER_SHIPMENT",
            "metadata" => {}
          },
          "THC" => {
            "key" => "THC",
            "max" => nil,
            "min" => 15,
            "name" => "THC",
            "value" => 15,
            "currency" => "EUR",
            "rate_basis" => "PER_WM",
            "rate_basis_id" => ""
          }
        }
      end
      let(:local_charge) do
        FactoryBot.create(:legacy_local_charge,
          hub: hub,
          direction: "export",
          tenant_vehicle: tenant_vehicle,
          organization: organization,
          fees: fees)
      end

      it "returns the manipulated local charge with no errors", :aggregate_failures do
        expect(target_result.id).to eq(local_charge.id)
        expect(target_result.breakdowns.map(&:code).uniq).to eq(%w[solas thc])
      end
    end
  end
end
