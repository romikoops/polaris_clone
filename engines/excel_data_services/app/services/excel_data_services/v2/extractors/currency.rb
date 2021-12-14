# frozen_string_literal: true

module ExcelDataServices
  module V2
    module Extractors
      class Currency < ExcelDataServices::V2::Extractors::Base
        def frame_data
          Treasury::ExchangeRate.current.select("id AS currency_id, treasury_exchange_rates.to AS existing_currency")
        end

        def join_arguments
          { "currency" => "existing_currency" }
        end

        def frame_types
          { "existing_currency" => :object, "currency_id" => :object }
        end
      end
    end
  end
end
