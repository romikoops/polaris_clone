# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class Client < ExcelDataServices::V4::Formatters::Base
        ATTRIBUTE_KEYS = %w[company_name first_name last_name email phone external_id password currency language organization_id].freeze

        def insertable_data
          frame[ATTRIBUTE_KEYS].to_a.uniq.map do |row|
            row.slice("email", "organization_id", "password").merge(
              "profile" => row.slice("company_name", "first_name", "last_name", "phone", "external_id"),
              "settings" => row.slice("currency", "language")
            )
          end
        end
      end
    end
  end
end
