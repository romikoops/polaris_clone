# frozen_string_literal: true

module Api
  module V2
    class QueryStatusSerializer < Api::ApplicationSerializer
      attributes %i[id status]
    end
  end
end
