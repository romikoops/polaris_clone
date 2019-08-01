# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Helmsman::Validator do
  context 'validating routes for the target tenant' do
    describe 'perform' do
      let(:tenant) { FactoryBot.create(:tenants_tenant) }
      let!(:hub_locations) do
        %w(Gothenburg Shanghai Ningbo Hamburg Rotterdam Veracruz).map do |name|
          FactoryBot.create("#{name.downcase}_location".to_sym)
        end
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
        hub_locations.permutation(2).each do |loc_array|
          FactoryBot.create(:routing_route, origin: loc_array.first, destination: loc_array.last)
        end
      end

      let!(:de_trucking_routes) do
        hamburg = hub_locations.find { |loc| loc.locode == 'DEHAM' }
        de_trucking_locations.map do |tl|
          FactoryBot.create(:routing_route, origin: hamburg, destination: tl)
          FactoryBot.create(:routing_route, origin: tl, destination: hamburg)
        end
      end

      let!(:cn_trucking_routes) do
        shanghai = hub_locations.find { |loc| loc.locode == 'CNSHA' }
        cn_trucking_locations.map do |tl|
          FactoryBot.create(:routing_route, origin: shanghai, destination: tl)
          FactoryBot.create(:routing_route, origin: tl, destination: shanghai)
        end
      end

      it 'finds one valid route' do
        hamburg = hub_locations.find { |loc| loc.locode == 'DEHAM' }
        shanghai = hub_locations.find { |loc| loc.locode == 'CNSHA' }
        de_trucking_location = Routing::Location.find_by(name: '26759')
        cn_trucking_location = Routing::Location.find_by(name: '盐都区 (Yandu)')
        de_trucking_route = Routing::Route.find_by(origin: de_trucking_location, destination: hamburg)
        cn_trucking_route = Routing::Route.find_by(origin: cn_trucking_location, destination: shanghai)
        ocean_route = Routing::Route.find_by(origin: hamburg, destination: shanghai)
        target_ids = [de_trucking_route, ocean_route, cn_trucking_route].map do |route|
          FactoryBot.create(:tenant_routing_route, route_id: route.id, tenant: tenant)&.id
        end
        compass_results = [
          [de_trucking_route.id, ocean_route.id, cn_trucking_route.id]
        ]
        3.times do
          compass_results << [
            de_trucking_routes.reject { |tr| tr == de_trucking_route }.sample(1).first&.id,
            routes.reject { |tr| tr == ocean_route }.sample(1).first&.id,
            cn_trucking_routes.reject { |tr| tr == cn_trucking_route }.sample(1).first&.id
          ]
        end

        results = described_class.new(tenant_id: tenant.id, routes: compass_results).perform

        expect(results[:valid]).to eq([target_ids])
      end

      it 'finds one valid route and two partials' do
        hamburg = hub_locations.find { |loc| loc.locode == 'DEHAM' }
        shanghai = hub_locations.find { |loc| loc.locode == 'CNSHA' }
        de_trucking_location = Routing::Location.find_by(name: '26759')
        cn_trucking_location = Routing::Location.find_by(name: '盐都区 (Yandu)')
        de_trucking_route = Routing::Route.find_by(origin: de_trucking_location, destination: hamburg)
        cn_trucking_route = Routing::Route.find_by(origin: cn_trucking_location, destination: shanghai)
        ocean_route = Routing::Route.find_by(origin: hamburg, destination: shanghai)
        partial_result_1 = [
          de_trucking_route&.id,
          routes.reject { |tr| tr == ocean_route }.sample(1).first&.id,
          cn_trucking_routes.reject { |tr| tr == cn_trucking_route }.sample(1).first&.id
        ]
        partial_result_2 = [
          de_trucking_routes.reject { |tr| tr == de_trucking_route }.sample(1).first&.id,
          routes.reject { |tr| tr == ocean_route }.sample(1).first&.id,
          cn_trucking_route&.id
        ]
        valid_target_ids = [de_trucking_route, ocean_route, cn_trucking_route].map do |route|
          FactoryBot.create(:tenant_routing_route, route_id: route.id, tenant: tenant)&.id
        end
        partial_target_ids_1 = [valid_target_ids.first]
        partial_target_ids_2 = [valid_target_ids.last]
        compass_results = [
          [de_trucking_route.id, ocean_route.id, cn_trucking_route.id],
          partial_result_1,
          partial_result_2
        ]
        3.times do
          compass_results << [
            de_trucking_routes.reject { |tr| tr == de_trucking_route }.sample(1).first&.id,
            routes.reject { |tr| tr == ocean_route }.sample(1).first&.id,
            cn_trucking_routes.reject { |tr| tr == cn_trucking_route }.sample(1).first&.id
          ]
        end

        results = described_class.new(tenant_id: tenant.id, routes: compass_results).perform

        expect(results[:valid]).to eq([valid_target_ids])
        expect(results[:partial].include?(partial_target_ids_1)).to eq(true)
        expect(results[:partial].include?(partial_target_ids_2)).to eq(true)
      end
    end
  end
end
