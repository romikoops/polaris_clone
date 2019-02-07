# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Insertability
      class LocalCharges < Base
        def perform
          super do |row|
            raise NotImplementedError
          end
        end
      end
    end
  end
end
