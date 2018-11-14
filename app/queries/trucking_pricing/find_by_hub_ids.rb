# frozen_string_literal: true

module Queries
  module TruckingPricing
    class FindByHubIds
      attr_reader :result

      def initialize(args = {})
        argument_errors(args)

        @klass = args[:klass]
        @hub_ids = args[:hub_ids]
      end

      def perform
        sanitized_query = ApplicationRecord.public_sanitize_sql([raw_query, binds])

        @result = ApplicationRecord.connection.exec_query(sanitized_query).to_a
      end

      def binds
        { hub_ids: @hub_ids }
      end

      def raw_query
        <<-SQL
          SELECT
            trucking_pricing_id,
            MIN(country_code) AS country_code,
            MIN(ident_type) AS ident_type,
            STRING_AGG(ident_values, ',') AS ident_values
          FROM (
            SELECT
              tp_id AS trucking_pricing_id,
              MIN(country_code) AS country_code,
              ident_type,
              CASE
                WHEN ident_type = 'city'
                  THEN MIN(locations.city) || '*' || MIN(locations.country)
                ELSE
                  MIN(ident_value)::text      || '*' || MAX(ident_value)::text
              END AS ident_values
            FROM (
              SELECT tp_id, ident_type, ident_value, country_code,
                CASE
                WHEN ident_type <> 'city'
                  THEN DENSE_RANK() OVER(PARTITION BY tp_id, ident_type ORDER BY ident_value) - ident_value::integer
                END AS range
              FROM (
                SELECT
                  trucking_pricings.id AS tp_id,
                  trucking_destinations.country_code,
                  CASE
                    WHEN trucking_destinations.zipcode  IS NOT NULL THEN 'zipcode'
                    WHEN trucking_destinations.distance IS NOT NULL THEN 'distance'
                    ELSE 'city'
                  END AS ident_type,
                  CASE
                    WHEN trucking_destinations.zipcode  IS NOT NULL THEN trucking_destinations.zipcode::integer
                    WHEN trucking_destinations.distance IS NOT NULL THEN trucking_destinations.distance::integer
                    ELSE trucking_destinations.location_id
                  END AS ident_value
                FROM trucking_pricings
                JOIN  hub_truckings         ON hub_truckings.trucking_pricing_id     = trucking_pricings.id
                JOIN  trucking_destinations ON hub_truckings.trucking_destination_id = trucking_destinations.id
                WHERE hub_truckings.hub_id IN (:hub_ids)
              ) AS sub_query_lvl_3
            ) AS sub_query_lvl_2
            LEFT OUTER JOIN locations ON sub_query_lvl_2.ident_value = locations.id
            GROUP BY tp_id, ident_type, range
            ORDER BY MAX(ident_value)
          ) AS sub_query_lvl_1
          GROUP BY trucking_pricing_id
          ORDER BY ident_values
        SQL
      end

      def deserialized_result
        @result.map do |row|
          next if row['ident_values'].nil?
          {
            'truckingPricing' => @klass.find(row['trucking_pricing_id']).as_options_json,
            row['ident_type'] => row['ident_values'].split(',').map { |range| range.split('*') },
            'countryCode'     => row['country_code']
          }
        end.compact
      end

      def argument_errors(args)
        raise ArgumentError, 'Must provide hub_ids or hub_id' if args[:hub_ids].empty?
      end
    end
  end
end
