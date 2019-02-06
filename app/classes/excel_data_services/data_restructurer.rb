# frozen_string_literal: true

module ExcelDataServices
  module DataRestructurer
    def self.get(klass_identifier)
      const_get(klass_identifier)
    end
  end
end
