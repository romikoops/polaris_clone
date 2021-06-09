# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Restructurers
      module Hubs
        class Nexuses < ExcelDataServices::DataFrames::Restructurers::Base
          ATTRIBUTE_KEYS = %w[name locode country_id latitude longitude organization_id].freeze

          def restructured_data
            frame[ATTRIBUTE_KEYS].to_a.uniq
          end
        end
      end
    end
  end
end
