# frozen_string_literal: true

module Api
  module V2
    class ScopeSerializer < Api::ApplicationSerializer
      attributes %i[links id]
    end
  end
end
