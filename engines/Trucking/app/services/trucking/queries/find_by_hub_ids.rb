module Trucking
  module Queries
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
            trucking_rate_id,
            MIN(country_code) AS country_code,
            MIN(ident_type) AS ident_type,
            STRING_AGG(ident_values, ',') AS ident_values
          FROM (
            SELECT
              tp_id AS trucking_rate_id,
              MIN(sub_query_lvl_2.country_code) AS country_code,
              ident_type,
              CASE
                WHEN ident_type = 'city'
                  THEN MIN(locations.name) || '*' || MIN(locations.country_code)
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
                  trucking_rates.id AS tp_id,
                  trucking_locations.country_code,
                  CASE
                    WHEN trucking_locations.zipcode  IS NOT NULL THEN 'zipcode'
                    WHEN trucking_locations.distance IS NOT NULL THEN 'distance'
                    ELSE 'city'
                  END AS ident_type,
                  CASE
                    WHEN trucking_locations.zipcode  IS NOT NULL THEN trucking_locations.zipcode::text
                    WHEN trucking_locations.distance IS NOT NULL THEN trucking_locations.distance::text
                    ELSE trucking_locations.location_id::text
                  END AS ident_value
                FROM trucking_rates
                JOIN  trucking_truckings         ON trucking_truckings.rate_id     = trucking_rates.id
                JOIN  trucking_locations ON trucking_truckings.location_id = trucking_locations.id
                WHERE trucking_truckings.hub_id IN (:hub_ids)
              ) AS sub_query_lvl_3
            ) AS sub_query_lvl_2
            LEFT OUTER JOIN locations_locations AS locations ON sub_query_lvl_2.ident_value = locations.id::text
            GROUP BY tp_id, ident_type, range
            ORDER BY MAX(ident_value)
          ) AS sub_query_lvl_1
          GROUP BY trucking_rate_id
          ORDER BY ident_values
        SQL
      end

      def deserialized_result
        @result.map do |row|
          next if row['ident_values'].nil?
          {
            'truckingPricing' => @klass.find(row['trucking_rate_id']).as_options_json,
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