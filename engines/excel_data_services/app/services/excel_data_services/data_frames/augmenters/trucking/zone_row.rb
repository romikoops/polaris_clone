# frozen_string_literal: true

module ExcelDataServices
  module DataFrames
    module Augmenters
      module Trucking
        class ZoneRow < ExcelDataServices::DataFrames::Augmenters::Base
          def augments
            %w[organization_id]
          end
        end
      end
    end
  end
end
