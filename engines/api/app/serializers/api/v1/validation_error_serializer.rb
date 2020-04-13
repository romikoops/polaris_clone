# frozen_string_literal: true

module Api
  module V1
    class ValidationErrorSerializer < Api::ApplicationSerializer
      attributes %i[id section limit attribute message code]
    end
  end
end
