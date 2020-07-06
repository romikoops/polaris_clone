# frozen_string_literal: true

module Api
  module Routing
    module Trucking
      class CountriesService < Api::Routing::Trucking::Base
        def perform
          countries(target_index: index)
        end
      end
    end
  end
end
