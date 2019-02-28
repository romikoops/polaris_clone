# frozen_string_literal: true

module ExcelDataServices
  module Row
    def self.get(klass_identifier)
      "#{name}::#{klass_identifier}".constantize
    end
  end
end
