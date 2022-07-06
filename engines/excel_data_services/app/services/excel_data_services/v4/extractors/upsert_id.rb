# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Extractors
      class UpsertId < ExcelDataServices::V4::Extractors::Base
        def extracted
          @extracted ||= Rover::DataFrame.new(
            frame.to_a.map do |row|
              row.merge(upsert_key => upsert_id_from_row(row: row))
            end
          )
        end
      end
    end
  end
end
