# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Helpers
      class Prefixer
        def initialize(prefix:)
          @prefix = prefix
        end

        def prefix_key(key:)
          return key if prefix.blank?

          "#{prefix}_#{key}"
        end

        private

        attr_reader :prefix
      end
    end
  end
end
