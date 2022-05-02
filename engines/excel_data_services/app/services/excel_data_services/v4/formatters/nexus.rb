# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Formatters
      class Nexus < ExcelDataServices::V4::Formatters::Base
        ATTRIBUTE_KEYS = %w[name locode organization_id country_id latitude longitude].freeze

        def insertable_data
          frame[ATTRIBUTE_KEYS].to_a.uniq
        end
      end
    end
  end
end
