# frozen_string_literal: true

module ExcelDataServices
  module V4
    module Sanitizers
      class VmScale < ExcelDataServices::V4::Sanitizers::Base
        def valid_types_with_sanitizers
          {
            ::Float => ->(obj) { (vm_scale << decimal).call(obj) },
            ::Integer => ->(obj) { (vm_scale << decimal).call(obj) },
            ::String => ->(obj) { (vm_scale << decimal << decimal_from_string).call(obj) }
          }
        end
      end
    end
  end
end
