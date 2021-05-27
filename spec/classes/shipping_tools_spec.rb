# frozen_string_literal: true

require "rails_helper"
require "active_storage"

RSpec.describe ShippingTools do
  before do
    ::Organizations.current_id = organization.id
    stub_request(:get, "https://assets.itsmycargo.com/assets/icons/mail/mail_ocean.png")
      .to_return(status: 200, body: "", headers: {})
    stub_request(:get, "https://assets.itsmycargo.com/assets/logos/logo_box.png")
      .to_return(status: 200, body: "", headers: {})
  end

  let!(:organization) { FactoryBot.create(:organizations_organization, scope: scope) }
  let(:scope) do
    FactoryBot.build(:organizations_scope,
      content: { send_email_on_quote_download: true, send_email_on_quote_email: true })
  end
  let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:user) { FactoryBot.create(:users_client, organization: organization) }
  let(:group) do
    FactoryBot.create(:groups_group, name: "Test", organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: user, group: tapped_group)
    end
  end
  let(:tenant_vehicle) { FactoryBot.create(:tenant_vehicle, organization: organization) }

  describe ".create_shipment" do
    let(:details) { { loadType: "container", direction: "export" }.with_indifferent_access }
    let(:result) { described_class.new.create_shipment(details, user) }
    let!(:itinerary_with_no_pricing) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }

    before do
      FactoryBot.create(:pricings_pricing,
        itinerary: itinerary,
        cargo_class: "fcl_20",
        load_type: details[:loadType],
        organization: organization, group_id: group.id,
        tenant_vehicle: tenant_vehicle,
        internal: false)
      ::Organizations.current_id = organization.id
    end

    shared_examples_for "Create Shipment" do
      it "creates the shipment and sends routes matching with valid pricings", :aggregate_failures do
        expect(result["routes"]).not_to be_empty
        expect(result["routes"].find { |route| route["itineraryId"] == itinerary.id }).not_to be_nil
        expect(result["routes"].find { |route| route["itineraryId"] == itinerary_with_no_pricing.id }).to be_nil
      end
    end

    context "with base pricing  && display_itineraries_with_rates enabled" do
      it_behaves_like "Create Shipment"
    end

    context "with base pricing  && display_itineraries_with_rates enabled && user margins" do
      before do
        FactoryBot.create(:pricings_margin, applicable: group, organization: organization)
        scope.update(content: { display_itineraries_with_rates: true })
      end

      it_behaves_like "Create Shipment"
    end

    context "with base pricing  && expired rates" do
      let(:itinerary_with_no_pricing) do
        FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization)
      end

      before do
        FactoryBot.create(:pricings_pricing,
          itinerary: itinerary_with_no_pricing,
          cargo_class: "fcl_20",
          load_type: details[:loadType],
          organization: organization, group_id: group.id,
          tenant_vehicle: tenant_vehicle,
          internal: false,
          expiration_date: Time.zone.today - 1.day,
          effective_date: Time.zone.today - 10.days)
      end

      it_behaves_like "Create Shipment"
    end
  end
end
