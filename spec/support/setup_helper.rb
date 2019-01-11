# frozen_string_literal: true

module SetupHelper
  module InstanceMethods
    def variables_setup(args = {}, is_json = false)
      args[:rate] = is_json ? JSON.parse(args[:rate].to_json) : JSON.parse(args[:rate])
      args[:extras] = (is_json ? JSON.parse(args[:extras].to_json) : JSON.parse(args[:extras])).deep_symbolize_keys
      _user = user(currency: args[:target_currency], rate: args[:rate],
                   mot: args[:mode_of_transport], load_type: args[:load_type],
                   customs_export_paper: args[:extras][:customs_export_paper],
                   consolidate_cargo: args[:extras][:consolidate_cargo])

      _currency = currency(today_value: { USD: 1, SEK: 8.88957, CNY: 6.596105, EUR: 0.8575 }, base: args[:target_currency], tenant_id: _user.tenant.id)
      _transport_category = transport_category(cargo_class: args[:cargo_class],
                                               load_type: args[:load_type], mot: args[:mode_of_transport])
      _vehicle = vehicle(categories: [_transport_category], name: args[:vehicle_name])
      _tenant_vehicle = tenant_vehicle(name: args[:tenant_vehicle_name], vehicle: _vehicle, tenant: _user.tenant)
      _itinerary = itinerary(mot: args[:mode_of_transport], tenant: _user.tenant)
      _trip = trip(tenant_vehicle: _tenant_vehicle, itinerary: _itinerary)
      _pricing = pricing(user: _user, transport_category: _transport_category, trip: _trip)

      _pricing_detail = pricing_detail(tenant: _user.tenant, pricing: _pricing,
                                       currency: args[:target_currency], rate: args[:rate]['BAS'] ? args[:rate]['BAS']['rate'] : nil,
                                       min: args[:rate]['BAS'] ? args[:rate]['BAS']['min'] : nil, pricing: _pricing)
      _cargo_item = cargo_item(quantity: args[:quantity], dimension_x: args[:dimension_x],
                               dimension_y: args[:dimension_y], dimension_z: args[:dimension_z],
                               payload_in_kg: args[:payload_in_kg], cargo_class: args[:cargo_class])

      destination_country = create(:country)
      origin_country = create(:country)
      pre_carriage_trucking_address = { country: origin_country }.merge(JSON.parse(is_json ? args[:pre_carriage_address].to_json : args[:pre_carriage_address]).deep_symbolize_keys)
      origin_address = JSON.parse(is_json ? args[:origin_address].to_json : args[:origin_address])
      origin_address[:country] = origin_country
      origin = address(origin_address.deep_symbolize_keys)
      destination = address(country: destination_country)
      trucking_address = JSON.parse(is_json ? args[:trucking_address].to_json : args[:trucking_address]).deep_symbolize_keys
      trucking_address[:country] = destination_country
      final_destination = address(trucking_address)

      # findout how to implement origin trucking for pre_carriage
      origin_trucking = address(pre_carriage_trucking_address)

      _mandatory_charge_type = mandatory_charge(origin_charges: charge_type(args), import_charges: charge_type(args))
      _origin_nexus = origin_nexus(name: args[:origin_nexus_name], latitude: args[:origin_latitude], longitude: args[:origin_longitude])
      _origin_hub = origin_hub(port: args[:origin_port], origin_nexus: _origin_nexus, tenant: _user.tenant,
                               atitude: args[:origin_latitude], longitude: args[:origin_longitude], mandatory_charge: _mandatory_charge_type, address: origin)

      _destination_nexus = destination_nexus(name: args[:destination_nexus_name], latitude: args[:destination_latitude],
                                             longitude: args[:destination_longitude])

      _destination_hub = destination_hub(port: args[:destination_port], destination_nexus: _destination_nexus,
                                         latitude: args[:destination_latitude], longitude: args[:destination_longitude],
                                         mandatory_charge: _mandatory_charge_type, address: destination, tenant: _user.tenant)

      _shipment = shipment(cargo_items: [_cargo_item], user: _user, shipment_status: args[:shipment_status],
                           trip: _trip, load_type: args[:load_type], direction: args[:direction], origin_hub: _origin_hub,
                           origin_nexus: _origin_nexus, destination_hub: _destination_hub, destination_nexus:  _destination_nexus,
                           trucking: args[:trucking], eta: args[:eta], etd: args[:etd], closing_date: args[:closing_date])

      _container = container(quantity: args[:quantity], payload_in_kg: args[:payload_in_kg],
                             cargo_class: args[:cargo_class], size_class: args[:size_class], shipment: _shipment)

      _origin_charge = local_charge(mot: args[:mode_of_transport], size_class: args[:size_class], hub: _origin_hub,
                                    tenant: _user.tenant, tenant_vehicle: _tenant_vehicle, direction: args[:direction], fees: JSON.parse(is_json ? args[:fees].to_json : args[:fees]))

      _destination_charge = local_charge(mot: args[:mode_of_transport], size_class: args[:size_class], hub: _destination_hub,
                                         tenant: _user.tenant, tenant_vehicle: _tenant_vehicle, direction: args[:direction], fees: JSON.parse(is_json ? args[:fees].to_json : args[:fees]))
      _trucking_pricing_scope = trucking_pricing_scope(load_type: args[:load_type],
                                                       cargo_class: args[:cargo_class], carriage: args[:extras][:carriage], truck_type: args[:trucking][:on_carriage][:truck_type])

      _trucking_pricing = trucking_pricing(tenant: _user.tenant, trucking_pricing_scope: _trucking_pricing_scope, modifier: args[:extras][:modifier],
                                           truck_type: args[:trucking][:on_carriage][:truck_type], carriage: args[:extras][:carriage], load_type: args[:load_type], address: final_destination)
      _trucking_destination = trucking_destination(zipcode: trucking_address[:zip_code])
      _hub_trucking = hub_trucking(trucking_pricing: _trucking_pricing, hub: _destination_hub, trucking_destination: _trucking_destination)

      _schedule = schedule(_shipment)

      {
        _user: _user,
        _transport_category: _transport_category,
        _vehicle: _vehicle,
        _tenant_vehicle: _tenant_vehicle,
        _trip: _trip,
        _pricing: _pricing,
        _cargo_item: _cargo_item,
        _container: _container,
        _origin_nexus: _origin_nexus,
        _origin_hub: _origin_hub,
        _destination_nexus: _destination_nexus,
        _destination_hub: _destination_hub,
        _itinerary: _itinerary,
        _shipment: _shipment,
        _schedule: _schedule,
        _pricing_detail: _pricing_detail,
        _hub_trucking: _hub_trucking,
        _trucking_pricing: _trucking_pricing,
        _final_destination: final_destination,
        _origin_charge: _origin_charge,
        _destination_charge: _destination_charge,
        _carriage: args[:extras][:carriage],
        _origin_trucking: origin_trucking
      }
    end

    def trucking_destination(arg = {})
      create(:trucking_destination, zipcode: arg[:zipcode] || '54016')
    end

    def currency(arg)
      create(:currency, today: arg[:today_value], yesterday: arg[:yesterday_value], base: arg[:base], tenant_id: arg[:tenant_id])
    end

    def hub_trucking(arg)
      create(:hub_trucking, trucking_pricing: arg[:trucking_pricing], hub: arg[:hub], trucking_destination: arg[:trucking_destination])
    end

    def trucking_pricing(arg = {})
      create(:trucking_pricing, rates: container_rates, fees: container_fees,
                                tenant: arg[:tenant], trucking_pricing_scope: arg[:trucking_pricing_scope], modifier: arg[:modifier])
    end

    def trucking_pricing_scope(arg)
      create(:trucking_pricing_scope, load_type: arg[:load_type],
                                      cargo_class: arg[:cargo_class], carriage: arg[:carriage], truck_type: arg[:truck_type])
    end

    def local_charge(arg)
      create(:local_charge, mode_of_transport: arg[:mot], load_type: arg[:size_class], hub: arg[:hub], tenant: arg[:tenant],
                            tenant_vehicle_id: arg[:tenant_vehicle].id, direction: arg[:direction], fees: arg[:fees])
    end

    def address(arg = {})
      create(:address, name: arg[:name] || 'Gothenburg', latitude: arg[:latitude] || '57.694253',
                       longitude: arg[:longitude] || '11.854048', zip_code: arg[:zip_code] || '43813',
                       geocoded_address: arg[:geocoded_address] || '438 80 Landvetter, Sweden',
                       city: arg[:city] || 'Gothenburg', country: arg[:country])
    end

    def charge_type(arg)
      if arg[:direction] == 'export'
        true
      else
        arg[:direction] == 'import'
      end
    end

    def pricing_exception(arg)
      create(:pricing_exception, tenant: arg[:tenant], pricing: arg[:pricing])
    end

    def pricing_detail(arg)
      create(:pricing_detail, rate: arg[:rate], currency_name: arg[:currency],
                              tenant: arg[:tenant], priceable: arg[:pricing], min: arg[:min])
    end

    def user(arg)
      tenant = create(:tenant, currency: arg[:currency], scope: tenant_scope(arg))
      create(:user, tenant: tenant)
    end

    def transport_category(arg = {})
      create(:transport_category, cargo_class: arg[:cargo_class].blank? ? 'lcl' : arg[:cargo_class], load_type: arg[:load_type] || 'cargo_item', mode_of_transport: arg[:mot])
    end

    def vehicle(arg)
      create(:vehicle, name: arg[:name] || 'express', transport_categories: arg[:categories])
    end

    def tenant_vehicle(arg)
      create(:tenant_vehicle, name: arg[:name] || 'express', vehicle: arg[:vehicle],
                              tenant: arg[:tenant])
    end

    def itinerary(arg = {})
      create(:itinerary, mode_of_transport: arg[:mot] || 'ocean', tenant: arg[:tenant])
    end

    def trip(arg)
      create(:trip,
             layovers: [create(:layover), create(:layover)],
             tenant_vehicle: arg[:tenant_vehicle], itinerary: arg[:itinerary])
    end

    def pricing(arg)
      create(:pricing, tenant: arg[:user].tenant, wm_rate: arg[:wm_rate],
                       transport_category: arg[:transport_category], itinerary: arg[:trip].itinerary)
    end

    def cargo_item(arg = {})
      create(:cargo_item, quantity: arg[:quantity] || 1, dimension_x: arg[:dimension_x] || 20,
                          dimension_y: arg[:dimension_y] || 20, dimension_z: arg[:dimension_z] || 20,
                          payload_in_kg: arg[:payload_in_kg] || 200, cargo_class: arg[:cargo_class] || 'lcl')
    end

    def container(arg = {})
      create(:container, quantity: arg[:quantity] || 1, payload_in_kg: arg[:payload_in_kg] || 10_000,
                         cargo_class: arg[:cargo_class] || 'fcl_20', size_class: arg[:size_class].blank? ? 'fcl_20' : arg[:size_class],
                         shipment: arg[:shipment])
    end

    def origin_nexus(arg)
      create(:nexus, name: arg[:name] || 'Shanghai', latitude: arg[:latitude], longitude: arg[:longitude])
    end

    def origin_hub(arg)
      create(:hub, name: arg[:port] || 'Shanghai Port', nexus: arg[:origin_nexus], latitude: arg[:latitude],
                   longitude: arg[:longitude], mandatory_charge: arg[:mandatory_charge], tenant: arg[:tenant], address: arg[:address])
    end

    def destination_nexus(arg)
      create(:nexus, name: arg[:name] || 'Gothenburg', latitude: arg[:latitude], longitude: arg[:longitude])
    end

    def destination_hub(arg)
      create(:hub, name: arg[:port] || 'Gothenburg port', nexus: arg[:destination_nexus],
                   latitude: arg[:latitude], longitude: arg[:longitude], mandatory_charge: arg[:mandatory_charge], tenant: arg[:tenant],
                   address: arg[:address])
    end

    def mandatory_charge(arg)
      create(:mandatory_charge, import_charges: arg[:import_charges], export_charges: arg[:export_charges])
    end

    def shipment(arg)
      create(:shipment,
             user: arg[:user], status: arg[:shipment_status] || 'requested', trip: arg[:trip],
             load_type: arg[:load_type] || 'cargo_item', direction: arg[:direction] || 'export',
             total_goods_value: 1500, booking_placed_at: Time.now, origin_hub: arg[:origin_hub],
             origin_nexus: arg[:origin_nexus], destination_hub: arg[:destination_hub],
             destination_nexus: arg[:destination_nexus], cargo_items: arg[:cargo_items],
             trucking: arg[:trucking], planned_eta: arg[:eta], planned_etd: arg[:etd],
             closing_date: arg[:closing_date])
    end

    def schedule(shipment)
      Schedule.new(
        origin_hub_id:        shipment.origin_hub.id,
        destination_hub_id:   shipment.destination_hub.id,
        origin_hub_name:      shipment.origin_hub.name,
        destination_hub_name: shipment.destination_hub.name,
        mode_of_transport:    shipment.mode_of_transport,
        eta:                  shipment.planned_eta,
        etd:                  shipment.planned_etd,
        closing_date:         shipment.closing_date,
        trip_id:              shipment.trip_id
      )
    end

    def container_rates
      {
        'km' => [
          {
            'rate' => {
              'base' => 1.0,
              'value' => 19.4,
              'currency' => 'SEK',
              'rate_basis' => 'PER_CONTAINER_KM'
            },
            'min_value' => 0
          }
        ],
        'unit' => [
          {
            'rate' => {
              'base' => 1.0,
              'value' => 350.0,
              'currency' => 'SEK',
              'rate_basis' => 'PER_CONTAINER_KM'
            },
            'max_unit' => '1.0',
            'min_unit' => '1.0',
            'min_value' => 2552.0
          }
        ]
      }
    end

    def container_fees
      {
        'FSC' => {
          'key' => 'FSC',
          'name' => 'Fuel Surcharge',
          'value' => 0.19,
          'currency' => 'SEK',
          'rate_basis' => 'PERCENTAGE'
        },
        'FWC' => {
          'key' => 'FWC',
          'name' => 'Freeways Charge',
          'value' => 40.0,
          'currency' => 'SEK',
          'rate_basis' => 'PER_SHIPMENT'
        }
      }
    end

    def container_load_meterage
      { 'ratio' => 1850.0, 'height_limit' => 130 }
    end

    def is_valid_combination?(arg, mot, load_type)
      arg[:mot] == mot && arg[:load_type] == load_type ? true : false
    end

    def tenant_scope(arg = {})
      {
        modes_of_transport: {
          truck: {
            container: is_valid_combination?(arg, 'truck', 'container'),
            cargo_item: is_valid_combination?(arg, 'truck', 'cargo_item')
          },
          ocean: {
            container: is_valid_combination?(arg, 'ocean', 'container'),
            cargo_item: is_valid_combination?(arg, 'ocean', 'cargo_item')
          },
          rail: {
            container: is_valid_combination?(arg, 'rail', 'container'),
            cargo_item: is_valid_combination?(arg, 'rail', 'cargo_item')
          },
          air: {
            container: is_valid_combination?(arg, 'air', 'container'),
            cargo_item: is_valid_combination?(arg, 'air', 'cargo_item')
          }
        },
        links: {
          about: 'https://freightservices.greencarrier.com/about-us/',
          legal: 'https://freightservices.greencarrier.com/contact/'
        },
        customs_export_paper: arg[:customs_export_paper],
        consolidate_cargo: arg[:consolidate_cargo],
        fixed_currency: true,
        dangerous_goods: false,
        detailed_billing: false,
        incoterm_info_level: 'text',
        cargo_info_level: 'text',
        has_insurance: true,
        has_customs: true,
        terms: [
          'You verify that all the information provided above is true',
          'You agree to the presented terms and conditions.',
          'Our rate and service proposals are made based on capacity conditions at the time of the inquiry. Market conditions are subject to change quickly. All offers must be re-confirmed with Greencarrier at the time of booking to be valid.'
        ],
        carriage_options: {
          on_carriage: {
            import: 'mandatory',
            export: 'optional'
          },
          pre_carriage: {
            import: 'optional',
            export: 'mandatory'
          }
        }
      }.deep_symbolize_keys
    end

    def request_stubber(access_key, currency)
      Net::HTTP.get_response(URI("http://data.fixer.io/latest?access_key=#{access_key}&base=#{currency}"))
    end
  end

  module ClassMethods
    def open_file(file)
      Roo::Spreadsheet.open(file)
    end

    def test_cases_from_json(file)
      test_json = JSON.parse(File.read(file))
      test_json.each do |sheet|
        sheet = sheet.deep_symbolize_keys
        sheet[:eta] = DateTime.parse(sheet[:eta])
        sheet[:etd] = DateTime.parse(sheet[:etd])
        sheet[:closing_date] = DateTime.parse(sheet[:closing_date])
      end
    end

    def test_cases_from_excel(file, sheet_name)
      test_workbook = open_file(file)
      test_sheet = test_workbook.sheet(sheet_name)
      test_sheet = test_sheet.parse(
        origin_nexus_name: 'origin_nexus_name',
        origin_port: 'origin_port',
        destination_nexus_name: 'destination_nexus_name',
        destination_port: 'destination_port',
        trucking: 'trucking',
        load_type: 'load_type',
        mode_of_transport: 'mode_of_transport',
        quantity: 'quantity',
        dimension_x: 'dimension_x',
        dimension_y: 'dimension_y',
        dimension_z: 'dimension_z',
        payload_in_kg: 'payload_in_kg',
        eta: 'eta',
        etd: 'etd',
        closing_date: 'closing_date',
        direction: 'direction',
        origin_latitude: 'origin_latitude',
        origin_longitude: 'origin_longitude',
        destination_latitude: 'destination_latitude',
        destination_longitude: 'destination_longitude',
        target_price: 'target_price',
        target_currency: 'target_currency',
        size_class: 'size_class',
        cargo_class: 'cargo_class',
        rate: 'rate',
        fees: 'fees',
        trucking_address: 'trucking_address',
        origin_address: 'origin_address',
        extras: 'extras',
        pre_carriage_address: 'pre_carriage_address'
      )

      test_sheet.each do |sheet|
        sheet[:eta] = sheet[:eta] ? DateTime.parse(sheet[:eta]) : DateTime.now + 10
        sheet[:etd] = sheet[:etd] ? DateTime.parse(sheet[:etd]) : DateTime.now + 7
        sheet[:closing_date] = sheet[:closing_date] ? DateTime.parse(sheet[:closing_date]) : DateTime.now + 5
        sheet[:trucking] = JSON.parse(sheet[:trucking])
      end
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
