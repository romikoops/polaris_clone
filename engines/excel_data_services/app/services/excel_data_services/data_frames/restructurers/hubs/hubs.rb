# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Restructurers
      module Hubs
        class Hubs < ExcelDataServices::DataFrames::Restructurers::Base
          ATTRIBUTE_KEYS = %w[name type status locode nexus_id address_id latitude longitude free_out terminal terminal_code mandatory_charge_id organization_id].freeze

          def restructured_data
            frame[ATTRIBUTE_KEYS].to_a.uniq.map do |row|
              row["hub_code"] = row.delete("locode")
              row["hub_type"] = row.delete("type")
              row["hub_status"] = row.delete("status")
              row
            end
          end
        end
      end
    end
  end
end
