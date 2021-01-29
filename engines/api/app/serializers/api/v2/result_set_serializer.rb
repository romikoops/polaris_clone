# frozen_string_literal: true

module Api
  module V2
    class ResultSetSerializer < Api::ApplicationSerializer
      attributes [:id, :query_id, :status]
    end
  end
end
