include Translator

module DataInserter
  module PfcNordic
    class HubInserter < DataInserter::BaseInserter
      attr_reader :path, :user, :hub_data, :existing_hub_data, :data, :hub_type, :hub, :input_language

      def post_initialize(args)
        @user = args[:_user]
        @hub_type = args[:hub_type]
      end

      def perform
        insert_hubs
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

        def find_port_data
          
          port = Port.where(code: @hub_data[:code]).first
          if port
            return port
          else
            return geocode_port_data
          end
        end

        def find_or_create_hub

          temp_hub = @user.tenant.hubs.where(
            name: "#{@existing_hub_data[:name]} #{hub_type_name[@hub_type]}",
            hub_type: @hub_type
          ).first
          @hub = temp_hub || @user.tenant.hubs.find_or_create_by(
            name: "#{@existing_hub_data[:name]} #{hub_type_name[@hub_type]}",
            latitude: @existing_hub_data[:latitude],
            longitude: @existing_hub_data[:longitude],
            location: @existing_hub_data[:location],
            nexus: @existing_hub_data[:nexus],
            hub_type: @hub_type
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

        def split_and_capitalise(str)
          str_array = str.split(' ')
          if str_array.length > 1
            return str_array.map(&:capitalize!).join(' ')
          else
            return str_array.first.capitalize!
          end
        end

        def get_hub_name(str)
          cased_string = split_and_capitalise(str)
          if @input_language && @input_language != 'en'
            name = Translator::GoogleTranslator.new(origin_language: @input_language, target_language: 'en', text: cased_str).perform
            return name
          else
            return cased_string
          end
        end

        def geocode_port_data
          port_location = Location.geocoded_location("#{@hub_data[:port]}, #{@hub_data[:country]}")
          port_nexus = Location.from_short_name("#{@hub_data[:port]} ,#{@hub_data[:country]}", 'nexus')
          return {
            hub_code: @hub_data[:code],
            name: split_and_capitalise(@hub_data[:port]),
            latitude: port_location.latitude,
            longitude: port_location.longitude,
            location: port_location,
            nexus: port_nexus,
            country_id: port_location.country_id
          }
        end


        def insert_hubs
          @data.each do |hub_data|
            @hub_data = hub_data
            @existing_hub_data = find_port_data
            find_or_create_hub
          end
        end
    end
  end
end
