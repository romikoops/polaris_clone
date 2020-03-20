# frozen_string_literal: true

module Api
  module V1
    class TripSerializer < Api::ApplicationSerializer
      attributes %i[closing start end service carrier vessel voyage_code tender_id]
    end
  end
end
