# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Helmsman::Validator do
  context 'validating routes for the target tenant' do
    describe 'perform' do
      let(:legacy_tenant) { FactoryBot.create(:legacy_tenant) }
      let(:tenant) { Tenants::Tenant.find_by(legacy_id: legacy_tenant.id) }
      let(:legacy_user) { FactoryBot.create(:legacy_user, tenant: legacy_tenant) }
      let(:user) { Tenants::User.find_by(legacy_id: legacy_user.id) }
      let!(:hub_locations) do
        %w(Gothenburg Shanghai Ningbo Hamburg Rotterdam Veracruz).map do |name|
          FactoryBot.create("#{name.downcase}_location".to_sym, all_mots: true)
        end
      end

      let!(:hub_terminals) do
        hub_locations.flat_map(&:terminals)
      end
      before(:each) do
        expect_any_instance_of(Federation::Members).to receive(:list).and_return(Tenants::Tenant.all)
      end

      let!(:de_trucking_locations) do
        [{ name: '22609', lat: 53.564015171950075, lng: 9.872106058684425, country_code: 'de' },
         { name: '20354', lat: 53.55876505682707, lng: 9.994116443570666, country_code: 'de' },
         { name: '29392', lat: 52.587166917989336, lng: 10.5362392833, country_code: 'de' },
         { name: '24799', lat: 54.27770621894213, lng: 9.418024874726212, country_code: 'de' },
         { name: '29693', lat: 52.76299308689905, lng: 9.548738622280371, country_code: 'de' },
         { name: '26180', lat: 53.260788198708354, lng: 8.211054863901857, country_code: 'de' },
         { name: '26757', lat: 53.59257241089075, lng: 6.722486576697578, country_code: 'de' },
         { name: '26123', lat: 53.15231230302764, lng: 8.232479907179881, country_code: 'de' },
         { name: '25980', lat: 54.87764815741687, lng: 8.358202458253, country_code: 'de' },
         { name: '26571', lat: 53.639804540389896, lng: 6.885068313527313, country_code: 'de' },
         { name: '25850', lat: 54.56043110310471, lng: 9.248611356660888, country_code: 'de' },
         { name: '26723', lat: 53.358874177553275, lng: 7.11649147197238, country_code: 'de' },
         { name: '26736', lat: 53.447141932531096, lng: 7.094639735576665, country_code: 'de' },
         { name: '26506', lat: 53.58119754743243, lng: 7.1795138105824226, country_code: 'de' },
         { name: '26571', lat: 53.67649969856594, lng: 6.975060633542749, country_code: 'de' },
         { name: '25379', lat: 53.77512689184231, lng: 9.505686131879242, country_code: 'de' },
         { name: '26759', lat: 53.419886636800996, lng: 7.209978549681542, country_code: 'de' },
         { name: '26907', lat: 52.928929964263475, lng: 7.231610762157991, country_code: 'de' },
         { name: '26548', lat: 53.713886924630415, lng: 7.241199099662412, country_code: 'de' },
         { name: '21438', lat: 53.30172452175038, lng: 10.057272175380726, country_code: 'de' }].map do |loc|
          FactoryBot.create(:dynamic_location,
                            lat: loc[:lat],
                            lng: loc[:lng],
                            name: loc[:name],
                            country_code: loc[:country_code])
        end
      end

      let!(:cn_trucking_locations) do
        [{ country_code: 'cn', name: '盐都区 (Yandu)', lat: 33.26487585686893, lng: 119.96039089452331 },
         { country_code: 'cn', name: '盐都区 (Yandu)', lat: 33.26487585686893, lng: 119.96039089452331 },
         { country_code: 'cn', name: '钟秀街道', lat: 32.03488320903518, lng: 120.88762158150192 },
         { country_code: 'cn', name: '盐都区 (Yandu)', lat: 33.26487585686893, lng: 119.96039089452331 },
         { country_code: 'cn', name: '盐都区 (Yandu)', lat: 33.26487585686893, lng: 119.96039089452331 },
         { country_code: 'cn', name: '铜山区 (Tongshan)', lat: 34.28809716938748, lng: 117.2785218907651 },
         { country_code: 'cn', name: '青浦区 (Qingpu)', lat: 31.12691102747813, lng: 121.08103175560093 },
         { country_code: 'cn', name: '赣榆区 (Ganyu)', lat: 34.88913456953606, lng: 119.02809423241273 },
         { country_code: 'cn', name: '盐都区 (Yandu)', lat: 33.26487585686893, lng: 119.96039089452331 },
         { country_code: 'cn', name: '盐都区 (Yandu)', lat: 33.26487585686893, lng: 119.96039089452331 }].map do |loc|
          FactoryBot.create(:dynamic_location,
                            lat: loc[:lat],
                            lng: loc[:lng],
                            name: loc[:name],
                            country_code: loc[:country_code])
        end
      end

      let!(:routes) do
        hub_locations.permutation(2).flat_map do |loc_array|
          %w(air truck rail ocean).flat_map do |mot|
            FactoryBot.create(:routing_route,
                              origin: loc_array.first,
                              destination: loc_array.last,
                              origin_terminal: hub_terminals.find { |ter| ter.location_id == loc_array.first.id && ter.mode_of_transport == mot },
                              destination_terminal: hub_terminals.find { |ter| ter.location_id == loc_array.last.id && ter.mode_of_transport == mot },
                              mode_of_transport: mot)
          end
        end
      end

      let!(:de_trucking_routes) do
        hamburg = hub_locations.find { |loc| loc.locode == 'DEHAM' }
        de_trucking_locations.flat_map do |tl|
          [
            FactoryBot.create(:routing_route, origin: hamburg, destination: tl, mode_of_transport: :carriage),
            FactoryBot.create(:routing_route, origin: tl, destination: hamburg, mode_of_transport: :carriage)
          ]
        end
      end

      let!(:cn_trucking_routes) do
        shanghai = hub_locations.find { |loc| loc.locode == 'CNSHA' }
        cn_trucking_locations.flat_map do |tl|
          [
            FactoryBot.create(:routing_route, origin: shanghai, destination: tl, mode_of_transport: :carriage),
            FactoryBot.create(:routing_route, origin: tl, destination: shanghai, mode_of_transport: :carriage)
          ]
        end
      end
      let(:ocean_carrier) { FactoryBot.create(:routing_carrier, name: 'TEST1') }
      let(:air_carrier) { FactoryBot.create(:routing_carrier, name: 'TEST2') }
      let(:carriage_carrier) { FactoryBot.create(:routing_carrier, name: 'TEST3') }
      let!(:ocean_line_service) { FactoryBot.create(:routing_line_service, name: 'OCEAN - line 1', carrier: ocean_carrier) }
      let!(:ocean_line_service_2) { FactoryBot.create(:routing_line_service, name: 'OCEAN - line 2', carrier: ocean_carrier) }
      let!(:air_line_service) { FactoryBot.create(:routing_line_service, name: 'AIR - line 1', carrier: air_carrier) }
      let!(:carriage_line_service) { FactoryBot.create(:routing_line_service, name: 'CARRIAGE - line 1', carrier: carriage_carrier) }

      let!(:hamburg) { hub_locations.find { |loc| loc.locode == 'DEHAM' } }
      let!(:shanghai) { hub_locations.find { |loc| loc.locode == 'CNSHA' } }
      let!(:de_trucking_location) { Routing::Location.find_by(name: '26759') }
      let!(:cn_trucking_location) { Routing::Location.find_by(name: '盐都区 (Yandu)') }
      let!(:de_trucking_route) { Routing::Route.find_by(origin: de_trucking_location, destination: hamburg) }
      let!(:cn_trucking_route) { Routing::Route.find_by(origin: cn_trucking_location, destination: shanghai) }
      let!(:ocean_route) { Routing::Route.find_by(origin: hamburg, destination: shanghai, mode_of_transport: 'ocean') }
      let!(:air_route) { Routing::Route.find_by(origin: hamburg, destination: shanghai, mode_of_transport: 'air') }
      let!(:ocean_route_line_service) { FactoryBot.create(:routing_route_line_service, route: ocean_route, line_service: ocean_line_service) }
      let!(:air_route_line_service) { FactoryBot.create(:routing_route_line_service, route: air_route, line_service: air_line_service) }
      let!(:de_carriage_route_line_service) { FactoryBot.create(:routing_route_line_service, route: de_trucking_route, line_service: carriage_line_service)  }
      let!(:cn_carriage_route_line_service) { FactoryBot.create(:routing_route_line_service, route: cn_trucking_route, line_service: carriage_line_service)  }
      let!(:truck_route) { Routing::Route.find_by(origin: hamburg, destination: shanghai, mode_of_transport: 'truck') }
      let!(:rail_route) { Routing::Route.find_by(origin: hamburg, destination: shanghai, mode_of_transport: 'rail') }
      let!(:ocean_connections) do
        [nil, ocean_route_line_service, ocean_route_line_service, nil].each_cons(2).map do |route_arr|
          FactoryBot.create(:tenant_routing_connection,
                            inbound: route_arr.first,
                            outbound: route_arr.last,
                            tenant: tenant)
        end
      end
      let(:valid_freight_ids) { [ocean_route.id, air_route] }
      let!(:air_connections) do
        [nil, air_route_line_service, air_route_line_service, nil].each_cons(2).map do |route_arr|
          FactoryBot.create(:tenant_routing_connection,
                            inbound: route_arr.first,
                            outbound: route_arr.last,
                            tenant: tenant)
        end
      end

      let!(:rates) do
        [
          ocean_route_line_service,
          air_route_line_service,
          de_carriage_route_line_service,
          cn_carriage_route_line_service
        ].map do |rls|
          FactoryBot.create(:lcl_rate, target: rls, tenant: tenant)
        end
      end

      let!(:valid_target_ids) do
        [
          [de_trucking_route.id, ocean_route.id, cn_trucking_route.id],
          [de_trucking_route.id, air_route.id, cn_trucking_route.id]
        ]
      end
      let!(:vis_valid_target_ids) do
        [
          [de_trucking_route.id, ocean_route.id, cn_trucking_route.id]
        ]
      end
      let!(:valid_results) do
        [
          [de_carriage_route_line_service.id, ocean_route_line_service.id, cn_carriage_route_line_service.id],
          [de_carriage_route_line_service.id, air_route_line_service.id, cn_carriage_route_line_service.id]
        ]
      end

      let!(:vis_valid_results) do
        [
          [de_carriage_route_line_service.id, ocean_route_line_service.id, cn_carriage_route_line_service.id]
        ]
      end
      let!(:compass_results) do
        [
          [
            de_trucking_routes.reject { |tr| tr == de_trucking_route }.sample(1).first&.id,
            rail_route.id,
            cn_trucking_routes.reject { |tr| tr == cn_trucking_route }.sample(1).first&.id
          ],
          [
            de_trucking_routes.reject { |tr| tr == de_trucking_route }.sample(1).first&.id,
            truck_route.id,
            cn_trucking_routes.reject { |tr| tr == cn_trucking_route }.sample(1).first&.id
          ]
        ] | valid_target_ids
      end
      it 'finds two valid routes' do
        results = described_class.new(tenant_id: tenant.id, paths: compass_results, user: user).filter
        expect(results).to eq(valid_results)
      end

      it 'finds four valid routes' do
        ocean_route_line_service_2 = FactoryBot.create(:routing_route_line_service, route: ocean_route, line_service: ocean_line_service_2)
        multi_rls_valid_results =
          [
            [de_carriage_route_line_service, ocean_route_line_service, cn_carriage_route_line_service],
            [de_carriage_route_line_service, ocean_route_line_service_2, cn_carriage_route_line_service]
          ]

        results = described_class.new(tenant_id: tenant.id, paths: compass_results, user: user).filter

        expect(results).to eq(valid_results)
      end

      it 'finds one valid route with user visibility' do
        ocean_connections.each do |conn|
          FactoryBot.create(:tenant_routing_visibility, target: user, connection: conn)
        end

        results = described_class.new(tenant_id: tenant.id, paths: compass_results, user: user).filter

        expect(results).to eq(vis_valid_results)
      end

      it 'finds one valid route with group visibility' do
        group = FactoryBot.create(:tenants_group, tenant: tenant)
        FactoryBot.create(:tenants_membership, group: group, member: user)
        ocean_connections.each do |conn|
          FactoryBot.create(:tenant_routing_visibility, target: group, connection: conn)
        end
        results = described_class.new(tenant_id: tenant.id, paths: compass_results, user: user).filter

        expect(results).to eq(vis_valid_results)
      end

      it 'finds one valid route with company visibility' do
        company = FactoryBot.create(:tenants_company, tenant: tenant)
        user.update(company: company)
        ocean_connections.each do |conn|
          FactoryBot.create(:tenant_routing_visibility, target: company, connection: conn)
        end
        results = described_class.new(tenant_id: tenant.id, paths: compass_results, user: user).filter

        expect(results).to eq(vis_valid_results)
      end

      it 'finds one valid route with company group visibility' do
        company = FactoryBot.create(:tenants_company, tenant: tenant)
        user.update(company: company)
        group = FactoryBot.create(:tenants_group, tenant: tenant)
        FactoryBot.create(:tenants_membership, group: group, member: company)
        ocean_connections.each do |conn|
          FactoryBot.create(:tenant_routing_visibility, target: group, connection: conn)
        end
        results = described_class.new(tenant_id: tenant.id, paths: compass_results, user: user).filter

        expect(results).to eq(vis_valid_results)
      end
    end
  end
end
