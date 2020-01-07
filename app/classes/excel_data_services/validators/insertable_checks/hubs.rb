# frozen_string_literal: true

module ExcelDataServices
  module Validators
    module InsertableChecks
      class Hubs < ExcelDataServices::Validators::InsertableChecks::Base
        private

        def check_single_data(row)
          check_row_country(row)
        end

        def check_row_country(row)
          country = ::Legacy::Country.find_by(name: row[:address][:country])
          if country.nil?
            add_to_errors(
              type: :error,
              row_nr: row[:row_nr],
              sheet_name: sheet_name,
              reason: "There exists no country with name: #{row[:address][:country]}.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
            return
          end

          geocoded_country_name = Legacy::Address.new(latitude: row[:address][:latitude], longitude: row[:address][:longitude]).reverse_geocode&.country&.name
          return if row[:address][:country] == geocoded_country_name

          add_to_errors(
            type: :error,
            row_nr: row[:row_nr],
            sheet_name: sheet_name,
            reason: "The given coordinates do not match the assigned country: Given #{row[:address][:country]}, Geocoded: #{geocoded_country_name}.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end
      end
    end
  end
end
