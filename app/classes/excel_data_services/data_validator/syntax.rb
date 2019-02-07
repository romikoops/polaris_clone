# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Syntax
      def self.get(klass_identifier)
        const_get(klass_identifier)
      end
    end
  end
end
