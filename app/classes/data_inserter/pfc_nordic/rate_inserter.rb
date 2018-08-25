# frozen_string_literal: true

include Translator

module DataInserter
  module PfcNordic
    class RateInserter < DataInserter::BaseInserter
      attr_reader :path, :user, :hub_data, :counterpart_hub, :rates, :tenant,
        :direction, :cargo_class, :tenant_vehicle, :transport_category

      def post_initialize(args)
        @rates = args[:rates]
        @counterpart_hub = args[:counterpart_hub]
        @counterpart_nexus = args[:counterpart_hub].split(" Port").first
        @tenant = args[:tenant]
        @direction = args[:direction]
        @cargo_class = args[:cargo_class]
      end

      def perform
        insert_rates
      end

      private

      def _stats
        {
          type:    "hubs",
          ports:   {
            number_updated: 0,
            number_created: 0
          },
          nexuses: {
            number_updated: 0,
            number_created: 0
          }
        }
      end

      def _results
        {
          ports:   [],
          nexuses: []
        }
      end

      def split_and_capitalise(str)
        return str if str.upcase != str
        str_array = str.split(" ")
        if str_array.length > 1
          return str_array.map { |s| s.capitalize! || s }.join(" ")
        else
          str_array = ["unknown"] if str_array.first.nil?
          capitalised = str_array.first.capitalize!
          if capitalised.nil?
            return str
          else
            return capitalised
          end
        end
      end

      def find_or_create_itinerary
        port_name = @rate[:data][:port]
        @itinerary = if @direction == "import"
                       Itinerary.find_or_initialize_by(
                         name:              "#{port_name} - #{@counterpart_nexus}",
                         mode_of_transport: @rate[:data][:mot],
                         tenant:            @tenant
                       )
                     else
                       Itinerary.find_or_initialize_by(
                         name:              "#{@counterpart_nexus} - #{port_name}",
                         mode_of_transport: @rate[:data][:mot],
                         tenant:            @tenant
                       )
                     end
        create_stops(port_name)
        @itinerary.save!
      end

      def create_stops(port_name)
        stop_names = if @direction == "import"
                       ["#{port_name.strip} #{hub_type_name[@rate[:data][:mot]]}", counterpart_hub]
                     else
                       [counterpart_hub, "#{port_name.strip} #{hub_type_name[@rate[:data][:mot]]}"]
                     end
        stop_names.each_with_index do |stop_name, i|
          hub = @tenant.hubs.where(name: stop_name).first
          hub = @tenant.hubs.where("name ILIKE ?", "%#{stop_name}%").first if hub.nil?
          next unless hub
          stop = @itinerary.stops.find_by(hub_id: hub.id, index: i)
          stop = Stop.new(hub_id: hub.id, index: i) if stop.nil?
          @itinerary.stops << stop
        end
      end

      def generate_trips
        transit_time = @rate[:data][:transit_time] ? @rate[:data][:transit_time].to_i : 30
        @itinerary.generate_weekly_schedules(
          @itinerary.stops.order(:index),
          [transit_time],
          DateTime.now,
          DateTime.now + 8.weeks,
          [2, 5],
          @tenant_vehicle.id,
          4
        )
      end

      def hub_type_name
        @hub_type_name ||= {
          "ocean" => "Port",
          "air"   => "Airport",
          "rail"  => "Railyard",
          "truck" => "Depot"
        }
      end

      def find_transport_category
        service_level = @rate[:data][:service_level] || "standard"
        vehicle = TenantVehicle.find_by(name: service_level, mode_of_transport: @rate[:data][:mot], tenant_id: @tenant.id)
        @tenant_vehicle = vehicle.presence || Vehicle.create_from_name(service_level, @rate[:data][:mot], @tenant.id)
        @transport_category = @tenant_vehicle.vehicle.transport_categories.find_by(name: "any", cargo_class: @cargo_class)
      end

      def create_pricings
        default_pricing_values = {
          transport_category: @transport_category,
          tenant:             @tenant,
          user:               nil,
          wm_rate:            1000,
          effective_date:     DateTime.now,
          expiration_date:    DateTime.now + 365
        }
        pricing_to_update = @itinerary.pricings.find_or_create_by!(default_pricing_values)
        pricing_details = @rate.delete(:rate)
        pricing_details.each do |pricing_detail|
          puts pricing_detail
          shipping_type = pricing_detail.delete(:code)
          currency = pricing_detail.delete(:currency)
          pricing_detail_params = pricing_detail.merge(shipping_type: shipping_type, tenant: @tenant)
          pricing_detail = pricing_to_update.pricing_details.find_or_create_by(shipping_type: shipping_type, tenant: @tenant)
          pricing_detail.update!(pricing_detail_params)
          pricing_detail.update!(currency_name: currency) # , external_updated_at: external_updated_at)
        end
        awesome_print pricing_to_update.as_json
      end

      def insert_rates
        @rates.each do |rate|
          @rate = rate

          find_or_create_itinerary
          find_transport_category
          generate_trips
          create_pricings
        end
      end
    end
  end
end
