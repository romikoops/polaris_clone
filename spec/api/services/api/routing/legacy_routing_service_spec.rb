# frozen_string_literal: true

require "rails_helper"

RSpec.describe Api::Routing::LegacyRoutingService, type: :service do
  let(:organization) { FactoryBot.create(:organizations_organization) }
  let(:user) { FactoryBot.create(:organizations_user, organization: organization) }
  let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization_id: organization.id) }
  let(:load_type) { "container" }
  let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, organization: organization) }
  let(:scope) { {display_itineraries_with_rates: true} }
  let(:group_member) { user }
  let(:group) do
    FactoryBot.create(:groups_group, name: "Test", organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: group_member, group: tapped_group)
    end
  end
  let(:company) do
    FactoryBot.create(:companies_company, name: "Test", organization: organization).tap do |tapped_company|
      FactoryBot.create(:companies_membership, member: user, company: tapped_company)
    end
  end
  let(:result) do
    described_class.routes(
      organization: organization,
      user: user,
      load_type: load_type,
      scope: scope
    )
  end

  before do
    ::Organizations.current_id = organization.id
  end

  describe ".routes" do
    context "with display_itineraries_with_rates disabled" do
      let(:scope) { {display_itineraries_with_rates: false} }
      let!(:itinerary_with_no_pricing) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }

      before do
        FactoryBot.create(:pricings_pricing,
          itinerary: itinerary,
          cargo_class: "fcl_20",
          load_type: load_type,
          organization: organization,
          tenant_vehicle: tenant_vehicle,
          internal: false)
      end

      it "creates the shipment and sends routes matching with valid pricings" do
        aggregate_failures do
          expect(result[:route_hashes]).not_to be_empty
          expect(result[:route_hashes].find { |route| route[:itinerary_id] == itinerary.id }).not_to be_nil
          expect(result[:route_hashes].find { |route| route[:itinerary_id] == itinerary_with_no_pricing.id }).to be_nil
        end
      end
    end

    context "with display_itineraries_with_rates enabled" do
      let!(:itinerary_with_no_pricing) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }

      before do
        FactoryBot.create(:pricings_pricing,
          itinerary: itinerary,
          cargo_class: "fcl_20",
          load_type: load_type,
          organization: organization, group_id: group.id,
          tenant_vehicle: tenant_vehicle,
          internal: false)
      end

      it "creates the shipment and sends routes matching with valid pricings" do
        aggregate_failures do
          expect(result[:route_hashes]).not_to be_empty
          expect(result[:route_hashes].find { |route| route[:itinerary_id] == itinerary.id }).not_to be_nil
          expect(result[:route_hashes].find { |route| route[:itinerary_id] == itinerary_with_no_pricing.id }).to be_nil
        end
      end
    end

    context "with display_itineraries_with_rates enabled and comapny groups" do
      let!(:itinerary_with_no_pricing) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }
      let(:group_member) { company }

      before do
        FactoryBot.create(:pricings_pricing,
          itinerary: itinerary,
          cargo_class: "fcl_20",
          load_type: load_type,
          organization: organization, group_id: group.id,
          tenant_vehicle: tenant_vehicle,
          internal: false)
      end

      it "creates the shipment and sends routes matching with valid pricings" do
        aggregate_failures do
          expect(result[:route_hashes]).not_to be_empty
          expect(result[:route_hashes].find { |route| route[:itinerary_id] == itinerary.id }).not_to be_nil
          expect(result[:route_hashes].find { |route| route[:itinerary_id] == itinerary_with_no_pricing.id }).to be_nil
        end
      end
    end

    context "with display_itineraries_with_rates enabled && user margins" do
      let!(:itinerary_with_no_pricing) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }

      before do
        FactoryBot.create(:pricings_pricing,
          itinerary: itinerary,
          cargo_class: "fcl_20",
          load_type: load_type,
          organization: organization, group_id: group.id,
          tenant_vehicle: tenant_vehicle,
          internal: false)
        FactoryBot.create(:pricings_margin, applicable: group, organization: organization)
      end

      it "creates the shipment and sends routes matching with valid pricings" do
        aggregate_failures do
          expect(result[:route_hashes]).not_to be_empty
          expect(result[:route_hashes].find { |route| route[:itinerary_id] == itinerary.id }).not_to be_nil
          expect(result[:route_hashes].find { |route| route[:itinerary_id] == itinerary_with_no_pricing.id }).to be_nil
        end
      end
    end

    context "withexpired rates" do
      let(:itinerary_with_expired_pricing) {
        FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization)
      }

      before do
        FactoryBot.create(:pricings_pricing,
          itinerary: itinerary,
          cargo_class: "fcl_20",
          load_type: load_type,
          organization: organization, group_id: group.id,
          tenant_vehicle: tenant_vehicle,
          internal: false)
        FactoryBot.create(:pricings_pricing,
          itinerary: itinerary_with_expired_pricing,
          cargo_class: "fcl_20",
          load_type: load_type,
          organization: organization, group_id: group.id,
          tenant_vehicle: tenant_vehicle,
          internal: false,
          expiration_date: Time.zone.today - 1.day,
          effective_date: Time.zone.today - 10.days)
      end

      it "creates the shipment and sends routes matching with valid pricings" do
        aggregate_failures do
          expect(result[:route_hashes]).not_to be_empty
          expect(result[:route_hashes].find { |route| route[:itinerary_id] == itinerary.id }).not_to be_nil
          expect(
            result[:route_hashes].find { |route| route[:itinerary_id] == itinerary_with_expired_pricing.id }
          ).to be_nil
        end
      end
    end
  end
end
