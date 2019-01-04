# frozen_string_literal: true

module DataValidator
  class SampleSheets < DataValidator::BaseValidator
    attr_reader :tenants, :n_sample_itineraries

    LCL_EXAMPLES = [{
      '#1-payload_in_kg' => 1000,
      '#1-dimension_x' => 120,
      '#1-dimension_y' => 80,
      '#1-dimension_z' => 160,
      '#1-stackable' => 1,
      '#1-quantity' => 6,
      '#1-dangerous_goods' => false
    }].freeze

    FCL_EXAMPLES = [{
      '#1-payload_in_kg' => 1000,
      '#1-size_class' => nil,
      '#1-quantity' => 1,
      '#1-dangerous_goods' => false
    }].freeze

    def initialize(options = {})
      @tenants = options[:tenants] || Tenant.all
      @n_sample_itineraries = options[:n_sample_itineraries]
    end

    def perform
      tempfile = Tempfile.new('excel')
      xlsx = WriteXLSX.new(tempfile, tempdir: Rails.root.join('tmp', 'write_xlsx/').to_s)

      tenants.each do |tenant|
        itineraries(tenant).each do |itinerary|
          itin_name = itinerary.name
          mot = itinerary.mode_of_transport
          start_hub = Hub.find(itinerary.origin_hub_ids.first)
          end_hub = Hub.find(itinerary.destination_hub_ids.first)
          xlsx.add_worksheet(itin_name)

          itinerary.pricings.each do |pricing|
            case pricing.cargo_class.downcase
            when 'lcl'
              LCL_EXAMPLES.each do |cargo_data|
                lcl_data = {
                  'ITINERARY' => itin_name,
                  'MOT' => mot,
                  'LOAD_TYPE' => pricing.load_type,
                  'ORIGIN_TRUCK_TYPE' => 'default',
                  'DESTINATION_TRUCK_TYPE' => 'default',
                  'UNITS' => nil,
                  **cargo_data,
                  'PICKUP_ADDRESS' => nil,
                  'DELIVERY_ADDRESS' => nil,
                  'CARRIER' => pricing.carrier,
                  'SERVICE_LEVEL' => pricing.tenant_vehicle.name,
                  'FREIGHT' => nil,
                  **freight_key_hashes(pricing.pricing_details),
                  'PRECARRIAGE' => nil,
                  'ONCARRIAGE' => nil,
                  'IMPORT' => nil,
                  **local_charges_key_hashes('import', 'lcl', mot, pricing.tenant_vehicle, end_hub, start_hub),
                  'EXPORT' => nil,
                  **local_charges_key_hashes('export', 'lcl', mot, pricing.tenant_vehicle, start_hub, end_hub),
                  'DATE' => DateTime.now + 7.days,
                  'TOTAL' => nil
                }
              end
            when /fcl.+/
              FCL_EXAMPLES.each do |cargo_data|
                fcl_data =
                  { 'ITINERARY' => itin_name,
                    'MOT' => mot,
                    'LOAD_TYPE' => pricing.load_type,
                    'ORIGIN_TRUCK_TYPE' => 'chassis',
                    'DESTINATION_TRUCK_TYPE' => 'chassis',
                    'UNITS' => nil,
                    **cargo_data.merge('#1-size_class' => pricing.cargo_class),
                    'PICKUP_ADDRESS' => nil,
                    'DELIVERY_ADDRESS' => nil,
                    'CARRIER' => pricing.carrier,
                    'SERVICE_LEVEL' => pricing.tenant_vehicle.name,
                    'FREIGHT' => nil,
                    **freight_key_hashes(pricing.pricing_details),
                    'PRECARRIAGE' => nil,
                    'ONCARRIAGE' => nil,
                    'IMPORT' => nil,
                    **local_charges_key_hashes('import', 'lcl', mot, pricing.tenant_vehicle, end_hub, start_hub),
                    'EXPORT' => nil,
                    **local_charges_key_hashes('export', 'lcl', mot, pricing.tenant_vehicle, start_hub, end_hub),
                    'DATE' => DateTime.now + 7.days,
                    'TOTAL' => nil }
              end
            end
          end
        end
      end
    rescue StandardError
      raise
    ensure
      tempfile&.unlink
    end

    private

    def itineraries(tenant)
      n_sample_itineraries ? tenant.itineraries.sample(n_sample_itineraries) : tenant.itineraries
    end

    def local_charges(direction, load_type, mot, tenant_vehicle, start_hub, end_hub)
      search_attrs = { direction: direction, load_type: load_type, mode_of_transport: mot, tenant_vehicle_id: tenant_vehicle.id }
      local_charges = start_hub.local_charges.find_by(**search_attrs, counterpart_hub_id: end_hub.id)
      local_charges ||= start_hub.local_charges.find_by(**search_attrs, counterpart_hub_id: nil)

      {} if local_charges.nil?
    end

    def local_charges_key_hashes(direction, load_type, mot, tenant_vehicle, start_hub, end_hub)
      local_charges = local_charges(direction, load_type, mot, tenant_vehicle, start_hub, end_hub)
      local_charges&.pluck(:fees)&.flat_map(&:keys)&.uniq&.map { |key| { "-#{key}" => nil } }
    end

    def freight_key_hashes(pricing_details)
      pricing_details.map { |pricing_detail| { "-#{pricing_detail.shipping_type}" => nil } }
    end
  end
end
