# frozen_string_literal: true

module Api
  module V1
    class CountrySerializer < Api::ApplicationSerializer
      attributes %i[name code flag]
    end
  end
end
