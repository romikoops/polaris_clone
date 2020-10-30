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
          country_name = row[:address].dig(:country, :name)
          country = ::Legacy::Country.find_by(name: country_name)
          if country.nil?
            add_to_errors(
              type: :error,
              row_nr: row[:row_nr],
              sheet_name: sheet_name,
              reason: "There exists no country with name: #{country_name}.",
              exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
            )
            return
          end

          geocoded_country_name = Legacy::Address.new(latitude: row[:address][:latitude], longitude: row[:address][:longitude]).reverse_geocode&.country&.name
          return if country_name == geocoded_country_name

          add_to_errors(
            type: :error,
            row_nr: row[:row_nr],
            sheet_name: sheet_name,
            reason: "The given coordinates do not match the assigned country: Given #{country_name}, Geocoded: #{geocoded_country_name}.",
            exception_class: ExcelDataServices::Validators::ValidationErrors::InsertableChecks
          )
        end
      end
    end
  end
end
