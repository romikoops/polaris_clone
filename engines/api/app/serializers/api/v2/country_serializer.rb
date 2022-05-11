# frozen_string_literal: true

module Api
  module V2
    class CountrySerializer < Api::ApplicationSerializer
      attributes %i[id name code flag]
    end
  end
  end
