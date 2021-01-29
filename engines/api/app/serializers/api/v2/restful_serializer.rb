# frozen_string_literal: true

module Api
  module V2
    class RestfulSerializer < Api::ApplicationSerializer
      attributes [:id]
    end
  end
end
