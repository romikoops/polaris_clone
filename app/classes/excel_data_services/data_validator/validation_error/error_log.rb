# frozen_string_literal: true

module ExcelDataServices
  module DataValidator
    module ValidationError
      class ErrorLog < Base
        attr_reader :errors_ary

        def initialize(errors_ary = [])
          @errors_ary = errors_ary
        end
      end
    end
  end
end
