# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Overlaps
      class Clearer
        DATE_KEYS = ExcelDataServices::V4::Validators::SequentialDates::DATE_PAIRS.flatten.freeze

        attr_reader :frame, :model, :conflict_keys

        def initialize(frame:, model:, conflict_keys:)
          @frame = frame
          @model = model
          @conflict_keys = conflict_keys
        end

        def perform
          ActiveRecord::Base.transaction do
            create_data_frame_table
            copy_into_table
            set_uuids_and_validity
            create_sub_query_table
            soft_delete_conflicts
            soft_delete_past_conflicts
            update_existing_conflicts
          end
        ensure
          connection.drop_table(data_frame_table_name.to_sym, if_exists: true)
          connection.drop_table(record_data_table_name.to_sym, if_exists: true)
        end

        def copy_into_table
          connection.raw_connection.copy_data "COPY #{data_frame_table_name} (#{relevant_keys.join(', ')}) FROM stdin WITH delimiter ',' csv;" do
            while (line = csv.gets)
              connection.raw_connection.put_copy_data(line.to_s)
            end
          end
          csv.close
        end

        def csv
          @csv ||= CSV.new(relevant_frame.to_csv, headers: true)
        end

        def connection
          @connection ||= ActiveRecord::Base.connection
        end

        def relevant_keys
          @relevant_keys ||= frame.keys & (conflict_keys + DATE_KEYS)
        end

        def relevant_frame
          @relevant_frame ||= frame[relevant_keys].uniq
        end

        def table_name
          @table_name ||= model.table_name
        end

        def row
          @row ||= frame.to_a.first
        end

        def upsert_key
          @upsert_key ||= %w[uuid upsert_id].find { |key| model.attribute_types[key].type.present? }
        end

        def data_frame_table_name
          @data_frame_table_name ||= "df_#{SecureRandom.hex}"
        end

        def record_data_table_name
          @record_data_table_name ||= "rd_#{SecureRandom.hex}"
        end

        def create_sub_query_table
          connection.drop_table(record_data_table_name.to_sym, if_exists: true)
          connection.create_table(record_data_table_name.to_sym, temporary: true, as:
            <<-SQL.squish
              SELECT
                existing.validity as existing_validity,
                existing.id as existing_id,
                #{data_frame_table_name}.validity as data_frame_validity,
                UPPER(#{data_frame_table_name}.validity) < now()::date as expired,
                LOWER(#{data_frame_table_name}.validity) > LOWER(existing.validity) as future
              #{main_join_switch}
              AND #{data_frame_table_name}.validity && existing.validity
              AND existing.deleted_at IS NULL;
            SQL
          )
        end

        def create_data_frame_table
          connection.drop_table(data_frame_table_name.to_sym, if_exists: true)
          connection.create_table(data_frame_table_name.to_sym, temporary: true) do |t|
            t.uuid :upsert_id, index: true
            t.daterange :validity, index: true
            relevant_keys.each do |key|
              case row[key]
              when Date, DateTime, Time
                t.date key.to_sym, index: conflict_keys.include?(key)
              when Integer
                t.integer key.to_sym, index: conflict_keys.include?(key)
              when String
                if key.ends_with?("_id")
                  t.uuid key.to_sym, index: conflict_keys.include?(key)
                else
                  t.string key.to_sym, index: conflict_keys.include?(key)
                end
              when NilClass
                model_type = model.attribute_types[key].type
                t.send(model_type, key.to_sym, index: conflict_keys.include?(key))
              end
            end
          end
        end

        def set_uuids_and_validity
          connection.execute(
            "
            UPDATE #{data_frame_table_name}
            SET validity = daterange(#{data_frame_table_name}.effective_date::date, #{data_frame_table_name}.expiration_date::date, '[)')
            "
          )
          return unless upsert_key

          concat_arguments = model::UUID_KEYS.map { |key| "#{key}::text" }.join(", ")
          connection.execute(
            "
            UPDATE #{data_frame_table_name}
            SET upsert_id = uuid_generate_v5('#{model::UUID_V5_NAMESPACE}', CONCAT(#{concat_arguments})::text)
            "
          )
        end

        def update_existing_conflicts
          connection.execute(
            <<-SQL.squish
              UPDATE #{table_name}
              SET #{update_clause}
              FROM #{record_data_table_name}
              WHERE #{record_data_table_name}.existing_id = #{table_name}.id
              AND #{record_data_table_name}.future = true
              AND #{table_name}.deleted_at IS NULL;
            SQL
          )
        end

        def soft_delete_conflicts
          connection.execute(
            <<-SQL.squish
              UPDATE #{table_name}
              SET deleted_at = now()
              FROM #{record_data_table_name}
              WHERE #{record_data_table_name}.existing_id = #{table_name}.id
              AND #{record_data_table_name}.future = false
              AND #{record_data_table_name}.expired = false
              AND #{table_name}.deleted_at IS NULL;
            SQL
          )
        end

        def soft_delete_past_conflicts
          connection.execute(
            <<-SQL.squish
              UPDATE #{table_name}
              SET deleted_at = now()
              FROM #{record_data_table_name}
              WHERE #{record_data_table_name}.existing_id = #{table_name}.id
              AND #{record_data_table_name}.expired = true
              AND #{table_name}.deleted_at IS NULL;
            SQL
          )
        end

        def update_clause
          [
            "validity = daterange(LOWER(#{table_name}.validity), LOWER(#{record_data_table_name}.data_frame_validity), '[)'),",
            (model.respond_to?(:expiration_date?) ? "expiration_date = LOWER(#{record_data_table_name}.data_frame_validity)::timestamp - interval '1 millisecond'," : nil),
            "updated_at = now()"
          ].compact.join
        end

        def model_date_keys
          @model_date_keys ||= DATE_KEYS.select { |key| model.respond_to?(key) }
        end

        def main_join_switch
          return trucking_join if model == Trucking::Trucking

          upsert_join
        end

        def trucking_join
          <<-SQL.squish
            FROM #{table_name} AS existing
            INNER JOIN #{data_frame_table_name}
            ON #{attributes_in_sql(attributes: (conflict_keys + model_date_keys) - ['country_id'])}
            INNER JOIN trucking_locations
            ON existing.location_id = trucking_locations.id
            AND trucking_locations.country_id = #{data_frame_table_name}.country_id
          SQL
        end

        def upsert_join
          <<-SQL.squish
            FROM #{table_name} AS existing
            INNER JOIN #{data_frame_table_name}
            ON existing.#{upsert_key} = #{data_frame_table_name}.upsert_id
          SQL
        end

        def attributes_in_sql(attributes:)
          attributes.map { |key| "existing.#{key} = #{data_frame_table_name}.#{key}" }.join(" AND ")
        end
      end
    end
  end
end
