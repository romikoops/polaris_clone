# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module Insertability
      class LocalCharges < Base
        private

        def check_data(_single_data)
          raise NotImplementedError
        end
      end
    end
  end
end
