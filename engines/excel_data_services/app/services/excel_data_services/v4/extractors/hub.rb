# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class Hub < ExcelDataServices::V4::Extractors::Base
        def extracted
          @extracted ||= blank_frame.concat(frame).left_join(hub_frame, on: joins)
        end

        def frame_data
          @frame_data ||=
            Legacy::Hub.where(organization_id: Organizations.current_id)
              .joins(nexus: :country)
              .select("
              hubs.id as #{prefix_key(key: 'hub_id')},
              hubs.name as #{prefix_key(key: 'hub')},
              terminal as #{prefix_key(key: 'terminal')},
              hub_code as #{prefix_key(key: 'locode')},
              countries.name as #{prefix_key(key: 'country')},
              hub_type as mode_of_transport
            ")
        end

        def routing_row_keys
          %w[terminal locode country hub].map { |atr| prefix_key(key: atr) } + %w[mode_of_transport]
        end

        def joins
          @joins ||= filtered_join_keys.each_with_object({ "mode_of_transport" => "mode_of_transport" }) do |prefixed_key, join_arg|
            join_arg[prefixed_key] = prefixed_key
          end
        end

        def frame_types
          (routing_row_keys + [required_key]).each_with_object({}) do |row_key, join_arg|
            join_arg[row_key] = :object
          end
        end

        def prefix
          ""
        end

        def required_key
          prefix_key(key: "hub_id")
        end

        def prefix_key(key:)
          prefixer.prefix_key(key: key)
        end

        def prefixer
          @prefixer ||= ExcelDataServices::V4::Helpers::Prefixer.new(prefix: prefix)
        end

        def hub_frame
          @hub_frame ||= Rover::DataFrame.new(frame_data, types: state.frame.types.merge(frame_types))
        end

        def filtered_join_keys
          prefixed_and_validated_keys = %w[locode hub terminal country]
            .map { |row_key| prefix_key(key: row_key) }
            .select { |join_key| frame.include?(join_key) }
            .reject { |join_key| frame[join_key].missing.all? }

          return prefixed_and_validated_keys if prefixed_and_validated_keys.exclude?(prefix_key(key: "locode"))

          prefixed_and_validated_keys - [prefix_key(key: "country")]
        end
      end
    end
  end
end
