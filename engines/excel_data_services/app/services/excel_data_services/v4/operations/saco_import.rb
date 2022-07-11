# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Operations
      class SacoImport < ExcelDataServices::V4::Operations::Base
        PRIMARY_FEE_CODE = ExcelDataServices::V4::Operations::Dynamic::DataColumn::PRIMARY_CODE_PLACEHOLDER

        def operation_result
          @operation_result ||= main_frame
            .concat(included_frame)
            .concat(pre_carriage_frame)
            .left_join(remarks_frame, on: { "row" => "row", "fee_code" => "fee_code" })
        end

        def precarriage_keys
          @precarriage_keys ||= frame.keys - %w[minimum rate]
        end

        def main_keys
          @main_keys ||= frame.keys.reject { |key| key.starts_with?("pre") } + [rate_basis_key]
        end

        def dynamic_keys
          @dynamic_keys ||= frame.keys.select { |key| key.starts_with?("Dynamic") }
        end

        def rate_basis_key
          @rate_basis_key ||= dynamic_keys.min_by { |key| key[/[0-9]{1,}/].to_i }
        end

        def ratio_info_key
          @ratio_info_key ||= dynamic_keys.max_by { |key| key[/[0-9]{1,}/].to_i }
        end

        def valid_frame
          @valid_frame ||= frame[!frame["rate"].in?([nil, 0, "on request"])]
        end

        def pre_carriage_frame
          @pre_carriage_frame ||= valid_frame[!valid_frame["pre_carriage_rate"].missing][precarriage_keys].tap do |pre_car_frame|
            pre_car_frame["fee_code"] = "pre_carriage"
            pre_car_frame["fee_name"] = "Pre-carriage"
            pre_car_frame["rate_basis"] = pre_car_frame.delete("pre_carriage_basis")
            pre_car_frame["rate"] = pre_car_frame.delete("pre_carriage_rate")
            pre_car_frame["minimum"] = pre_car_frame.delete("pre_carriage_minimum")
            pre_car_frame["cbm_ratio"] = pre_car_frame[ratio_info_key].map { |row| parse_ratio_info(string: row) }
          end
        end

        def main_frame
          @main_frame ||= valid_frame[main_keys].tap do |main_fra|
            main_fra["fee_code"] = PRIMARY_FEE_CODE
            main_fra["rate_basis"] = main_fra.delete(rate_basis_key)
            main_fra["cbm_ratio"] = main_fra[ratio_info_key].map { |row| parse_ratio_info(string: row) }
          end
        end

        def included_frame
          @included_frame ||= base_include_frame.concat(Rover::DataFrame.new(
            included_frame_data.compact
          ))
        end

        def remarks_frame
          @remarks_frame ||= base_include_frame.concat(Rover::DataFrame.new(
            remarks_frame_data.compact
          ))
        end

        def base_include_frame
          Rover::DataFrame.new(
            [ratio_info_key, "row", "sheet_name", "fee_code", "fee_name"].zip([[]] * 5).to_h
          )
        end

        def included_frame_data
          valid_frame_with_ratio_info[main_keys].to_a.flat_map do |row|
            incl_string = row[ratio_info_key].to_s.downcase
            next if incl_string.exclude?("incl.")

            fee_code_string = incl_string.split("incl.").map(&:strip).reject(&:blank?).first
            fee_code_string.split("/").map do |included_fee_code|
              row.merge(
                "fee_code" => "included_#{included_fee_code}",
                "fee_name" => included_fee_code.upcase,
                "rate" => 0,
                "rate_basis" => row[rate_basis_key]
              )
            end
          end
        end

        def remarks_frame_data
          valid_frame_with_ratio_info[[ratio_info_key, "rate_info", "row", "sheet_name"]].to_a.flat_map do |row|
            remark_values = row.values_at("rate_info", ratio_info_key).compact
            next if remark_values.empty?

            fee_code = row[ratio_info_key].downcase.starts_with?("pre") ? "pre_carriage" : PRIMARY_FEE_CODE
            row.merge(
              "remarks" => remark_values.join(". "),
              "fee_code" => fee_code
            )
          end
        end

        def parse_ratio_info(string:)
          return 1000 if string.blank? || string.include?("incl.")

          string.gsub("= 1 cbm", "")[/[0-9]{1,}/].to_f
        end

        def valid_frame_with_ratio_info
          @valid_frame_with_ratio_info ||= valid_frame[!valid_frame[ratio_info_key].missing]
        end
      end
    end
  end
end
