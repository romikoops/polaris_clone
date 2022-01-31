# frozen_string_literal: true

module ExcelDataServices
  module V3
    module Operations
      class DynamicFees < ExcelDataServices::V3::Operations::Base
        PRICING_COLUMNS = %w[group_id group_name effective_date expiration_date country_origin service_level origin origin_locode country_destination mode_of_transport destination destination_locode transshipment transit_time carrier service load_type cargo_class rate currency rate_basis fee_code fee_name fee_min fee wm_ratio vm_ratio range_max range_min remarks].freeze
        STATE_COLUMNS = %w[hub_id group_id organization_id row sheet_name].freeze

        def perform
          return state if dynamic_keys.empty?

          super
        end

        def operation_result
          @operation_result ||= Rover::DataFrame.new(non_dynamic_rows.concat(expanded_dynamic_rows)[final_columns].to_a.uniq)
        end

        def non_dynamic_rows
          @non_dynamic_rows ||= frame[!frame["fee_code"].missing]
        end

        def dynamic_rows
          @dynamic_rows ||= frame[frame["fee_code"].missing]
        end

        def expanded_dynamic_rows
          @expanded_dynamic_rows ||= dynamic_rows.inner_join(
            expanded_fees,
            on: {
              "sheet_name" => "sheet_name",
              "row" => "row"
            }
          )
        end

        def expanded_fees
          @expanded_fees ||= fees_with_notes.left_join(
            validity_frame,
            on: {
              "sheet_name" => "sheet_name",
              "row" => "row",
              "effective_date" => "original_effective_date",
              "expiration_date" => "original_expiration_date"
            }
          )
        end

        def validity_frame
          @validity_frame ||= Dynamic::ValidityFrame.new(date_frame: frame[%w[effective_date expiration_date row sheet_name]], columns: month_columns).frame
        end

        def fees_with_notes
          @fees_with_notes ||= fee_frame[!fee_frame["rate"].missing].left_join(notes_frame, on: { "sheet_name" => "sheet_name", "row" => "row" })
        end

        def fee_frame
          @fee_frame ||= columns_by_fee_code_and_period.each_with_object(empty_frame) do |columns, new_frame|
            new_frame.concat(Dynamic::FeeFromColumns.new(columns: columns).frame)
          end
        end

        def notes_frame
          @notes_frame ||= columns.select { |col| col.category == :note }.each_with_object(empty_frame) do |column, new_frame|
            note_column_frame = column.data
            new_frame.concat(note_column_frame[!note_column_frame["remarks"].missing])
          end
        end

        def month_columns
          @month_columns ||= columns.select { |col| col.category == :month }
        end

        def columns
          @columns ||= dynamic_keys.flat_map { |header| Dynamic::DataColumn.new(header: header, frame: frame) }
        end

        def columns_by_fee_code_and_period
          @columns_by_fee_code_and_period ||= columns.select(&:fee?).group_by { |col| [col.fee_code, col.current?] }.values
        end

        def dynamic_keys
          @dynamic_keys ||= frame.keys.select { |column_header| column_header.starts_with?("Dynamic") && !column_header.match?(/(_row|_column)$/) }
        end

        def existing_columns
          @existing_columns ||= frame.keys - dynamic_keys - %w[effective_date expiration_date]
        end

        def final_columns
          @final_columns ||= (existing_columns + fee_frame.keys + %w[effective_date expiration_date]).uniq
        end

        def empty_frame
          Rover::DataFrame.new({ "sheet_name" => [], "row" => [], "rate" => [] })
        end
      end
    end
  end
end
