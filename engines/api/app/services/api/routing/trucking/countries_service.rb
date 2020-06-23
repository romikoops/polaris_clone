# frozen_string_literal: true

module Api
  module Routing
    module Trucking
      class CountriesService < Api::Routing::Trucking::Base
        def perform
          Legacy::Country.where(code: country_codes(target_index: index)).distinct
        end
      end
    end
  end
end
