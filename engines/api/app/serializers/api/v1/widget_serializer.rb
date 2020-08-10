# frozen_string_literal: true

module Api
  module V1
    class WidgetSerializer < Api::ApplicationSerializer
      attributes %i[name order data organization_id]
    end
  end
end
