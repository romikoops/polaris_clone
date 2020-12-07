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

  let!(:organization) { FactoryBot.create(:organizations_organization) }
  let!(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
  let(:itinerary_2) { FactoryBot.create(:hamburg_shanghai_itinerary, organization: organization) }
  let(:trip) { FactoryBot.create(:trip, itinerary_id: itinerary.id) }
  let(:origin_hub) { Hub.find(itinerary.hubs.find_by(name: "Gothenburg").id) }
  let(:destination_hub) { Hub.find(itinerary.hubs.find_by(name: "Shanghai").id) }
  let!(:scope) {
    FactoryBot.create(:organizations_scope, target: organization, content: {
      send_email_on_quote_download: true, send_email_on_quote_email: true, base_pricing: true
    })
  }
  let(:user) { FactoryBot.create(:organizations_user, :with_profile, organization: organization) }
  let(:group) do
    FactoryBot.create(:groups_group, name: "Test", organization: organization).tap do |tapped_group|
      FactoryBot.create(:groups_membership, member: user, group: tapped_group)
    end
  end
  let(:hidden_args) { Pdf::HiddenValueService.new(user: user).hide_total_args }
  let(:args) { Pdf::HiddenValueService.new(user: user).hide_total_args }
  let(:tenant_vehicle) { FactoryBot.create(:tenant_vehicle, organization: organization) }
  let(:quotation) { Quotations::Quotation.find_by(legacy_shipment_id: shipment.id) }
  let(:shipment) do
    FactoryBot.create(:legacy_shipment,
      user: user,
      trip: trip,
      organization: organization,
      origin_hub: origin_hub,
      destination_hub: destination_hub,
      origin_nexus: origin_hub&.nexus,
      destination_nexus: destination_hub&.nexus,
      with_tenders: completed,
      with_breakdown: completed)
  end
  let(:completed) { false }
  let(:schedules) { [Legacy::Schedule.from_trip(trip)] }
  let(:tender) { Quotations::Tender.find(shipment.charge_breakdowns.first.tender_id) }
  let(:params) do
    {
      shipment_id: shipment.id,
      meta: {tender_id: tender.id},
      schedule: {
        "trip_id" => trip.id, :charge_trip_id => trip.id,
        :origin_hub => origin_hub,
        :destination_hub => destination_hub
      }
    }.with_indifferent_access
  end

  context "when sending admin emails on quote download" do
    let(:shipment) do
      FactoryBot.create(:complete_legacy_shipment,
        user: user,
        trip: trip,
        organization: organization,
        origin_hub: origin_hub,
        destination_hub: destination_hub,
        origin_nexus: origin_hub&.nexus,
        destination_nexus: destination_hub&.nexus,
        with_breakdown: true,
        with_tenders: true)
    end
    let!(:charge_breakdown) { shipment.charge_breakdowns.first }
    let(:results) do
      [
        {
          quote: charge_breakdown.to_nested_hash(args, sub_total_charge: false),
          schedules: [
            {
              "trip_id" => charge_breakdown.trip_id,
              :origin_hub => origin_hub,
              :destination_hub => destination_hub
            }
          ],
          meta: {:charge_trip_id => trip.id, "tender_id" => charge_breakdown.tender_id}
        }.with_indifferent_access
      ]
    end

    before do
      FactoryBot.create(:legacy_quotation, original_shipment: shipment)
    end

    describe ".save_pdf_quotes" do
      before do
        shipment.charge_breakdowns.map(&:tender).each do |tender|
          Legacy::ExchangeRate.create(from: tender.amount.currency.iso_code,
                                      to: "USD", rate: 1.3,
                                      created_at: tender.created_at - 30.seconds)
        end
      end

      it "successfully calls the mailer and return the quote Document" do
        described_class.new.save_pdf_quotes(shipment, user.organization, results)
      end
    end

    describe ".save_and_send_quotes" do
      it "successfully calls the mailer and return the quote Document" do
        described_class.new.save_and_send_quotes(shipment, results, user.email)
      end

      context "when send_email_on_quote_email is set to true" do
        it "sends an email to the admin" do
          expect {
            described_class.new.save_and_send_quotes(shipment, results, user.email)
          }.to have_enqueued_job(ActionMailer::DeliveryJob).at_least(2).times
        end
      end
    end
  end

  describe ".request_shipment" do
    let(:completed) { true }

    before do
      shipment_request_creator = instance_double("Shipments::ShipmentRequestCreator", errors: [])
      shipment_request = instance_double("Shipments::ShipmentRequest", id: 1, organization_id: 123)
      allow(Shipments::ShipmentRequestCreator).to receive(:new).with(legacy_shipment: shipment, user: user)
        .and_return(shipment_request_creator)
      allow(shipment_request_creator).to receive(:create).once
      allow(shipment_request_creator).to receive(:shipment_request).and_return(shipment_request)
      allow(Integrations::Processor).to receive(:process).once.with(shipment_request_id: 1, organization_id: 123)
    end

    it "persists data into the engine models" do
      described_class.new.request_shipment(params, user)
    end
  end

  describe ".create_shipment" do
    let(:details) { {loadType: "container", direction: "export"}.with_indifferent_access }

    before { ::Organizations.current_id = organization.id }

    context "with base pricing  && display_itineraries_with_rates enabled" do
      let!(:itinerary_with_no_pricing) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }

      before do
        FactoryBot.create(:pricings_pricing,
          itinerary: itinerary,
          cargo_class: "fcl_20",
          load_type: details[:loadType],
          organization: organization, group_id: group.id,
          tenant_vehicle: tenant_vehicle,
          internal: false)
        scope.update(content: {base_pricing: true, display_itineraries_with_rates: true})
      end

      it "creates the shipment and sends routes matching with valid pricings" do
        result = described_class.new.create_shipment(details, user)
        aggregate_failures do
          expect(result["routes"]).not_to be_empty
          expect(result["routes"].find { |route| route["itineraryId"] == itinerary.id }).not_to be_nil
          expect(result["routes"].find { |route| route["itineraryId"] == itinerary_with_no_pricing.id }).to be_nil
        end
      end
    end

    context "with base pricing  && display_itineraries_with_rates enabled && user margins" do
      let!(:itinerary_with_no_pricing) { FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization) }

      before do
        FactoryBot.create(:pricings_pricing,
          itinerary: itinerary,
          cargo_class: "fcl_20",
          load_type: details[:loadType],
          organization: organization, group_id: group.id,
          tenant_vehicle: tenant_vehicle,
          internal: false)
        FactoryBot.create(:pricings_margin, applicable: group, organization: organization)
        scope.update(content: {base_pricing: true, display_itineraries_with_rates: true})
      end

      it "creates the shipment and sends routes matching with valid pricings" do
        result = described_class.new.create_shipment(details, user)
        aggregate_failures do
          expect(result["routes"]).not_to be_empty
          expect(result["routes"].find { |route| route["itineraryId"] == itinerary.id }).not_to be_nil
          expect(result["routes"].find { |route| route["itineraryId"] == itinerary_with_no_pricing.id }).to be_nil
        end
      end
    end

    context "with base pricing  && expired rates" do
      let(:itinerary_with_expired_pricing) {
        FactoryBot.create(:shanghai_gothenburg_itinerary, organization: organization)
      }

      before do
        FactoryBot.create(:pricings_pricing,
          itinerary: itinerary,
          cargo_class: "fcl_20",
          load_type: details[:loadType],
          organization: organization, group_id: group.id,
          tenant_vehicle: tenant_vehicle,
          internal: false)
        FactoryBot.create(:pricings_pricing,
          itinerary: itinerary_with_expired_pricing,
          cargo_class: "fcl_20",
          load_type: details[:loadType],
          organization: organization, group_id: group.id,
          tenant_vehicle: tenant_vehicle,
          internal: false,
          expiration_date: Time.zone.today - 1.day,
          effective_date: Time.zone.today - 10.days)
      end

      it "creates the shipment and sends routes matching with valid pricings" do
        result = described_class.new.create_shipment(details, user)
        aggregate_failures do
          expect(result["routes"]).not_to be_empty
          expect(result["routes"].find { |route| route["itineraryId"] == itinerary.id }).not_to be_nil
          expect(result["routes"].find { |route| route["itineraryId"] == itinerary_with_expired_pricing.id }).to be_nil
        end
      end
    end
  end

  describe ".get_offers" do
    let(:current_user) { FactoryBot.create(:organizations_user, organization: organization) }
    let(:shipment_params) do
      shipment.as_json.merge(
        origin: {
          longitude: origin_hub.longitude,
          latitude: origin_hub.latitude,
          nexus_id: origin_hub.nexus.id,
          nexus_name: origin_hub.nexus.name,
          country: origin_hub.nexus.country.name
        },
        destination: {
          longitude: destination_hub.longitude,
          latitude: destination_hub.latitude,
          nexus_id: destination_hub.nexus.id,
          nexus_name: destination_hub.nexus.name,
          country: destination_hub.nexus.country.name
        },
        direction: "export",
        selected_day: Time.zone.today,
        containers_attributes: [{
          size_class: "fcl_40",
          quantity: 1,
          payload_in_kg: 12,
          dangerous_goods: false
        }],
        async: false
      )
    end
    let(:params) do
      ActionController::Parameters.new(shipment_id: shipment.id, shipment: shipment_params)
    end

    let(:offer_calculator_double) { instance_double(OfferCalculator::Calculator) }

    before do
      allow(OfferCalculator::Calculator).to receive(:new).and_return(offer_calculator_double)
    end

    context "when failing with a guest user" do
      before do
        Organizations::Scope.find_by(target_id: organization.id)
          .update(content: {closed_after_map: true, base_pricing: true})
      end

      let(:current_user) { nil }

      it "raises an Application::NotLoggedInError" do
        expect {
          described_class.new.get_offers(params, nil)
        }.to raise_error(ApplicationError, "Please sign in to continue with your booking request.")
      end
    end

    context "when failing in OfferCalculator" do
      let(:offer_calculator_error_map) do
        {
          "OfferCalculator::Errors::LoadMeterageExceeded":
            "Your shipment has exceeded the load meterage limits for online booking.",
          "ArgumentError": "Something has gone wrong!"
        }
      end

      it "rescues errors from the offer calculator service and spews the right messages" do
        offer_calculator_error_map.each do |key, message|
          allow(offer_calculator_double).to receive(:perform).and_raise(key.to_s.constantize)
          expect {
            described_class.new.get_offers(params, current_user).perform
          }.to raise_error(ApplicationError, message)
        end
      end
    end

    describe "success cases" do
      let(:mock_offer_calculator) { instance_double("OfferCalculator::Calculator") }
      let(:mock_offer_results) do
        instance_double("OfferCalculator::Results", shipment: shipment, quotation: quotation)
      end
      let(:completed) { true }
      let(:result) { described_class.new.get_offers(params, user) }

      before do
        allow(OfferCalculator::Calculator).to receive(:new).and_return(mock_offer_calculator)
        allow(mock_offer_calculator).to receive(:perform).and_return(mock_offer_results)
        allow(OfferCalculator::QuotedShipmentsJob).to receive(:perform_later)
      end

      it "returns the correct response including the cargo units" do
        aggregate_failures do
          expect(result[:shipment]).to eq(mock_offer_results.shipment)
          expect(result[:quotationId]).to eq(quotation.id)
          expect(result[:originHubs]).to be_present
          expect(result[:destinationHubs]).to be_present
          expect(result[:results]).to be_present
        end
      end

      it "returns the correct response including the cargo units for a quote setup" do
        Organizations::Scope.find_by(target_id: organization.id)
          .update(content: {closed_quotation_tool: true, email_all_quotes: true})

        aggregate_failures do
          expect(result[:shipment]).to eq(mock_offer_results.shipment)
          expect(result[:quotationId]).to eq(quotation.id)
          expect(result[:originHubs]).to be_present
          expect(result[:destinationHubs]).to be_present
          expect(result[:results]).to be_present
        end
      end

      context "with trucking, quote and breakdowns" do
        before do
          shipment.update(
            trucking: {"pre_carriage" => {"truck_type" => "default", "trucking_time_in_seconds" => 10_000}}
          )
          FactoryBot.create(:pricings_metadatum, charge_breakdown: shipment.charge_breakdowns.first,
                                                 organization: organization)
        end

        it "returns the correct response including the cargo units for a quote setup with trucking" do
          Organizations::Scope.find_by(target_id: organization.id).update(content: {closed_quotation_tool: true})

          aggregate_failures do
            expect(result[:shipment]).to eq(mock_offer_results.shipment)
            expect(result[:quotationId]).to eq(quotation.id)
            expect(result[:originHubs]).to be_present
            expect(result[:destinationHubs]).to be_present
            expect(result[:results]).to be_present
          end
        end
      end

      context "with shipment created by guest user" do
        before do
          shipment.update(user_id: nil)
        end

        it "returns the correct response including the cargo units for a quote setup with trucking" do
          aggregate_failures do
            expect(result[:shipment]).to eq(mock_offer_results.shipment)
            expect(result[:quotationId]).to eq(quotation.id)
            expect(result[:originHubs]).to be_present
            expect(result[:destinationHubs]).to be_present
            expect(result[:results]).to be_present
          end
        end
      end
    end
  end

  describe ".update_shipment" do
    let(:current_user) { FactoryBot.create(:organizations_user, organization: organization) }
    let(:address) { FactoryBot.create(:address, country: FactoryBot.create(:country)) }
    let(:itinerary_2) { FactoryBot.create(:itinerary, name: "A - B", organization: organization) }
    let(:contact) { FactoryBot.create(:contact, user: current_user, address: address) }
    let(:trip) { FactoryBot.create(:trip, itinerary: itinerary_2, tenant_vehicle: tenant_vehicle) }
    let(:user_params) do
      {
        address: {street: "Avenyen", streetNumber: "7", zipCode: "", city: "Gothenburg", country: "Sweden"},
        contact: {companyName: "ItsMyCargo", firstName: "Test2", lastName: "shipper", email: "test@itsmycargo.com",
                  phone: "123"}
      }
    end
    let(:shipment) do
      FactoryBot.create(:complete_legacy_shipment,
        user: user,
        trip: trip,
        organization: organization,
        origin_hub: origin_hub,
        destination_hub: destination_hub,
        origin_nexus: origin_hub&.nexus,
        destination_nexus: destination_hub&.nexus,
        with_tenders: true,
        with_breakdown: true,
        total_goods_value: {currency: "USD", value: "1000.00"})
    end
    let(:shipment_data) do
      {
        hsCodes: {},
        hsTexts: {},
        totalGoodsValue: {},
        cargoNotes: {},
        incotermText: "This is an incoterm text",
        shipper: ActionController::Parameters.new(
          address: {street: "Brooktorkai", streetNumber: "7", zipCode: "", city: "Hamburg", country: "Germany"},
          contact: {companyName: "ItsMyCargo", firstName: "Test", lastName: "shipper",
                    email: "shipper_test@itsmycargo.com", phone: "123"}
        ),
        notifyees: [user_params],
        insurance: {isSelected: true, val: 1000},
        customs: {total: {val: 34, currency: "USD"}, import: {bool: true, val: "22", currency: "USD"},
                  export: {bool: true, val: 12, currency: "USD"}},
        addons: {customs_export_paper: {value: 12, currency: "USD"}},
        consignee: ActionController::Parameters.new(
          address: {street: "Avenyen", streetNumber: "7", zipCode: "", city: "Gothenburg", country: "Sweden"},
          contact: {companyName: "ItsMyCargo", firstName: "Test2", lastName: "shipper",
                    email: "consignee_test@itsmycargo.com", phone: "123"}
        ),
        notes: []
      }
    end
    let(:params) { ActionController::Parameters.new(shipment_id: shipment.id, shipment: shipment_data) }
    let(:contact_params) do
      ActionController::Parameters.new(
        address: {street: "Brooktorkai", streetNumber: "7", zipCode: "", city: "Hamburg", country: "Germany"},
        contact: {
          companyName: "ItsMyCargo",
          firstName: "Test",
          lastName: "shipper",
          email: "shipper_test@itsmycargo.com",
          phone: "123"
        }
      )
    end
    let(:expected_keys) {
      %i[cargoItems
        containers
        aggregatedCargo
        addresses
        consignee
        notifyees
        shipper
        documents
        cargoItemTypes
        shipment]
    }
    let(:tender) { shipment.charge_breakdowns.selected.tender }

    before do
      FactoryBot.create(:legacy_file, :with_file, shipment: shipment, doc_type: "packing_sheet")
      allow(Address).to receive(:create_and_geocode).and_return(address)
    end

    it "updates the shipment appropriately with the attributes in the parameters" do
      result = described_class.new.update_shipment(params, current_user)
      aggregate_failures do
        expected_keys.each do |key|
          expect(result.key?(key)).to be(true)
        end
        expect(tender.line_items.where(section: :insurance_section).count).to eq(1)
        expect(tender.line_items.where(section: :insurance_section).map(&:code)).to eq(["freight_insurance"])
        expect(tender.line_items.where(section: :customs_section).count).to eq(2)
        expect(
          tender.line_items.where(section: :customs_section).map(&:code)
        ).to match_array(["export_customs", "import_customs"])
        expect(tender.line_items.where(section: :addons_section).count).to eq(1)
      end
    end

    it "does not allow shipper and consignee to be the same contact" do
      params = ActionController::Parameters.new(shipment_id: shipment.id, shipment: {
        shipper: contact_params,
        consignee: contact_params
      })
      expect { described_class.new.update_shipment(params, current_user) }.to raise_error(ApplicationError)
    end
  end

  describe ".choose_offer" do
    let(:params) { {} }
    let(:current_user) { FactoryBot.create(:organizations_user, organization: organization) }
    let(:user) { current_user }
    let(:completed) { true }

    context "when failing with a guest user" do
      let(:current_user) { nil }

      before do
        Organizations::Scope.find_by(target_id: organization.id).update(content: {closed_after_map: true})
      end

      it "throws an ApplicationError::NotLoggedIn with a guest user" do
        expect { described_class.new.choose_offer(params, current_user) }.to raise_error(ApplicationError)
      end
    end

    context "when failing with an invalid shipment_id" do
      it "raises an ApplicationError::ShipmentNotFound error" do
        expect { described_class.new.choose_offer({shipment_id: 5}, current_user) }.to raise_error(ApplicationError)
      end
    end

    context "when basic fcl example" do
      let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary_2, tenant_vehicle: tenant_vehicle) }
      let(:schedule) { OfferCalculator::Schedule.from_trip(trip) }
      let(:params) do
        {
          shipment_id: shipment.id,
          customs_credit: {},
          schedule: schedule.as_json.merge(
            origin_hub: schedule.origin_hub,
            destination_hub: schedule.destination_hub,
            charge_trip_id: schedule.trip_id
          ).with_indifferent_access,
          meta: {
            pricing_rate_data: {},
            pricing_breakdown: {},
            tender_id: tender.id
          }
        }
      end
      let(:quotation) { tender.quotation }
      let(:result) { described_class.new.choose_offer(params, user) }

      before { FactoryBot.create(:charge_breakdown, shipment: shipment, tender_id: tender.id) }

      it "selects an offer for the shipment and assigns a reference number" do
        aggregate_failures do
          expect(result[:shipment]["trip_id"]).to eq(trip.id)
          expect(result[:shipment]["tender_id"]).to eq(tender.id)
          expect(quotation.user).to eq(current_user)
          expect(quotation.creator).to eq(current_user)
        end
      end
    end

    context "when user settings is nil" do
      let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary_2, tenant_vehicle: tenant_vehicle) }
      let(:schedule) { OfferCalculator::Schedule.from_trip(trip) }
      let(:params) do
        {
          shipment_id: shipment.id,
          customs_credit: {},
          schedule: schedule.as_json.merge(
            origin_hub: schedule.origin_hub,
            destination_hub: schedule.destination_hub,
            charge_trip_id: schedule.trip_id
          ).with_indifferent_access,
          meta: {
            pricing_rate_data: {},
            pricing_breakdown: {},
            tender_id: tender.id
          }
        }
      end

      before do
        Users::Settings.find_by(user_id: user.id).destroy
        FactoryBot.create(:charge_breakdown, shipment: shipment, tender_id: tender.id)
      end

      it "selects an offer for the shipment and assigns a reference number" do
        result = described_class.new.choose_offer(params, user)
        aggregate_failures do
          expect(result[:shipment]["trip_id"]).to eq(trip.id)
          expect(result[:shipment]["tender_id"]).to eq(tender.id)
        end
      end
    end

    context "when it is a basic lcl with documents customs" do
      let(:address) { FactoryBot.create(:address) }
      let(:schedule) { OfferCalculator::Schedule.from_trip(trip) }
      let(:lcl_shipment) do
        FactoryBot.create(:shipment,
          user: user,
          trip: trip,
          organization: organization,
          origin_hub: origin_hub,
          destination_hub: destination_hub,
          origin_nexus: origin_hub&.nexus,
          destination_nexus: destination_hub&.nexus,
          load_type: "cargo_item",
          trucking: {"pre_carriage": {"truck_type": "default", "trucking_time_in_seconds": 10_000}})
      end
      let(:params) do
        {
          shipment_id: lcl_shipment.id,
          customs_credit: {},
          schedule: schedule.as_json.merge(
            origin_hub: schedule.origin_hub,
            destination_hub: schedule.destination_hub,
            charge_trip_id: schedule.trip_id
          ).with_indifferent_access,
          meta: {
            pricing_rate_data: {},
            pricing_breakdown: {},
            tender_id: tender.id
          }
        }
      end

      before do
        FactoryBot.create(:user_addresses, user: user, address: address)
        FactoryBot.create(:customs_fee, hub: origin_hub, direction: "export", tenant_vehicle_id: trip.tenant_vehicle_id)
        FactoryBot.create(:customs_fee, hub: destination_hub, direction: "import",
                                        tenant_vehicle_id: trip.tenant_vehicle_id)
        FactoryBot.create(:legacy_file, shipment_id: lcl_shipment.id)
        stub_request(:get, "http://data.fixer.io/latest?access_key=FAKEKEY&base=EUR")
          .to_return(status: 200, body: {rates: {AED: 4.11, BIF: 1.1456, EUR: 1.34}}.to_json, headers: {})
        FactoryBot.create(:charge_breakdown, shipment: lcl_shipment, tender_id: tender.id)
      end

      it "selects an offer for the shipment and assigns a reference number" do
        result = described_class.new.choose_offer(params, user)
        expect(result[:shipment]["trip_id"]).to eq(trip.id)
      end
    end
  end

  describe ".view_more_schedules" do
    let(:trip) { FactoryBot.create(:legacy_trip, itinerary: itinerary_2, tenant_vehicle: tenant_vehicle) }

    context "with a positive delta" do
      let(:delta) { 1 }
      let!(:later_trip) do
        FactoryBot.create(:legacy_trip, itinerary: itinerary_2,
                                        tenant_vehicle: tenant_vehicle,
                                        start_date: trip.start_date + 7,
                                        end_date: trip.end_date + 14)
      end

      it "generates schedules from trips later than the specified trip" do
        result = described_class.new.view_more_schedules(trip.id, delta)
        expect(result[:schedules].first[:eta].to_date).to eq(later_trip.end_date.to_date)
      end
    end

    context "with a negative delta" do
      let(:delta) { -1 }
      let!(:earlier_trip) do
        FactoryBot.create(:legacy_trip, itinerary: itinerary_2,
                                        tenant_vehicle: tenant_vehicle,
                                        start_date: trip.start_date - 14,
                                        end_date: trip.end_date - 7)
      end

      it "generates schedules from trips earlier than the specified trip" do
        result = described_class.new.view_more_schedules(trip.id, delta)
        expect(result[:schedules].first[:eta].to_date).to eq(earlier_trip.end_date.to_date)
      end
    end
  end
end
