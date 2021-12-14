# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Validators
      class Language < ExcelDataServices::V2::Validators::Base
        VALID_LANGUAGES = %w[en-US de-DE es-ES].freeze

        def extract_state
          @state
        end

        def append_errors_to_state
          frame[!frame["language"].in?(VALID_LANGUAGES)].to_a.each do |row|
            append_error(row: row)
          end
        end

        def error_reason(row:)
          "The language '#{row['language']}' is not one of #{VALID_LANGUAGES.join(', ')}"
        end
      end
    end
  end
end
