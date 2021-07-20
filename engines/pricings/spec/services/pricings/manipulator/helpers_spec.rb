# frozen_string_literal: true

require "rails_helper"

RSpec.describe Pricings::Manipulator do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:vehicle) { FactoryBot.create(:vehicle, tenant_vehicles: [tenant_vehicle]) }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly", organization: organization) }
  let!(:currency) { FactoryBot.create(:legacy_currency) }
  let!(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:lcl_shipment) { FactoryBot.create(:legacy_shipment, organization: organization, user: user) }
  let(:itinerary) { FactoryBot.create(:legacy_itinerary, organization: organization) }
  let(:trips) do
    [1, 3].map do |num|
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

  let(:args) do
    {
      pricing: pricing,
      schedules: schedules,
      cargo_class_count: target_shipment.cargo_classes.count,
      without_meta: true
    }
  end

  let!(:default_group) { FactoryBot.create(:groups_group, :default, organization: organization) }

  let(:klass) do
    described_class.new(
      target: user,
      organization: organization,
      type: :freight_margin,
      args: args
    )
  end
  let(:target_shipment) { lcl_shipment }
  let(:pricing) {
    FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle, organization: organization)
  }

  before do
    FactoryBot.create(:freight_margin,
      default_for: "ocean", organization: organization, applicable: organization, value: 0)
  end

  describe "fee_keys" do
    let(:args) do
      {
        schedules: schedules,
        itinerary_id: itinerary.id,
        cargo_class_count: target_shipment.cargo_classes.count
      }
    end

    it "returns an empty array when no variables are present" do
      expect(klass.fee_keys).to match_array([])
    end
  end

  describe "sanitize_date" do
    let(:args) do
      {
        schedules: schedules,
        itinerary_id: itinerary.id,
        cargo_class_count: target_shipment.cargo_classes.count
      }
    end

    it "returns a DateTime" do
      expect(klass.sanitize_date("2020/12/31")).to eq(DateTime.parse("2020/12/31"))
    end
  end

  describe ".applicable_margins" do
    let(:margins) { klass.applicable_margins }

    context "with freight pricings and user margin" do
      let!(:user_margin) {
        FactoryBot.create(:freight_margin, pricing: pricing, organization: organization, applicable: user)
      }

      it "returns the applicable margin attached to the user" do
        expect(margins.first[:margin]).to eq(user_margin)
      end
    end

    context "with freight pricings and tenant margin" do
      let!(:tenant_margin) {
        FactoryBot.create(:freight_margin, pricing: pricing, organization: organization, applicable: organization)
      }

      it "returns the applicable margin attached to the tenant when the user has none" do
        expect(margins.first[:margin]).to eq(tenant_margin)
      end
    end

    context "with freight pricings and user and company group margin" do
      let!(:user_margin) {
        FactoryBot.create(:freight_margin, pricing: pricing, organization: organization, applicable: user)
      }
      let!(:group_margin) {
        FactoryBot.create(:freight_margin, pricing: pricing, organization: organization, applicable: group)
      }
      let(:group) {
        FactoryBot.create(:groups_group, name: "Test", organization: organization).tap do |tapped_group|
          FactoryBot.create(:groups_membership, member: user, group: tapped_group)
        end
      }
      let(:company) do
        FactoryBot.create(:companies_companies, organization: organization).tap do |tapped_company|
          FactoryBot.create(:companies_membership, member: user, company: tapped_company)
        end
      end

      let(:user_result) { margins.find { |result| result[:margin] == user_margin } }
      let(:group_result) { margins.find { |result| result[:margin] == group_margin } }

      before do
        FactoryBot.create(:groups_group, organization: organization).tap do |tapped_group|
          FactoryBot.create(:groups_membership, member: user, group: tapped_group)
        end
      end

      it "returns the applicable margin attached to the user" do
        aggregate_failures do
          expect(user_result[:priority]).to eq(0)
          expect(group_result[:priority]).to eq(2)
        end
      end
    end
  end

  context "when initializing variables" do
    context "when user is nil" do
      let(:user) { nil }

      it "sets the target as the default group" do
        expect(klass.send(:target)).to eq(default_group)
      end
    end
  end
end
