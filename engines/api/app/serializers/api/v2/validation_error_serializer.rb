# frozen_string_literal: true

module Api
  module V2
    class ValidationErrorSerializer < Api::ApplicationSerializer
      attributes %i[id limit attribute message code]
    end
  end
end
