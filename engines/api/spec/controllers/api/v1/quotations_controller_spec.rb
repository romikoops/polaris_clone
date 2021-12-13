# frozen_string_literal: true

require "rails_helper"

module Api
  RSpec.describe V1::QuotationsController, type: :controller do
    routes { Engine.routes }

    before do
      request.headers["Authorization"] = token_header
      { USD: 1.26, SEK: 8.26 }.each do |currency, rate|
        FactoryBot.create(:treasury_exchange_rate, from: currency, to: "EUR", rate: rate)
      end
      FactoryBot.create(:companies_membership, client: client)
      FactoryBot.create(:users_membership, organization: organization, user: user)
    end

    let(:organization) { FactoryBot.create(:organizations_organization, :with_max_dimensions) }
    let(:user) { FactoryBot.create(:users_user) }
    let(:client) { FactoryBot.create(:api_client, organization_id: organization.id) }
    let(:source) { FactoryBot.create(:application, name: "bridge") }
    let(:access_token) do
      FactoryBot.create(:access_token,
        resource_owner_id: user.id,
        scopes: "public",
        application: source)
    end
    let(:token_header) { "Bearer #{access_token.token}" }

    describe "POST #create" do
      let(:origin_nexus) { origin_hub.nexus }
      let(:destination_nexus) { destination_hub.nexus }
      let(:origin_hub) { itinerary.origin_hub }
      let(:destination_hub) { itinerary.destination_hub }
      let(:carrier) { FactoryBot.create(:legacy_carrier).tap { |carrier| FactoryBot.create(:routing_carrier, name: carrier.name, code: carrier.code) } }
      let(:tenant_vehicle) { FactoryBot.create(:legacy_tenant_vehicle, name: "slowly", carrier: carrier, organization: organization) }
      let(:tenant_vehicle2) { FactoryBot.create(:legacy_tenant_vehicle, name: "quickly", carrier: carrier, organization: organization) }
      let(:itinerary) { FactoryBot.create(:gothenburg_shanghai_itinerary, organization: organization) }
      let(:pallet) { FactoryBot.create(:legacy_cargo_item_type) }
      let(:trips) do
        [tenant_vehicle, tenant_vehicle2].flat_map do |tv|
          [
            FactoryBot.create(:trip_with_layovers, itinerary: itinerary, load_type: "container", tenant_vehicle: tv),
            FactoryBot.create(:trip_with_layovers, itinerary: itinerary, load_type: "cargo_item", tenant_vehicle: tv)
          ]
        end
      end
      let(:async) { false }
      let(:cargo_items_attributes) { [] }
      let(:containers_attributes) { [] }
      let(:load_type) { "container" }
      let(:params) do
        {
          organization_id: organization.id,
          quote: {
            selected_date: 5.minutes.from_now,
            organization_id: organization.id,
            user_id: client.id,
            load_type: load_type,
            origin: { nexus_id: origin_hub.nexus_id },
            destination: { nexus_id: destination_hub.nexus_id }
          },
          shipment_info: {
            trucking_info: { pre_carriage: :pre },
            cargo_items_attributes: cargo_items_attributes,
            containers_attributes: containers_attributes
          },
          async: async
        }
      end
      let(:origin) { FactoryBot.build(:carta_result, id: "xxx1", type: "locode", address: origin_hub.nexus.locode) }
      let(:destination) { FactoryBot.build(:carta_result, id: "xxx2", type: "locode", address: destination_hub.nexus.locode) }
      let(:query) { Journey::Query.find(response_data["id"]) }
      let(:default_cargo_items_attributes) do
        [
          {
            "id" => SecureRandom.uuid,
            "payload_in_kg" => 120,
            "total_volume" => 0,
            "total_weight" => 0,
            "width" => 120,
            "length" => 80,
            "height" => 120,
            "quantity" => 1,
            "cargo_item_type_id" => pallet.id,
            "dangerous_goods" => false,
            "stackable" => true
          }
        ]
      end

      context "with available tenders" do
        before do
          [tenant_vehicle, tenant_vehicle2].each do |t_vehicle|
            FactoryBot.create(:lcl_pricing, itinerary: itinerary, tenant_vehicle: t_vehicle, organization: organization)
          end
          FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle,
                                             organization: organization, amount: 170)
          FactoryBot.create(:fcl_20_pricing, itinerary: itinerary, tenant_vehicle: tenant_vehicle2,
                                             organization: organization, amount: 190)

          OfferCalculator::Schedule.from_trips(trips)
          FactoryBot.create(:freight_margin, default_for: "ocean", organization_id: organization.id,
                                             applicable: organization, value: 0)
          allow(Carta::Client).to receive(:suggest).with(query: origin_hub.hub_code).and_return(origin)
          allow(Carta::Client).to receive(:suggest).with(query: destination_hub.hub_code).and_return(destination)
        end

        it "returns tenders ordered by amount by default", :aggregate_failures do
          post :create, params: params, as: :json

          amounts = response_data.dig("attributes", "tenders", "data").map { |i| i.dig("attributes", "total", "amount") }
          expect(query.source_id).to eq(source.id)
          expect(amounts).to eq(["170.0", "190.0"])
          expect(response_data.dig("attributes", "loadType")).to eq("container")
        end

        context "when client is provided" do
          it "returns results successfully" do
            post :create, params: params, as: :json

            expect(response).to be_successful
          end

          it "returns 2 available tenders" do
            post :create, params: params, as: :json

            expect(response_data.dig("attributes", "tenders", "data").count).to eq 2
          end
        end

        context "when no client is provided" do
          before do
            params[:quote][:user_id] = nil
            organization.scope.update(content: { default_currency: "usd" })
          end

          it "returns prices with default margins" do
            post :create, params: params, as: :json

            expect(response_data.dig("attributes", "tenders", "data").count).to eq 2
          end

          it "creates a quotation with user nil but with creator set to current user" do
            post :create, params: params, as: :json

            expect(response).to be_successful
          end
        end

        context "when cargo items are invalid" do
          let(:load_type) { "cargo_item" }
          let(:cargo_items_attributes) do
            [
              {
                "id" => SecureRandom.uuid,
                "payload_in_kg" => 120,
                "total_volume" => 0,
                "total_weight" => 0,
                "width" => 0,
                "length" => 80,
                "height" => 1200,
                "quantity" => 1,
                "cargo_item_type_id" => pallet.id,
                "dangerous_goods" => false,
                "stackable" => true
              }
            ]
          end

          it "returns validations errors" do
            post :create, params: params
            aggregate_failures do
              expect(response.code).to eq "417"
              expect(response_data.count).to eq 2
            end
          end
        end

        context "when containers are invalid" do
          let(:containers_attributes) do
            [
              {
                "id" => SecureRandom.uuid,
                "payload_in_kg" => 999_999,
                "size_class" => "fcl_20",
                "total_weight" => 0,
                "width" => 0,
                "length" => 0,
                "height" => 0,
                "quantity" => 1
              }
            ]
          end

          before do
            FactoryBot.create(:legacy_max_dimensions_bundle,
              organization: organization,
              mode_of_transport: "ocean",
              payload_in_kg: 10_000,
              cargo_class: "fcl_20")
          end

          it "returns validation errors" do
            post :create, params: params
            aggregate_failures do
              expect(response.code).to eq "417"
              expect(response_data.count).to eq 1
            end
          end
        end

        context "when cargo items are valid" do
          let(:load_type) { "cargo_item" }

          it "returns prices with default margins" do
            post :create, params: params, as: :json
            aggregate_failures do
              expect(response.code).to eq "200"
              expect(response_data.dig("attributes", "tenders", "data").count).to eq 2
            end
          end
        end

        context "when async" do
          let(:load_type) { "cargo_item" }
          let(:async) { true }
          let(:cargo_items_attributes) { default_cargo_items_attributes }
          let(:expected_keys) do
            %w[selectedDate loadType paymentTerms companyName user creator origin destination containers cargoItems tenders completed parentId]
          end

          it "returns prices with default margins" do
            post :create, params: params
            aggregate_failures do
              expect(response.code).to eq "200"
              expect(response_data["attributes"].keys).to match_array(expected_keys)
            end
          end
        end

        context "with parent_id" do
          let(:parent_query) { FactoryBot.create(:journey_query) }

          before { params[:quote][:parent_id] = parent_query.id }

          it "returns parentId with parent_query id in response" do
            post :create, params: params, as: :json
            expect(response_data["attributes"]["parentId"]).to eq parent_query.id
          end
        end
      end

      context "when no available schedules" do
        before { FactoryBot.create(:lcl_pricing, organization: organization) }

        let(:cargo_items_attributes) { default_cargo_items_attributes }

        it "returns no available schedules error" do
          post :create, params: params, as: :json

          expect(response_error).to eq "There are no departures for this timeframe."
        end
      end
    end

    describe "GET #show" do
      include_context "journey_pdf_setup"
      context "when async error has occurred " do
        before do
          result.destroy
          FactoryBot.create(:journey_error, query: query, code: 3002)
        end

        it "renders the errors" do
          get :show, params: { organization_id: organization.id, id: query.id }

          expect(response_error).to eq "OfferCalculator::Errors::LoadMeterageExceeded"
        end
      end

      context "when origin and destinations are nexuses" do
        let!(:origin_hub) do
          FactoryBot.create(:legacy_hub,
            hub_code: origin_locode,
            hub_type: freight_section.mode_of_transport,
            organization: organization)
        end
        let!(:destination_hub) do
          FactoryBot.create(:legacy_hub,
            hub_code: destination_locode,
            hub_type: freight_section.mode_of_transport,
            organization: organization)
        end
        let!(:origin_nexus) { origin_hub.nexus }
        let!(:destination_nexus) { destination_hub.nexus }
        let(:route_sections) { [freight_section] }

        it "renders origin and destination as nexus objects", :aggregate_failures do
          get :show, params: { organization_id: organization.id, id: query.id }

          expect(response_data.dig("attributes", "origin", "data", "id")).to eq origin_nexus.id.to_s
          expect(response_data.dig("attributes", "destination", "data", "id")).to eq destination_nexus.id.to_s
        end
      end

      context "when origin and destination are addresses" do
        it "renders origin and destination as address objects", :aggregate_failures do
          get :show, params: { organization_id: organization.id, id: query.id }

          expect(response_data.dig("attributes", "origin", "data", "attributes", "geocodedAddress")).to eq origin_text
          expect(response_data.dig("attributes", "destination", "data", "attributes", "geocodedAddress")).to eq destination_text
        end
      end

      context "when cargo is lcl" do
        let(:cargo_trait) { :lcl }

        it "returns the cargo items" do
          get :show, params: { organization_id: organization.id, id: query.id }
          expect(response_data.dig("attributes", "cargoItems", "data", 0, "id")).to eq(query.cargo_units.first.id)
        end
      end

      context "when no results are completed yet" do
        before { result.destroy }

        it "returns the cargo items" do
          get :show, params: { organization_id: organization.id, id: query.id }
          expect(response_data.dig("attributes", "cargoItems", "data", 0, "id")).to eq(query.cargo_units.first.id)
        end
      end
    end

    describe "GET #index" do
      before do
        Organizations.current_id = organization.id
      end

      context "when quotations exist" do
        before do
          FactoryBot.create_list(:journey_query, 3, organization: organization).tap do |queries|
            queries.each do |query|
              FactoryBot.create(:journey_result, query: query)
            end
          end
        end

        it "renders a list of quotations" do
          get :index, params: { organization_id: organization.id }

          expected_response = Journey::Query.order("created_at DESC").pluck(:id)

          expect(response_data.map { |q| q["id"] }).to match expected_response
        end

        it "paginates results" do
          get :index, params: { organization_id: organization.id, per_page: 2 }

          expected_response = Journey::Query.order("created_at DESC").pluck(:id)[0..1]

          expect(response_data.map { |q| q["id"] }).to match_array expected_response
        end
      end

      context "when quotations do not exist" do
        it "renders an empty list" do
          get :index, params: { organization_id: organization.id }

          aggregate_failures do
            expect(response_data).to eq []
          end
        end
      end

      context "with sorting params" do
        let(:older_query) do
          FactoryBot.create(:journey_query,
            organization: organization,
            cargo_ready_date: DateTime.now + 1.day,
            client: client)
        end

        let(:newer_query) do
          FactoryBot.create(:journey_query,
            organization: organization,
            cargo_ready_date: DateTime.now + 2.days,
            client: client)
        end

        before do
          FactoryBot.create(:journey_result, query: older_query)
          FactoryBot.create(:journey_result, query: newer_query)
        end

        it "sorts by selected date desc" do
          get :index, params: { organization_id: organization.id, sort_by: "selected_date", direction: "desc" }

          aggregate_failures do
            expect(response_data.first["id"]).to eq newer_query.id
            expect(response_data.last["id"]).to eq older_query.id
          end
        end

        it "filters by cargo_ready_date desc" do
          get :index, params: { organization_id: organization.id, start_date: 1.minute.ago, end_date: 36.hours.from_now }

          aggregate_failures do
            expect(response_data.pluck("id")).to eq [older_query.id]
          end
        end
      end
    end

    describe "POST #download" do
      include_context "journey_pdf_setup"

      shared_examples_for "a downloadable quotation format" do |format|
        context "without tender ids" do
          it "returns the url of the generated document for the quotation tenders" do
            post :download, params: { organization_id: organization.id, quotation_id: query.id, format: format }

            expect(response_data["id"]).not_to be_empty
          end
        end

        context "with tender ids" do
          let(:params) do
            {
              organization_id: organization.id,
              quotation_id: query.id,
              format: format,
              tenders: [result.id],
              dl: dl
            }
          end

          it "renders origin and destination as nexus objects" do
            post :download, params: params

            expect(response_data["id"]).not_to be_empty
          end
        end
      end

      context "when downloading as pdf" do
        let(:dl) { 1 }

        it_behaves_like "a downloadable quotation format", "pdf"
      end

      context "when downloading as xlsx" do
        let(:dl) { 0 }

        it_behaves_like "a downloadable quotation format", "xlsx"
      end

      context "when format is not specified" do
        it "is unsuccessful", :aggregate_failures do
          post :download, params: { organization_id: organization.id, quotation_id: query.id, tenders: [] }
          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)["error"]).to eq("Download format is missing or invalid")
        end
      end
    end
  end
end
