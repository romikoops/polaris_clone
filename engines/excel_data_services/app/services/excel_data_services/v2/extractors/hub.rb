# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class Hub < ExcelDataServices::V2::Extractors::Base
        def extracted
          @extracted ||= joins.inject(blank_frame.concat(frame)) do |inner_frame, join|
            inner_frame.left_join(hub_frame, on: join)
          end
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
          @joins ||= filter_joins(joins: [%w[locode], %w[hub terminal country]]).map do |join_array|
            join_array.each_with_object({ "mode_of_transport" => "mode_of_transport" }) do |prefixed_key, join_arg|
              join_arg[prefixed_key] = prefixed_key
            end
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
          @prefixer ||= ExcelDataServices::V2::Helpers::Prefixer.new(prefix: prefix)
        end

        def hub_frame
          @hub_frame ||= Rover::DataFrame.new(frame_data, types: state.frame.types.merge(frame_types))
        end

        def filter_joins(joins:)
          # rubocop:disable Rails/NegateInclude include is a Rover method, not standard rails include
          joins
            .map { |join| join.map { |row_key| prefix_key(key: row_key) } }
            .select { |join| frame.include?(join.first) }
            .map { |join| join.delete_if { |key, _value| !frame.include?(key) } }
            .reject(&:empty?)
          # rubocop:enable Rails/NegateInclude
        end
      end
    end
  end
end
