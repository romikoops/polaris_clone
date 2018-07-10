include Translator

module DataInserter
  module PfcNordic
    class RateInserter < DataInserter::BaseInserter
      attr_reader :path, :user, :hub_data, :counterpart_hub, :rates, :tenant,
        :direction, :cargo_class, :tenant_vehicle, :transport_category

      def post_initialize(args)
        @rates = args[:rates]
        @counterpart_hub = args[:counterpart_hub]
        @counterpart_hnexus = args[:counterpart_hub].split(' Port').first
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
            type: "hubs",
            ports: {
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
            ports: [],
            nexuses: []
          }
        end

        def find_or_create_itinerary
          if @direction == 'import'
            @itinerary = Itinerary.find_or_initialize_by(
              name: "#{@rate[:data][:port]} - #{@counterpart_nexus}",
              mode_of_transport: @rate[:data][:mot],
              tenant: @tenant
            )
          else
            @itinerary = Itinerary.find_or_initialize_by(
              name: "#{@counterpart_nexus} - #{@rate[:data][:port]}",
              mode_of_transport: @rate[:data][:mot],
              tenant: @tenant
            )
          end
          create_stops
          @itinerary.save!
        end

        def create_stops
          if @direction == 'import'
            stop_names = ["#{@rate[:data][:port]} #{hub_type_name[@rate[:data][:mot]]}", counterpart_hub]
          else
            stop_names = [counterpart_hub, "#{@rate[:data][:port]} #{hub_type_name[@rate[:data][:mot]]}"]
          end
          stop_names.each_with_index do |stop_name, i|
              hub = @tenant.hubs.where(name: stop_name).first
             if hub.nil?
                byebug
              end
              stop = @itinerary.stops.find_by(hub_id: hub.id, index: i)
              if stop.nil?
                stop = Stop.new(hub_id: hub.id, index: i)
              end
              @itinerary.stops << stop
          end
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
          vehicle = TenantVehicle.find_by(name: @rate[:data][:service_level], mode_of_transport: @rate[:data][:mot], tenant_id: @tenant.id)
          @tenant_vehicle = vehicle.presence || Vehicle.create_from_name(@rate[:data][:service_level], @rate[:data][:mot], @tenant.id)
          @transport_category = @tenant_vehicle.vehicle.transport_categories.find_by(name: "any", cargo_class: @cargo_class)
        end

        def create_pricings
          
          pricing_to_update = @itinerary.pricings.find_or_create_by!(transport_category: @transport_category, tenant: @tenant, user: nil)
          pricing_detail = @rate.delete(:rate)
          shipping_type = 'BAS'
          currency = pricing_detail.delete(:currency)
          pricing_detail_params = pricing_detail.merge(shipping_type: shipping_type, tenant: @tenant)
          pricing_detail = pricing_to_update.pricing_details.find_or_create_by(shipping_type: shipping_type, tenant: @tenant)
          pricing_detail.update!(pricing_detail_params)
          pricing_detail.update!(currency_name: currency) # , external_updated_at: external_updated_at)
          awesome_print pricing_to_update.as_json
        end


        def insert_rates
          @rates.each do |rate|
            @rate = rate
            
            find_or_create_itinerary
            find_transport_category
            create_pricings
          end
        end
    end
  end
end
