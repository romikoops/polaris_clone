# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class DefaultCurrency < ExcelDataServices::V2::Extractors::Base
        def frame_data
          [
            { "currency" => state.organization.scope.default_currency, "join_value" => nil, "organization_id" => state.organization.id }
          ]
        end

        def join_arguments
          { "currency" => "join_value", "organization_id" => "organization_id" }
        end

        def frame_types
          { "currency" => :object, "organization_id" => :object }
        end
      end
    end
  end
end
